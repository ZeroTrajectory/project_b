using System;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace Core.Load
{
    public class AssetManager : MonoBehaviour
    {
        private static AssetManager _instance;
        public static AssetManager instance
        {
            get
            {
                return _instance;
            }
        }

        private void Awake()
        {
            _instance = this;
            if (LoadUtility.instance == null)
                LoadUtility.SetInstance(new LoadUtility());
        }

        private void OnDestroy()
        {
            //_instance = null;
           // LoadUtility.SetInstance(null);
        }

        void Update()
        {
            LoaderPool.instance.OnUpdate();
        }

        private LoadUtility loadUtility
        {
            get
            {
                return LoadUtility.instance;
            }
        }

        /// <summary>
        /// load prefab
        /// </summary>
        /// <param name="assetPath"></param>
        /// <param name="assetType"></param>
        /// <param name="priority"></param>
        /// <param name="loadAssetCallbacks"></param>
        /// <param name="userData"></param>
        public void LoadAysnc(string assetPath, Type assetType, int priority, LoadAssetCallbacks loadAssetCallbacks,
            object userData, ulong mask , bool ShowErrorLog = true)
        {
            LoaderProfiler.Instance.RecordLoad(assetPath);
            string assetKey = LoadUtility.instance.GenAssetkey(assetPath);
            LoaderProfiler.Instance.EnqueueAssetLife(mask,assetKey,LoaderProfiler.PointType.AskLoadAsset);
            AssetLoader assetLoader = LoaderPool.instance.GetLoader<AssetLoader>(assetKey);

            if (assetLoader == null)
            {
                assetLoader = new AssetLoader(assetPath,assetType, priority, userData, ShowErrorLog);
                LoaderPool.instance.Add(assetLoader);
            }

            assetLoader.AddMask(mask);
            switch (assetLoader.loadStatus)
            {   
                case ELoadStatus.Waiting:
                case ELoadStatus.Loading:
                    assetLoader.SetCallback(loadAssetCallbacks, userData, mask);
                    break;
                case ELoadStatus.Loaded:
                case ELoadStatus.LoadError:
                    if (loadAssetCallbacks != null)
                    {
                        LoaderProfiler.Instance.EnqueueAssetLife(assetLoader.refMask,assetLoader.key, LoaderProfiler.PointType.ReturnAsset,
                            string.Format("return asset:{0}, isSuccess:{1}",loadAssetCallbacks.Id,assetLoader.asset!=null));
                        loadAssetCallbacks.LoadAssetSuccessCallback(assetLoader.assetPath, assetLoader.asset,
                            userData);
                    }

                    break;
            }

        }

        /// <summary>
        /// load sprite
        /// </summary>
        /// <param name="assetPath"></param>
        /// <param name="assetType"></param>
        /// <param name="loadAssetCallbacks"></param>
        /// <param name="userData"></param>
        public void LoadAysnc(string assetPath, Type assetType, LoadAssetCallbacks loadAssetCallbacks, ulong mask, object userData = null, bool ShowErrorLog = true)
        {
            LoadAysnc(assetPath, assetType, 0, loadAssetCallbacks, userData, mask, ShowErrorLog);
        }

        public void LoadAysnc4Lua(string assetPath, Type assetType, LoadAssetCallbacks loadAssetCallbacks)
        {
           // LoadAysnc(assetPath, assetType, 0, loadAssetCallbacks, null,LoadMask.AUTO);
            throw new NotImplementedException("涛哥说是一个测试接口，放个exception看看是不是真的");
        }

        /// <summary>
        /// 从远程下载，只需要byte[]，只为了写入存储
        /// </summary>
        /// <param name="assetPath"></param>
        /// <param name="callback"></param>
        public void LoadBytesAynsc(string abName, string version, string[] urls, string suburl,Action<string, byte[]> callback, ulong mask )
        {
            LoaderProfiler.Instance.EnqueueAssetLife(mask, abName, LoaderProfiler.PointType.AskLoadAb, "load bytes aynsc");
            RemoteBytesLoader loader = GetBytesLoader(abName, version, urls, suburl);

            switch (loader.loadStatus)
            {
                case ELoadStatus.Waiting:
                case ELoadStatus.LoadError:
                    loader.LoadAsync();
                    loader.SetCallback(callback);
                    break;
                case ELoadStatus.Loaded:
                    loader.SetCallback(callback);
                    break;
            }
        }

        private RemoteBytesLoader GetBytesLoader(string abName, string version, string[] urls, string suburl)
        {
            string depKey = LoadUtility.instance.GenByteskey(abName);
            RemoteBytesLoader loader = LoaderPool.instance.GetLoader<RemoteBytesLoader>(depKey);

            if (loader == null)
            {
                loader = new RemoteBytesLoader(depKey, abName, version, urls, suburl);
                LoaderPool.instance.Add(loader);
            }

            return loader;
        }
        public void DownLoadRemoteFileAynsc(RemoteFileLoaderData loaderData)
        {
            LoaderProfiler.Instance.EnqueueAssetLife(ulong.MinValue, loaderData.abName, LoaderProfiler.PointType.AskLoadAb, "DownLoadRemoteFileAynsc");
            RemoteFileLoader loader = GetFileLoader(loaderData);

            switch (loader.loadStatus)
            {
                case ELoadStatus.Waiting:
                case ELoadStatus.LoadError:
                    loader.SetCallback(loaderData.callback);
                    loader.LoadAsync();
                    break;
                case ELoadStatus.Loaded:
                    loader.SetCallback(loaderData.callback);
                    break;
                case ELoadStatus.Loading:
                    Debug.LogError("AssetManager.DownLoadRemoteFileAynsc->" + loaderData.abName);
                    break;
            }
        }

        private RemoteFileLoader GetFileLoader(RemoteFileLoaderData loaderData)
        {
            RemoteFileLoader loader = LoaderPool.instance.GetLoader<RemoteFileLoader>(loaderData.depKey);
            if (loader == null)
            {
                loader = new RemoteFileLoader(loaderData);
                LoaderPool.instance.Add(loader);
            }
            loader.AddMask(loaderData.mask);
            return loader;
        }

        public void Unload(ulong mask)
        {
            if(LoaderPool.instance == null)
            {
                return;
            }

            LoaderProfiler.Instance.EnqueueAssetLife(mask,"unload mask",LoaderProfiler.PointType.AskUnloadMask);
            if (mask != 0)
            {
                LoaderPool.instance.Unload(mask);
            }
        }

        public void Unload(string assetPath,ulong mask)
        {
            if(LoaderPool.instance == null)
            {
                return;
            }

            string assetKey = LoadUtility.instance.GenAssetkey(assetPath);
            LoaderProfiler.Instance.EnqueueAssetLife(mask,assetKey, LoaderProfiler.PointType.AskUnloadAsset,string.Format("unload assetpath:{0}, mask:{1}",assetPath,mask));
            LoaderPool.instance.Unload(assetPath,mask);
        }

        public void UnloadAssetLoader(string assetPath, ulong mask, string callbackId)
        {
            if(LoaderPool.instance == null)
            {
                return;
            }

            string assetKey = LoadUtility.instance.GenAssetkey(assetPath);
            LoaderProfiler.Instance.EnqueueAssetLife(mask, assetKey, LoaderProfiler.PointType.AskUnloadAsset, string.Format("unload assetpath:{0}, mask:{1}, callbackId:{2}",
                assetPath, mask, callbackId));
            LoaderPool.instance.Unload(assetPath, mask, callbackId);
        }
    }
}



















    // public string GetCriwareAssetPath(string name)
    //     {
// #if UNITY_EDITOR
//             if(LoaderPool.instance.enableCollectUseAsset)
//             {
//                 ResourceUseUtility.instance.AddResource(string.Format("Assets/GameMain/CriwareVideo/{0}.txt", name));
//             }
//             if (loadUtility.EditorResourceMode)
//             {
//                 return string.Format("{0}/GameMain/CriwareVideo/{1}.txt", Application.dataPath, name);
//             }
// #endif

//             string criPath = string.Empty;
//             if(GameEntry.BuiltinData.BuildInfo.useOBB)
//             {
//                 criPath = GetObbCriPath(name);
//             }
//             else
//             {
//                criPath = GetNormalCriPath(name);
//             }

//             return criPath;
           
        // }

        // private string GetObbCriPath(string name)
        // {
        //     //Path.Combine(GameEntry.BuiltinData.mountObbPath,"CriwareVideo",name);
        //     return string.Format("{0}/CriwareVideo/{1}.txt",GameEntry.BuiltinData.mountObbPath,name);
        // }

        // private string GetNormalCriPath(string name)
        // {
        //     string criPath = string.Empty;
        //     string simulateABName = string.Format("GameMain/CriwareVideo/{0}", name).ToLower();
        //     AssetBundleInfoConfig abInfoConf = LoadUtility.instance.GetABInfoConfigByABName(simulateABName);

        //     if (abInfoConf == null)
        //     {
        //         Debug.LogError(string.Format("can't find criware asset : {0}", name));
        //         return criPath;
        //     }

        //     ELoadType loadtype = abInfoConf.LoadType;
        //     switch (loadtype)
        //     {
        //         case ELoadType.Remote:
        //             criPath = LoadUtility.instance.GetCriwarePathFromStorage(name, abInfoConf.Version);
        //             break;
        //         default:
        //             criPath = LoadUtility.instance.GetCriwarePathFromStreamingAssets(name);
        //             break;
        //     }
        //     return criPath;
        // }

        // private ObbMounter m_ObbMounter;
        // public ObbMounter GetObbMounter
        // {
        //     get
        //     {
        //         if(m_ObbMounter == null)
        //         {
        //             m_ObbMounter = this.gameObject.GetComponent<ObbMounter>();
        //         }
                
        //         return m_ObbMounter;
        //     }
        // }
