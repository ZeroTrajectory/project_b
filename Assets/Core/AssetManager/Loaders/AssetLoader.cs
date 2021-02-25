using System;
using System.Collections.Generic;
using Core.Load;
using UnityEngine;
using Object = UnityEngine.Object;

namespace Core.Load
{
    public class AssetData
    {
        public ulong mask;
        public object userData;
        public LoadAssetCallbacks loadAssetCallbacks;
    }

    public class AssetLoader : BaseLoader
    {
        private Type m_Type;
        private UnityEngine.Object m_Asset;
        private ELoadModel m_LoadModel = ELoadModel.AssetBundle;
        private List<AssetData> m_CallBackList = new List<AssetData>();
        private bool m_ShowErrorLog;
        public UnityEngine.Object asset
        {
            get
            {
                return m_Asset;
            }
        }

        private ILoaderAgent m_LoaderAgent;
        
        public AssetLoader(string assetPath,Type assetType, int priority, object userData, bool showErrorLog = true)
        {
            m_CallBackList.Clear();
            m_AssetPath = assetPath;
            m_Key = LoadUtility.instance.GenAssetkey(assetPath);
            m_LoadModel = LoadUtility.instance.GetLoadModelAndLoadAgent(out m_LoaderAgent);
            m_ShowErrorLog = showErrorLog;
            m_Type = assetType;
            loadStatus = ELoadStatus.Waiting;
        }

        public override void LoadAsync()
        {
            base.LoadAsync();
            m_LoaderAgent.UpdateMask(refMask);
            m_LoaderAgent.StartLoad(key,m_AssetPath, m_Type, OnLoad);
        }

        void OnLoad(Object asset, string errorMsg)
        {
            if (asset == null)
            {
                LoadError(errorMsg);
            }
            else
            {
                m_Asset = asset;
                LoadSuccess();
            }
        }

        public override bool IsValid()
        {
            if(loadStatus == ELoadStatus.Loading)
            {
                return true;
            }
           
            return base.IsValid();
        }

        public override void AddMask(ulong mask)
        {
            base.AddMask(mask);
            m_LoaderAgent.AddMask(mask);
        }

        public override void RemoveMask(ulong mask)
        {
            base.RemoveMask(mask);
            m_LoaderAgent.RemoveMask(mask);
        }

        public void RemoveCallBack(ulong mask, string callbackId = null)
        {
            for(int i = m_CallBackList.Count - 1;i >= 0; i--)
            {
                if(callbackId!=null)
                {
                    if(m_CallBackList[i].loadAssetCallbacks.Id == callbackId)
                    {
                        m_CallBackList.RemoveAt(i);
                    }
                }
                else if(m_CallBackList[i].mask == mask)
                {
                    m_CallBackList.RemoveAt(i);
                }
            }
            
        }

        public void SetCallback(LoadAssetCallbacks loadAssetCallbacks, object userData, ulong mask)
        {
            if(loadAssetCallbacks == null)
                return;
            AssetData data = m_CallBackList.Find(x =>
            {
               return x.loadAssetCallbacks.Id == loadAssetCallbacks.Id;
            });
            if (data != null)
            {
                data.mask |= m_RefMask;
                if (data.userData != userData)
                    data.userData = userData;
                return;
            }
            data = new AssetData();
            data.mask = mask;
            data.userData = userData;
            data.loadAssetCallbacks = loadAssetCallbacks;
            m_CallBackList.Add(data);
            LoaderProfiler.Instance.EnqueueAssetLife(refMask,key,LoaderProfiler.PointType.AddAssetLoadCb,loadAssetCallbacks.Id.ToString());
        }

        public override void OnUpdate()
        {
            m_LoaderAgent.OnUpdate();
        }

        private void LoadError(string errorMessage)
        {
            loadStatus = ELoadStatus.LoadError;
            CallBack(false,errorMessage);
            m_CallBackList.Clear();
            if(m_ShowErrorLog)
                Debug.LogError(errorMessage);
        }

        private void LoadSuccess()
        {
            loadStatus = ELoadStatus.Loaded;
            CallBack(true);
            m_CallBackList.Clear();
        }

        private void CallBack(bool isSuccess, string errorMsg="")
        {
            try
            {
                int index = 0;
                AssetData assetData = GetNextCallback(index++);
                while (assetData!=null)
                {
                    if(assetData.loadAssetCallbacks == null || assetData.loadAssetCallbacks.LoadAssetSuccessCallback == null)
                    {
                        continue;
                    }
                    LoaderProfiler.Instance.EnqueueAssetLife(refMask,key, LoaderProfiler.PointType.ReturnAsset,
                        string.Format("return asset:{0}, isSuccess:{1}",assetData.loadAssetCallbacks.Id,isSuccess));
                    if (isSuccess)
                    {
                        if (assetData.loadAssetCallbacks.LoadAssetSuccessCallback != null)
                        {
                            assetData.loadAssetCallbacks.LoadAssetSuccessCallback(m_AssetPath, m_Asset,  assetData.userData);
                        }
                    }
                    else
                    {
                        if (assetData.loadAssetCallbacks.LoadAssetFailureCallback != null)
                        {
                            assetData.loadAssetCallbacks.LoadAssetFailureCallback(m_AssetPath, 
                                errorMsg, assetData.userData);
                        }
                    }

                    assetData = GetNextCallback(index++);
                }
            }
            catch (Exception e)
            {
                Debug.LogErrorFormat("{0}, {1}, {2} , {3}", assetPath, m_CallBackList.Count, Time.frameCount, Time.realtimeSinceStartup);
                Debug.LogException(e);
            }
        }

        AssetData GetNextCallback(int index)
        {
            return index < m_CallBackList.Count ? m_CallBackList[index] : null;
        }

        public override float Unload()
        {
            LoaderProfiler.Instance.EnqueueAssetLife(m_RefMask, key,LoaderProfiler.PointType.UnLoadLoader,IdentityKey());
            base.Unload();
            m_Type = null;
            m_Asset = null;
            m_CallBackList.Clear();
            m_LoadModel = ELoadModel.AssetBundle;
            m_LoaderAgent.UnLoad();
            return 0;
        }
    }
}















