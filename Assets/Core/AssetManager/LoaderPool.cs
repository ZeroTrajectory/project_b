using System;
using System.Collections.Generic;
using UnityEngine;

namespace Core.Load
{
    public class LoaderPool : MonoBehaviour
    {
        private static LoaderPool _instance;
        public static LoaderPool instance
        {
            get
            {
                return _instance;
            }
        }

        private void Awake()
        {
            _instance = this;
        }

        private void OnDestroy()
        {
            Cleanup();
            _instance = null;
        }

        [SerializeField]
        public bool enableEditorDelayLoad = false;
        [SerializeField]
        public bool enableCollectUseAsset = false;
        [SerializeField]
        public bool useAssetBundle = false;

        private ILoader m_TempLoader;
        private float m_UploadSize = 0f;
        //50M ,清理一次
        public const float MAX_CLEAN_MEMORY = 100000f;
        private const int MAX_WHILE_ERROR_COUNT = 100000;
        private LinkedList<ILoader> m_Loaders = new LinkedList<ILoader>();
        private List<ILoader> m_AutoMaskLoaderList = new List<ILoader>(20);
        public int syncLoadCount = 5;
        public void Add(ILoader loader)
        {
            if (loader == null || string.IsNullOrEmpty(loader.key))
            {
                Debug.LogError("loader is  invalid");
                return;
            }
           //TODO @chenjie 此处有优化空间，暂时这样写了
            LinkedListNode<ILoader> node = m_Loaders.Find(loader);
            if ( node != null)
            {
                node.Value = loader;
            }
            else
            {
                m_Loaders.AddFirst(loader);
                LoaderProfiler.Instance.EnqueueLoaderListOpt(loader.key,LoaderProfiler.ELoaderListTrack.FirstAdd);
            }
        }
        
        public void Unload(ulong mask)
        {
            foreach (ILoader loader in m_Loaders)
            {
                if (loader.loadSign == "AssetLoader")
                {
                    (loader as AssetLoader).RemoveCallBack(mask);
                }
                    
                loader.RemoveMask(mask);
            }
            LoaderProfiler.Instance.EnqueueLoaderListOpt(LOADER_PROFILER_KEY,
                LoaderProfiler.ELoaderListTrack.UnloadMask,string.Format("mask:{0}",mask));
            LoadMask.DeallocMask(mask);
        }

        void UnloadMask(ILoader loader, ulong mask)
        {
            if(loader == null)
                return;
            loader.RemoveMask(mask);
            bool hasMask = false;
            foreach (ILoader ll in m_Loaders)
            {
                hasMask |= LoadMask.HasMask(ll.refMask, mask);
                if(hasMask)
                    break;
            }
            if(!hasMask)
                LoadMask.DeallocMask(mask);
        }

        private void UnLoadILoader(ILoader iLoader,string opt = "")
        {
            if (iLoader == null)
                return;
            LoaderProfiler.Instance.EnqueueAssetLife(iLoader.refMask,iLoader.key,
                LoaderProfiler.PointType.UnLoadAsset,opt);
            LoaderProfiler.Instance.EnqueueLoaderListOpt(iLoader.key,LoaderProfiler.ELoaderListTrack.AskDelete,opt);
            m_UploadSize += iLoader.Unload();            
        }

        public void Unload(string assetPath, ulong mask, string callbackId = null)
        {
            if (string.IsNullOrEmpty(assetPath))
                return;
            
            foreach ( ILoader loader in m_Loaders)
            {
                if (loader.loadStatus != ELoadStatus.WaitDelete )
                {
                    if (loader.loadSign == "AssetLoader" && loader.assetPath == assetPath)
                    {
                        (loader as AssetLoader).RemoveCallBack(mask, callbackId);
                    }

                    if (loader.assetPath == assetPath)
                    {
                        UnloadMask(loader, mask);
                    }
                }
            }
            LoaderProfiler.Instance.EnqueueLoaderListOpt(LOADER_PROFILER_KEY,
                LoaderProfiler.ELoaderListTrack.UnloadAssetPath,string.Format("mask:{0}, assetpath:{1}",mask,assetPath));
        }

        void DeleteILoader(LinkedListNode<ILoader> node)
        {
            ILoader loader = node.Value;
            if (loader != null)
            {
                loader.OnDestroy();
            }
            m_Loaders.Remove(node);
            LoaderProfiler.Instance.EnqueueLoaderListOpt(loader.key,LoaderProfiler.ELoaderListTrack.DoDelete);
        }

        public T GetLoader<T>(string key) where T : ILoader
        {
            
            if (string.IsNullOrEmpty(key))
            {
                return default(T);
            }
            
            ILoader loader = default(T);
            LinkedListNode<ILoader> node = m_Loaders.Last;
            try
            {
                int errorIndex = MAX_WHILE_ERROR_COUNT;
                while (node!=null)
                {
                    ILoader ll = node.Value;
                    if (ll != null && ll.key == key&& ll.GetType().Equals(typeof(T)))
                    {
                        loader = ll;
                        if (loader.loadStatus == ELoadStatus.WaitDelete)
                        {
                            DeleteILoader(node);
                            loader = default(T);
                        }
                        break;
                    }
                    node = node.Previous;
                    if (errorIndex-- < 0)
                    {
                        Debug.LogError("GetLoader while 死循环");
                        break;
                    }
                }
            }
            catch (Exception e)
            {
               Debug.LogException(e);
            }
            LoaderProfiler.Instance.EnqueueLoaderListOpt(key,LoaderProfiler.ELoaderListTrack.Get);
            return (T)loader;
        }

        public void OnUpdate()
        {
            try
            {
                LinkedListNode<ILoader> node = m_Loaders.Last;
                int errorIndex = MAX_WHILE_ERROR_COUNT;
                while  (node != null)
                {
                    ILoader loader = node.Value;
                    if (loader == null)
                    {
                        continue;
                    }

                    LinkedListNode<ILoader> curr = node;
                    node = node.Previous;  //注意，此处有顺序问题，一定要在updateloader之前执行，因为updateloader的时候，会有remove操作
                    UpdateILoader(curr);
                    if (errorIndex-- < 0)
                    {
                        Debug.LogError("Loader Pool OnUpdate while 死循环");
                        break;
                    }
                }
            }
            catch (Exception e)
            {
               Debug.LogException(e);
            }
            UpdateAutoMaskLoader();
            
            if (m_UploadSize >= MAX_CLEAN_MEMORY)
            {
                Debug.LogWarning("LoaderPool GC m_UploadSize=" + m_UploadSize);
                GCCollect();
            }
        }

        void UpdateILoader(LinkedListNode<ILoader> curr)
        {
            ILoader loader = curr.Value;
            bool isMaskZero = CheckLoaderMaskZero(loader);
            switch (loader.loadStatus)
            {
                case ELoadStatus.Waiting:
                    loader.LoadAsync();  //TODO @chenjie 此处应该有并发数限制
                    break;
                case ELoadStatus.Loading:
                    loader.OnUpdate();
                    break;
                case ELoadStatus.LoadError:
                    if (loader.refMask != 0)
                        UnloadMask(loader, loader.refMask);
                    break;
                case ELoadStatus.WaitDelete:
                    DeleteILoader(curr);
                    LoaderProfiler.Instance.EnqueueAssetLife(loader.refMask,loader.key, LoaderProfiler.PointType.RemoveLoader);
                    break;
                case ELoadStatus.Loaded:
                    loader.OnUpdate();
                    break;
            }

            if (!isMaskZero)
            {
                CheckLoaderMaskZero(loader);
            }
        }

        bool CheckLoaderMaskZero(ILoader loader)
        {
            if (loader.IsValid())
                return false;

            if (loader.loadStatus == ELoadStatus.WaitDelete)
                return false;

            if (loader.loadStatus == ELoadStatus.Deleted)
                return false;

            AssetBundleLoader abLoader = loader as AssetBundleLoader;
            if (abLoader != null && !abLoader.IsUnloadForce)
            {
                if (m_AutoMaskLoaderSize>0&&!m_AutoMaskLoaderList.Contains(loader))
                {
                    m_AutoMaskLoaderList.Add(loader);
                }
            }
            else
            {
                UnLoadILoader(loader,"CheckLoaderMaskZero");
            }

            return true;
        }

        void UpdateAutoMaskLoader()
        {
            for (int i = m_AutoMaskLoaderList.Count-1; i >=0; i--)
            {
                ILoader item = m_AutoMaskLoaderList[i];
                if (item.refMask != 0)
                {
                    m_AutoMaskLoaderList.Remove(item);
                }
            }

            int needDelete = Mathf.Clamp(m_AutoMaskLoaderList.Count - m_AutoMaskLoaderSize, 0,
                m_AutoMaskLoaderList.Count);
            for (int i = needDelete-1; i>=0; i--)
            {
                ILoader item = m_AutoMaskLoaderList[i];
                LoaderProfiler.Instance.EnqueueAssetLife(item.refMask,item.key,LoaderProfiler.PointType.UnloadAutoMask);
                UnLoadILoader(m_AutoMaskLoaderList[i],"UpdateAutoMaskLoader");
                m_AutoMaskLoaderList.Remove(item);
                
            }

        }

        public void ClearAutoMaskLoaderList()
        {
            var oldSize = m_AutoMaskLoaderSize;
            m_AutoMaskLoaderSize = 0;
            UpdateAutoMaskLoader();
            m_AutoMaskLoaderSize = oldSize;
        }

        private int m_AutoMaskLoaderSize = 0;

        public System.Action luaGC;
        public void LuaGC()
        {
            try
            {
                if (luaGC != null)
                {
                    luaGC();
                }
            }
            catch (Exception e)
            {
                Debug.LogException(e);
            }
        }

        private const string LOADER_PROFILER_KEY = "LoaderPool";
        public void GCCollect()
        {
            Debug.Log("LoaderPool GCCollect:"+m_UploadSize);
            LoaderProfiler.Instance.EnqueueLoaderListOpt(LOADER_PROFILER_KEY, LoaderProfiler.ELoaderListTrack.Gc,string.Format("释放ab的内存大小:{0}",m_UploadSize));
            m_UploadSize = 0;
            Resources.UnloadUnusedAssets();
            LuaGC();
            System.GC.Collect();
            System.GC.WaitForPendingFinalizers();
        }

        public void Cleanup()
        {
            LinkedListNode<ILoader> node = m_Loaders.Last;
            int errorIndex = MAX_WHILE_ERROR_COUNT;
            while (node!=null)
            {
                ILoader loader = node.Value;
                if(loader == null)
                    continue;
                loader.Unload();
                node = node.Previous;
                if (errorIndex-- < 0)
                {
                    Debug.LogError("LoaderPool Cleanup while 死循环");
                    break;
                }
            }
            m_Loaders.Clear();
            //LoadMask.ResetMask();
            LoaderProfiler.Instance.EnqueueLoaderListOpt(LOADER_PROFILER_KEY, LoaderProfiler.ELoaderListTrack.CleanUp);
            m_AutoMaskLoaderList.Clear();
            GCCollect();
        }

        #region Debug

        public ILoader GetNextAutoMaskLoader(int index)
        {
            return index < m_AutoMaskLoaderList.Count ? m_AutoMaskLoaderList[index] : null;
        }

        public void TryGetLastLoader(ref LinkedListNode<ILoader> node)
        {
            if (node == null)
            {
                node = m_Loaders.Last;
            }
            else
            {
                node = node.Previous;
            }
        }

        public int AutoMaskLoaderCount
        {
            get { return m_AutoMaskLoaderList.Count; }
        }

        public int LoadersCount
        {
            get { return m_Loaders.Count; }
        }

        #endregion
    }
}