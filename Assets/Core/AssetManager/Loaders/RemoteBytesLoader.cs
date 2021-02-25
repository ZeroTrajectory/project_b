using System;
using System.IO;
using UnityEngine;
using UnityEngine.Networking;

namespace Core.Load
{
    public class RemoteBytesLoader : BaseLoader
    {
        private byte[] m_bytes;
        private string m_url;
        private string m_AssetBundleName;
        private UnityWebRequest m_UnityWebRequest;
        private Action<string,byte[]> m_CallbackBytes;
     
        private string m_Version;
        private string[] m_Urls;
        private string m_Suburl;
        private int m_TotalSwitchCount = 0;//线路总数
        private int m_SwitchCount = 0;//已切次数
        static int m_CurCDNUrlIndex = 0;//当前线路，每次下载不重置
        public RemoteBytesLoader(string key,string assetBundleName,string version,string[] urls,string suburl)
        {
            m_Progress          = 0;
            m_Key               = key;
            loadStatus        = ELoadStatus.Waiting;
            m_AssetBundleName   = assetBundleName;
            m_Version = version;
            m_Urls = urls;
            m_Suburl = suburl;
            m_TotalSwitchCount = urls.Length;
            m_SwitchCount = 0;
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

        public void SetCallback(Action<string,byte[]> callBack)
        {
            if(loadStatus == ELoadStatus.Loaded)
            {
                callBack(m_AssetBundleName,m_bytes);
            }
            else
            {
                m_CallbackBytes = callBack;
            }
        }
        
        private void LoadFromRemote()
        {
            loadStatus = ELoadStatus.Loading;
            // url/Assets/2/1.0.0.1/AssetBundle/assetlist,Progress = 1
            //m_url = string.Format("{0}/{1}/AssetBundle/{2}",LoadUtility.instance.CDNServerURL,m_Version,m_AssetBundleName);
            // m_url = LoadUtility.instance.GetRemoteUrl(m_AssetBundleName,m_Version,m_CDNUrlIndex);
            if(!TryGetTotalUrl(out m_url))
            {
                Debug.LogError("All lines have been tried! ");
                m_CallbackBytes(m_AssetBundleName,null);
                return;
            }
            
            Debug.Log(m_url);

            m_UnityWebRequest = UnityWebRequest.Get(m_url);
            m_UnityWebRequest.SendWebRequest();
        }

        public override void OnUpdate()
        {
            if(m_UnityWebRequest != null)
            {
                OnUpdateUnityWebRequest();
            }
        }

        private void OnUpdateUnityWebRequest()
        {
            m_Progress = m_UnityWebRequest.downloadProgress;

            if(m_UnityWebRequest == null)
            {
                return;
            }

            if(m_UnityWebRequest.isHttpError || m_UnityWebRequest.isNetworkError)
            {
                loadStatus = ELoadStatus.LoadError;
                Debug.LogError(string.Format("{0},url = {1},Progress = {2}",m_UnityWebRequest.error,m_url,m_Progress));
                m_UnityWebRequest = null;

                //切线
                SwitchLine();

                LoadFromRemote();

                return;
            }

            if(m_UnityWebRequest.downloadHandler.isDone)
            {
                m_bytes = m_UnityWebRequest.downloadHandler.data;
                loadStatus = ELoadStatus.Loaded;
                m_UnityWebRequest = null;
                m_Progress = 1;
                
                if(m_CallbackBytes != null)
                {
                    m_CallbackBytes(m_AssetBundleName,m_bytes);
                }

               //disposeDownloadHandlerOnDispose == true,则不需要主动Dipose;
               //disposeDownloadHandlerOnDispose的默认值为true;
               // 1.If disposeDownloadHandlerOnDispose true, any DownloadHandler attached to this UnityWebRequest will have DownloadHandler.
               //   Dispose called automatically when UnityWebRequest.Dispose is called.
               // 2.disposeDownloadHandlerOnDispose Default: true.
            }    
        }

        private bool TryGetTotalUrl(out string url)
        {
            if(m_SwitchCount < m_TotalSwitchCount)
            {
                url = string.Format("{0}{1}",m_Urls[m_CurCDNUrlIndex],m_Suburl);
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

        public override float Unload()
        {
            base.Unload();
            m_UnityWebRequest = null; 
            m_AssetBundleName = string.Empty;  
            return 0;
        }
       
    }
    
}