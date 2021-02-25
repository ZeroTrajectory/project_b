using System;
using System.IO;
using UnityEngine;
using UnityEngine.Networking;

namespace Core.Load
{
    public class RemoteDownloadConfig
    {
        public static bool DebugMode = false;                 //测试模式
        public static uint DownloadSpeedMinPerFileInKB = 1;  //默认最低网速1kb/s
        public static uint ConcurrencyLimit =  5;            //默认并发数(从15修改为5)
        public static uint DownloadBytesMinPerCheck
        {
            get => DownloadSpeedMinPerFileInKB * 1024 * 10;
        }
    }
    /// <summary>
    /// RemoteFileLoader构造参数
    /// </summary>
    public class RemoteFileLoaderData
    {
        public string abName;
        public string suburl;
        public string savePath;
        public int timeOut;
        public Action<string, RemoteFileLoaderState> callback;
        // 进度回调
        public Action<string, ulong, float> progressHandler;
        // 默认mask
        public ulong mask = LoadMask.ONLY_ASSET;
        // 是否允许relocate(热更文件列表地址唯一确定,不relocate/热更文件允许relocate)
        public bool willRelocate = false;
        public string depKey
        {
            get { return LoadUtility.instance.GenFilekey(abName); }
        }
        public string[] hosts
        {
            get { return LoadUtility.instance.UpdatePrefixUri; }
        }
    }

    /// <summary>
    /// 相关错误枚举
    /// </summary>
    public enum RemoteFileLoaderState
    {
        Success = 0,
        FailTimeout = 1,           //一般下载超时
        FailHandler = 2,           //DownloadHandlerFile创建失败
        FailMove = 3,              //无法从temp拷贝到正式地址
        FailHash = 4               //md5校验失败
    }

    public class RemoteFileLoader : BaseLoader
    {
        // 超时判断相关
        //const ulong MIN_BYTES_FOR_TIMEOUT = 500 * 1024 / DownloadQueueHelper.MAX_DOWNLOAD_COUNT; //最低每秒50k/10秒500k(总)
        //const float MIN_PROGRESS_FOR_TIMEOUT = 0.01f;   //最低每10秒1%
        static readonly int[] TIMEOUT_PROTOCOL = new int[]{10 , 10 , 15};
        // 超时计时器
        private int m_SwitchTs = 0;
        private ulong m_DownloadBytes = 0;
        private float m_DownloadProgress = 0.0f;
        // 网速计时器
        private int m_SpeedCacheTs = 0;

        private string m_url;
        private string m_AssetBundleName;
        private UnityWebRequest m_UnityWebRequest;
        private DownloadHandlerFile m_DownloadHandlerFile;
        private Action<string, RemoteFileLoaderState> m_CallbackBytes;
        private Action<string, ulong, float> progressHandler;

        private string[] m_Urls;
        private string m_Suburl;
        private int m_TotalSwitchCount = 0;//线路总数
        private int m_SwitchCount = 0;//已切次数
        static int m_CurCDNUrlIndex = 0;//当前线路，每次下载不重置

        private int m_Timeout = 0;
        private bool m_WillRelocate = false;
        private const float TIMEOUT_ADD_RATE = 1.3f;


        public RemoteFileLoader(RemoteFileLoaderData loaderData)
        : this(loaderData.depKey, loaderData.abName, loaderData.hosts, loaderData.suburl, loaderData.savePath, loaderData.timeOut)
        {
            // 调用原始构造函数(已私有化)
            // loaderData不需要备份 保持只用一份数据
            progressHandler = loaderData.progressHandler;//可以为空
            m_WillRelocate = loaderData.willRelocate;
        }
        private RemoteFileLoader(string key, string assetBundleName, string[] urls, string suburl, string savePath, int timeout)
        {
            m_Progress = 0;
            m_Key = key;
            m_AssetBundleName = assetBundleName;
            m_Urls = urls;
            m_Suburl = suburl;
            m_AssetPath = savePath;
            m_Timeout = timeout;
            m_TotalSwitchCount = m_Urls.Length;
            m_SwitchCount = 0;
            loadStatus = ELoadStatus.Waiting;
        }

        public override string name
        {
            get
            {
                return m_AssetBundleName;
            }
        }

        public UnityEngine.Object asset
        {
            get
            {
                return null;
            }
        }

        public override void LoadAsync()
        {
            LoadFromRemote();
        }

        public void SetCallback(Action<string, RemoteFileLoaderState> callBack)
        {
            if (loadStatus == ELoadStatus.Loaded)
            {
                callBack(m_AssetPath, RemoteFileLoaderState.Success);
            }
            else
            {
                m_CallbackBytes = callBack;
            }
        }

        private void LoadFromRemote()
        {
            loadStatus = ELoadStatus.Loading;
            // 重置超时计时器
            ResetTimeoutCalculator();
            // 重置UnityWebRequest
            ResetUnityWebRequest();

            if (!TryGetTotalUrl(out m_url))
            {
                Debug.LogError("All lines have been tried! ");
                m_CallbackBytes(m_AssetPath, RemoteFileLoaderState.FailTimeout);
            }
            else 
            {
                Debug.Log(m_url);

                // 初始化文件句柄
                if (InitDownloadHandlerFile(m_AssetPath))
                {
                    m_DownloadHandlerFile.removeFileOnAbort = true;
                    // 初始化下载句柄
                    m_UnityWebRequest = UnityWebRequest.Get(m_url);
                    m_UnityWebRequest.downloadHandler = m_DownloadHandlerFile;
                    DoSendWebRequest();
                }
                else
                {
                    // 修正:若文件句柄初始化失败,不再实例化m_UnityWebRequest
                    m_CallbackBytes(m_AssetPath, RemoteFileLoaderState.FailHandler);
                }
            }
            
        }
        bool InitDownloadHandlerFile(string savePath)
        {
            bool isSuccess = false;
            string pathToDelete = string.Empty;
            int tryTimesLeft = 3;
            while(tryTimesLeft > 0 && !isSuccess)
            {
                try
                {
                    if(pathToDelete != string.Empty)
                    {
                        var _copy = pathToDelete;
                        pathToDelete = string.Empty;
                        // 测试代码 仅在首次句柄创建失败时尝试删除
                        // 句柄创建失败大概率是读写权限被占用
                        // 因此无法创建句柄时大概率也无法正常删除
                        Debug.LogError("RemoteFileLoader.LoadFromRemote Delete begin " + _copy);
                        File.Delete(_copy);
                        Debug.LogError("RemoteFileLoader.LoadFromRemote Delete end " + _copy);
                    }
                    // 创建文件句柄
                    m_DownloadHandlerFile = new DownloadHandlerFile(savePath);
                    // 成功
                    isSuccess = true;
                }
                catch (Exception e)
                {
                    Debug.LogError(e);
                    Debug.LogError("RemoteFileLoader.LoadFromRemote catch " + tryTimesLeft + "times " + savePath);

                    switch (tryTimesLeft)
                    {
                        case 3:
                            {
                                // 首次失败(准备尝试第二次创建/检查文件是否存在/尝试删除)
                                if (File.Exists(savePath)) pathToDelete = savePath;
                                Debug.LogError("RemoteFileLoader.InitDownloadHandlerFile exist " + pathToDelete);
                                break;
                            }
                        case 2:
                            {
                                // 再次失败(准备尝试第三次创建/尝试更改临时下载路径)
                                if(m_WillRelocate)
                                {
                                    m_AssetPath = m_AssetPath + AssetConst.HOTUPDATE_TEMP_RELOCATE;
                                    savePath = m_AssetPath;
                                }
                                Debug.LogError("RemoteFileLoader.InitDownloadHandlerFile m_WillRelocate " + m_WillRelocate.ToString());
                                Debug.LogError("RemoteFileLoader.InitDownloadHandlerFile relocate " + savePath);
                                break;
                            }
                        case 1:
                            {
                                // 放弃治疗,弹框提示失败
                                break;
                            }
                    }
                    tryTimesLeft--;
                }
            }
            return isSuccess;
        }
        void DoSendWebRequest()
        {
            // 暂时不使用固定时长判定是否超时 改为动态检测下载百分比
            //m_UnityWebRequest.timeout = m_Timeout;
            m_UnityWebRequest.SendWebRequest();          
        }

        public override void OnUpdate()
        {
            if (m_UnityWebRequest != null)
            {
                OnUpdateUnityWebRequest();
            }
        }

        private void OnUpdateUnityWebRequest()
        {
            m_Progress = m_UnityWebRequest.downloadProgress;

            if (m_UnityWebRequest == null)
            {
                return;
            }

            if (m_UnityWebRequest.isHttpError || m_UnityWebRequest.isNetworkError || IsTimeout())
            {
                OnDownloadException();
                return;
            }

            if (m_UnityWebRequest.downloadHandler.isDone)
            {
                bool isExist = File.Exists(m_AssetPath);
                // debug
                Debug.Log(string.Format("RemoteFileLoader.isDone {0} , {1}", isExist.ToString(), m_AssetPath));
                if(!isExist)
                {
                    // 文件不存在的异常
                    Debug.Log(string.Format("RemoteFileLoader.isDone NOT Exist ERROR {0}", m_AssetPath));
                    OnDownloadException();
                    return;
                }

                loadStatus = ELoadStatus.Loaded;
                m_Progress = 1;
                // 下载完成更新进度
                progressHandler?.Invoke(m_AssetBundleName, m_UnityWebRequest.downloadedBytes, 1.0f);
                // 回调
                m_CallbackBytes?.Invoke(m_AssetPath, RemoteFileLoaderState.Success);
                // 销毁
                ResetUnityWebRequest();
                // debug
                Debug.Log(string.Format("RemoteFileLoader.isReseted {0} , {1}", File.Exists(m_AssetPath).ToString(), m_AssetPath));

            }
        }
        // 下载时的各种异常情况
        public void OnDownloadException()
        {
            loadStatus = ELoadStatus.LoadError;
            Debug.LogError(string.Format("{0},url = {1},Progress = {2}", m_UnityWebRequest.error, m_url, m_Progress));

            // 下载错误更新进度
            progressHandler?.Invoke(m_AssetBundleName, 0, 0.0f);
            // 改在LoadFromRemote中重置-> ResetUnityWebRequest
            //m_UnityWebRequest = null;
            //切线
            SwitchLine();
            ExtendedTimeout();
            LoadFromRemote();
        }

        private bool TryGetTotalUrl(out string url)
        {
            if (m_SwitchCount < m_TotalSwitchCount)
            {
                url = string.Format("{0}{1}", m_Urls[m_CurCDNUrlIndex], m_Suburl);
                return true;
            }
            else
            {
                url = string.Empty;
                return false;
            }
        }

        private void SwitchLine()
        {
            m_CurCDNUrlIndex++;
            m_SwitchCount++;
            m_CurCDNUrlIndex = m_CurCDNUrlIndex % m_TotalSwitchCount;
            int line = m_CurCDNUrlIndex + 1;
            Debug.LogError("CDN Switch to line: " + line);
        }

        private void ExtendedTimeout()
        {
            m_Timeout = (int)Mathf.Ceil(m_Timeout * TIMEOUT_ADD_RATE);
        }
        
        public override void AddMask(ulong mask)
        {
            base.AddMask(mask);
        }

        public override void RemoveMask(ulong mask)
        {
            base.RemoveMask(mask);
        }

        public override float Unload()
        {
            base.Unload();

            //m_UnityWebRequest = null;
            // 重置UnityWebRequest
            ResetUnityWebRequest();
            m_AssetBundleName = string.Empty;
            return 0;
        }

        public void ResetUnityWebRequest()
        {
            if(m_UnityWebRequest != null)
            {
                m_UnityWebRequest.Abort();
                m_UnityWebRequest.Dispose();
                m_UnityWebRequest = null;
            }
        }

        public void ResetTimeoutCalculator()
        {
            // 重置超时计时器
            m_SwitchTs = (int)Time.time;
            m_DownloadBytes = 0;
            m_DownloadProgress = 0.0f;
        }

        public bool IsTimeout()
        {
            bool isTimeout = false;
            if (m_SwitchCount < m_TotalSwitchCount)
            {
                // 切线小于上限时(一般情况)
                int timeOnCheck = TIMEOUT_PROTOCOL[TIMEOUT_PROTOCOL.Length - 1];// 预防传入的线路数大于约定的3线
                if (m_SwitchCount < TIMEOUT_PROTOCOL.Length) timeOnCheck = TIMEOUT_PROTOCOL[m_SwitchCount];
                // 是否到时需要检测下载进度
                if (m_SwitchTs + timeOnCheck < (int)Time.time)
                {
                    var downloadBytes = m_UnityWebRequest.downloadedBytes;
                    var downloadProgress = m_UnityWebRequest.downloadProgress;
                    var isTimeoutBytes = downloadBytes - m_DownloadBytes < RemoteDownloadConfig.DownloadBytesMinPerCheck;
                    //var isTimeoutProgress = downloadProgress - m_DownloadProgress < MIN_PROGRESS_FOR_TIMEOUT;
                    //isTimeout = isTimeoutBytes && isTimeoutProgress;
                    isTimeout = isTimeoutBytes;// 暂时不使用progress判定
                    // 测试log begin
                    //Debug.Log(string.Format("RemoteFileLoader.isTimeout {0} , file:{1} , m_DownloadBytes:{2} , downloadBytes:{3} , m_DownloadProgress:{4} , downloadProgress:{5} ",
                    //    isTimeout.ToString(),
                    //    m_AssetBundleName,
                    //    m_DownloadBytes,
                    //    downloadBytes,
                    //    m_DownloadProgress,
                    //    downloadProgress));
                    // 测试log end
                    if (!isTimeout)
                    {
                        // 下载进度正常 更新变量
                        m_DownloadBytes = downloadBytes;
                        m_DownloadProgress = downloadProgress;
                        m_SwitchTs = (int)Time.time;
                    }
                }
                //else Debug.Log("未到检测时间");

                // 测速(每秒测一次)
                if(m_SpeedCacheTs < (int)Time.time)
                {
                    m_SpeedCacheTs = (int)Time.time;
                    // 更新进度
                    progressHandler?.Invoke(m_AssetBundleName, m_UnityWebRequest.downloadedBytes, m_UnityWebRequest.downloadProgress);
                }
                if(!m_WillRelocate)
                {
                    // 文件列表 每帧更新
                    progressHandler?.Invoke(m_AssetBundleName, m_UnityWebRequest.downloadedBytes, m_UnityWebRequest.downloadProgress);
                }
            }
            else
            {
                // 切线次数已超
                isTimeout = true;
            }
            return isTimeout;
        }

        // 调试接口
        public UnityWebRequest GetUnityWebRequestForTest()
        {
            return m_UnityWebRequest;
        }
    }

}