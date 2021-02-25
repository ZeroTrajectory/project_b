using System;
using Core.Load;
using UnityEngine;

namespace Core.Load
{
    public class BaseLoader : ILoader
    {
        //外面控制
        protected ulong m_RefMask;
        protected float m_Progress = 0;
        protected string m_Key = string.Empty;
        protected string m_LoadSign = string.Empty;
        protected string m_AssetPath = string.Empty;
        private ELoadStatus m_LoadStatus = ELoadStatus.Waiting;
        protected ELoadType m_LoadType = ELoadType.StreamingAssets;
        private const string IDENTITY = "BaseLoader";
        protected int m_RefCount;

        public int RefCount => m_RefCount;

        public string key 
        {
            get
            {
                return m_Key;
            }
        }

        public ELoadStatus loadStatus 
        {
            get
            {
                return m_LoadStatus;
            }
            protected set
            {
#if DEBUG
                    LoaderProfiler.Instance.EnqueueLoaderStatus(assetPath,value,m_RefMask,m_LoadStatus.ToString(),IdentityKey());
#endif            
                m_LoadStatus = value;
                
            }
        }
        
        public float progress 
        {
            get
            {
                return m_Progress;
            }
        }
        public string loadSign
        {
            get
            {
                return string.IsNullOrEmpty(m_LoadSign) ? this.GetType().Name:m_LoadSign;
            }    
        }

        public ulong refMask
        {
            get
            {
                return m_RefMask;
            }
        }
      
        public bool isDone
        {
            get
            {
                return  m_LoadStatus == ELoadStatus.Loaded || m_LoadStatus == ELoadStatus.LoadError;
            }
        }

        public virtual string assetPath
        {
            get
            {
                return m_AssetPath;
            } 
        }

        public virtual string name{ get; }

        public virtual bool IsValid()
        {
            return m_RefMask != 0 || RefCount > 0;
        }

        public virtual void OnUpdate()
        {
            
        }

        public virtual void AddMask(ulong mask)
        {
            if (mask == 0)
            {
                Debug.LogErrorFormat("Add Mask 0 :{0}!",IdentityKey());
                return;
            }

            bool isEffect = false;
            ulong tmpMask = mask;
            if (LoadMask.HasMask(mask, LoadMask.REFCOUNT))
            {
                m_RefCount++;
                m_RefMask |= LoadMask.REFCOUNT;
                LoadMask.UnLoadMask(ref  mask, LoadMask.REFCOUNT);
                isEffect = true;
            }
            
            if (mask!=0 && !LoadMask.HasMask(m_RefMask, mask))
            {
                m_RefMask |= mask;
                isEffect = true;
            }

            if (isEffect)
            {
                EnqueueMaskProfiler(true, tmpMask);
            }
        }

        void EnqueueMaskProfiler(bool isAdd, ulong mask)
        {
#if DEBUG
            string prefix = isAdd ? "add" : "remove";
            LoaderProfiler.PointType pointType =
                isAdd ? LoaderProfiler.PointType.AddLoaderMask : LoaderProfiler.PointType.RemoveLoaderMask;
            LoaderProfiler.Instance.EnqueueAssetLife(m_RefMask,key,
                pointType, string.Format("[{3}] mask:{0}, curr refcount:{1}, id:{2}",mask,m_RefCount,IdentityKey(),prefix));
#endif
        }

        public virtual void RemoveMask(ulong mask)
        {
            if (mask == 0)
            {
                Debug.LogErrorFormat("Remove Mask 0 :{0}!",IdentityKey());
                return;
            }

            bool isEffect = false;
            ulong tmpMask = mask;
            if (LoadMask.HasMask(mask, LoadMask.REFCOUNT))
            {
                m_RefCount--;
                if (m_RefCount == 0)
                {
                    m_RefMask &= ~LoadMask.REFCOUNT;
                }
                LoadMask.UnLoadMask(ref  mask, LoadMask.REFCOUNT);
                isEffect = true;
            }
            if (mask!=0 && LoadMask.HasMask(m_RefMask, mask))
            {
                m_RefMask &= ~mask;
                isEffect = true;
            }
            if (isEffect)
            {
                EnqueueMaskProfiler(false, tmpMask);
            }
        }

        public virtual float Unload()
        {  
            loadStatus = ELoadStatus.WaitDelete;
            m_Progress = 0;
            m_Key = string.Empty;
            m_LoadSign = string.Empty;
            m_AssetPath = string.Empty;
            m_LoadType = ELoadType.StreamingAssets;
            return 0;
        }

        public virtual string IdentityKey()
        {
            string identity = IDENTITY;

#if !DEBUG
                return identity;
#endif

            try
            {
                 identity = string.Format("assetpath:{0}, key:{4}, mask:{1}, sign:{2}, loadStatus:{3}, refCount:{5}",
                     assetPath,refMask, m_LoadSign, m_LoadStatus, key, RefCount);
            }
            catch (Exception e)
            {
                #if UNITY_EDITOR
                Debug.LogException(e);
                #endif
            }
            return identity;
        }

        public virtual void LoadAsync()
        {
            loadStatus = ELoadStatus.Loading;
        }

        public virtual void LoadAsync<T>() where T : UnityEngine.Object
        {
            loadStatus = ELoadStatus.Loading;
        }

        public virtual void OnDestroy()
        {
            loadStatus = ELoadStatus.Deleted;
        }
    }
}