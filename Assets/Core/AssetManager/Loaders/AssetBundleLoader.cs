using System;
using System.Collections;
using UnityEngine;
using UnityEngine.Networking;

namespace Core.Load
{
    public class AssetBundleLoader : BaseLoader
    {
        private string m_Version;
        private string m_AssetBundleName;
        private AssetBundle m_AssetBundle;
        private bool m_IsUnloadForce = true;
        private int m_AssetBundleRefCount = 0;
        private AssetBundleInfoConfig m_Config;
        private AssetBundleCreateRequest m_AssetBundleCreateRequest;

        public AssetBundleLoader(string key, AssetBundleInfoConfig config)
        {
            m_Key = key;
            m_Progress = 0;
            m_Config = config;
            m_LoadType = config.LoadType;
            m_Version = config.Version;
            m_AssetBundleRefCount = 0;
            m_AssetBundleName = config.AssetBundleName;
            loadStatus = ELoadStatus.Waiting;
        }

        public override void AddMask(ulong mask)
        {
            base.AddMask(mask);
        }

        public override void RemoveMask(ulong mask)
        {
            base.RemoveMask(mask);
        }
        public bool IsUnloadForce { get => m_IsUnloadForce;}
        public override string assetPath
        {
            get
            {
                return m_AssetBundleName;
            } 
        }

        public AssetBundle assetBundle
        {
            get
            {
                return m_AssetBundle;
            }
        }

        private string BundleFullPath
        {
            get
            {
                if (string.IsNullOrEmpty(m_AssetBundleName))
                {
                    Debug.LogError("m_AssetBundleName is null, " + m_Key);
                    loadStatus = ELoadStatus.LoadError;
                }
                return LoadUtility.instance.GetAssetBundlePath(m_AssetBundleName, m_LoadType, m_Version);
            }

        }
   
        public override void  LoadAsync()
        {
            loadStatus = ELoadStatus.Loading;
            m_AssetBundleCreateRequest = AssetBundle.LoadFromFileAsync(BundleFullPath);

            if (m_AssetBundleCreateRequest == null)
            {
                loadStatus = ELoadStatus.LoadError;
                EnqueueLoadResult();
            }
        }

        public override void OnUpdate()
        {
            if (m_AssetBundleCreateRequest != null)
            {
                OnUpdateCreateRequest();
            }
        }

        private void OnUpdateCreateRequest()
        {
            m_Progress = m_AssetBundleCreateRequest.progress;

            if (m_AssetBundleCreateRequest.isDone)
            {
                m_Progress = 1;
                loadStatus = ELoadStatus.Loaded;
                m_AssetBundle = m_AssetBundleCreateRequest.assetBundle;
                m_AssetBundleCreateRequest = null;
                EnqueueLoadResult();
            }
        }

        void EnqueueLoadResult()
        {
#if DEBUG
            LoaderProfiler.Instance.EnqueueAssetLife(m_RefMask,key,
                LoaderProfiler.PointType.LoadedAb,string.Format("{0}_{1}",loadSign, loadStatus));
#endif
        }

        public void SetMask(ulong mask, int refCount)
        {
            if (mask == 0)
            {
                // Debug.LogErrorFormat("Add Mask 0 :{0}!", IdentityKey());
                return;
            }

            bool isEffect = false;
            ulong tmpMask = mask;
            if (LoadMask.HasMask(mask, LoadMask.REFCOUNT))
            {
                m_RefCount += refCount;
                m_RefMask |= LoadMask.REFCOUNT;
                LoadMask.UnLoadMask(ref mask, LoadMask.REFCOUNT);
                isEffect = true;
            }

            if (mask != 0 && !LoadMask.HasMask(m_RefMask, mask))
            {
                m_RefMask |= mask;
                isEffect = true;
            }

            if (isEffect)
            {
#if DEBUG
                LoaderProfiler.Instance.EnqueueAssetLife(m_RefMask, key, LoaderProfiler.PointType.SetABLoaderMask,
                    string.Format("[setABLoaderMask] mask:{0}, curr refcount:{1}, id:{2}", tmpMask, m_RefCount, IdentityKey()));
#endif
            }
        }

        public float BuildSize()
        {
            return m_Config != null ? m_Config.BundleSize : 0;
        }

        public override string IdentityKey()
        {
#if DEBUG
            return string.Format("{0}, size: {1}",base.IdentityKey(), BuildSize());
#else
            return string.Empty;
#endif            
        }

        public override bool IsValid()
        {
            //if return false then unload

            if(loadStatus == ELoadStatus.Loading)
            {
                return true;
            }

            return m_AssetBundleRefCount > 0;
        }

        public void Plus_AB_RefCount()
        {
            m_AssetBundleRefCount ++;    
        }

        public void Minus_AB_RefCount()
        {
            m_AssetBundleRefCount --;
        }

        public override float Unload()
        {
#if DEBUG
                LoaderProfiler.Instance.EnqueueAssetLife(m_RefMask, key, LoaderProfiler.PointType.UnLoadLoader,IdentityKey());
                LoaderProfiler.Instance.EnqueueAssetLife(m_RefMask, key,
                LoaderProfiler.PointType.UnLoadAssetAb,string.Format("{0} unload({1})",IdentityKey(),m_IsUnloadForce));
#endif
           
            base.Unload();
            float unloadSize = 0f;
            
            if (m_AssetBundle != null)
            {
                m_AssetBundle.Unload(true);
                m_AssetBundle = null;
            }

            m_AssetBundleRefCount = 0;
            m_Version = string.Empty;
            m_AssetBundleName = string.Empty;
            m_AssetBundleCreateRequest = null;
            
            return unloadSize;
        }

    }
}

