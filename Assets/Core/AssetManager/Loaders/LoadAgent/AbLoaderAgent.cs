using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using Object = UnityEngine.Object;

namespace Core.Load
{
    public class AbLoaderAgent : ILoaderAgent
    {
        private AssetBundleRequest m_AssetBundleRequest;
        private string m_AssetPath;
        private Type m_AssetType;
        private Action<Object, string> m_OnLoad;
        private ulong m_Mask;
        private int m_RefCount = 0;
        private List<AssetBundleLoader> m_DependencyLoaders;
        private AssetBundleLoader m_MainAssetbundleLoader;
        private AssetConfig m_AssetConfig;
        private LoaderAgentState m_AgentState = LoaderAgentState.Wait;
        private string m_Key;
        private LoaderAgentState AgentState
        {
            get { return m_AgentState; }
            set
            {
                if (m_AgentState != value)
                {
                    m_AgentState = value;
                    OnStateChange();
                }
            }
        }

        public void StartLoad(string key,string assetPath, Type assetType, Action<Object, string> onLoad)
        {
            m_AssetPath = assetPath;
            m_AssetType = assetType;
            m_OnLoad = onLoad;
            m_Key = key;
            if (m_AssetType == null)
            {
                m_AssetType = typeof(UnityEngine.Object);
            }

           if(m_Mask == 0)
               return;
            if (AgentState == LoaderAgentState.Done)
            {
                return;
            }

            if (CheckAssetConfig())
            {
                AgentState = LoaderAgentState.LoadDependency;
            }
        }

        private bool CheckAssetConfig()
        {
            m_AssetConfig = LoadUtility.instance.GetAssetConfig(m_AssetPath);
            if (m_AssetConfig == null)
            {
                string errorMsg = string.Format("m_AssetConfig == null, asset name = {0} ", m_AssetPath);
                OnAssetLoaded(null, errorMsg);
                return false;
            }
            return true;
        }

        private void LoadDependencies()
        {
            string[] dependencies = null;
            m_DependencyLoaders = TryStartDependenceLoader(m_AssetConfig, m_Mask,out dependencies);
            DependLoaderReferer(true);
            string depStrings = dependencies == null || dependencies.Length == 0
                ? "No Dependency"
                : string.Join("\r\n -- ", dependencies);
            LoaderProfiler.Instance.EnqueueAssetLife(m_Mask,m_Key, LoaderProfiler.PointType.AskLoadAbDependency, 
                string.Format("dependency count:{0}, depString:{1}",m_DependencyLoaders.Count.ToString(), depStrings));
        }

        void OnLoadDependenciesUpdate()
        {
            bool isDone = true;
            for (int i = 0; i < m_DependencyLoaders.Count; i++)
            {
                isDone &= m_DependencyLoaders[i].isDone;
            }

            if (isDone)
            {
                LoaderProfiler.Instance.EnqueueAssetLife(m_Mask,m_Key,LoaderProfiler.PointType.LoadedAbDependency);
                AgentState = LoaderAgentState.LoadAssetAb;
            }
        }

        void LoadAssetAb()
        {
            string assetBundleName = m_AssetConfig.AssetBundleName;
            AssetBundleInfoConfig abInfoConfig = LoadUtility.instance.GetABInfoConfigByABName(assetBundleName);
            m_MainAssetbundleLoader = TryStartAssetBundleLoader(abInfoConfig, m_Mask, m_RefCount);
            MainLoaderReferer(true);
            LoaderProfiler.Instance.EnqueueAssetLife(m_Mask,m_Key,LoaderProfiler.PointType.AskLoadAb,string.Format("ab name:{0}",
                LoadUtility.instance.GenAssetBundlekey(abInfoConfig.AssetBundleName)));
        }

        void LoadAsset()
        {
            LoaderProfiler.Instance.EnqueueAssetLife(m_Mask,m_Key,LoaderProfiler.PointType.LoadedAb);
            AssetBundle assetBundle = m_MainAssetbundleLoader.assetBundle;
            string errorMsg = null;
            if (assetBundle == null)
            {
                errorMsg = string.Format("Load ab Error,asset name = {0}", m_AssetPath);                
                OnAssetLoaded(null,errorMsg);
                return;
            }

            if (m_AssetType == typeof(Scene))
            {
                OnAssetLoaded(assetBundle,null);
            }
            else
            {
                m_AssetBundleRequest = assetBundle.LoadAssetAsync(m_AssetConfig.AssetPath, m_AssetType);
                if (m_AssetBundleRequest == null)
                {
                    errorMsg = string.Format("m_AssetBundleRequest == null, asset name = {0}", m_AssetPath);
                    OnAssetLoaded(null,errorMsg);
                }
            }
        }

        void OnAssetLoaded(Object asset, string errorMsg)
        {
            AgentState = LoaderAgentState.Done;
            LoaderProfiler.Instance.EnqueueAssetLife(m_Mask, m_Key, LoaderProfiler.PointType.LoadedAsset);
            if (m_OnLoad != null)
            {
                m_OnLoad(asset, errorMsg);
            }
        }

        void OnStateChange()
        {
            if (AgentState == LoaderAgentState.LoadDependency)
            {
                LoadDependencies();
            }else if (AgentState == LoaderAgentState.LoadAssetAb)
            {
                LoadAssetAb();
            }else if (AgentState == LoaderAgentState.LoadAsset)
            {
                LoadAsset();
            }
        }

        public void OnUpdate()
        {
            switch (AgentState)
            {
                case LoaderAgentState.LoadDependency:
                    OnLoadDependenciesUpdate();
                    break;
                case LoaderAgentState.LoadAssetAb:
                    if (m_MainAssetbundleLoader.isDone)
                    {
                        AgentState = LoaderAgentState.LoadAsset;
                    }
                    break;
                case LoaderAgentState.LoadAsset:
                    if (m_AssetBundleRequest != null)
                    {
                        OnAssetBundleRequest();
                    }
                    break;
            }
        }
        
        private void OnAssetBundleRequest()
        {
            if (m_AssetBundleRequest.isDone)
            {
                ReplaceShader();
                OnAssetLoaded(m_AssetBundleRequest.asset,null);
                m_AssetBundleRequest = null;
            }
        }

        public void UpdateMask(ulong mask)
        {
            m_Mask |= mask;
        }

        public void AddMask(ulong mask)
        {
            if(mask == 0)
            {
                Debug.LogError("mask = 0");
            }

           AddOrRemoveMask(mask,true);
        }

        void AddOrRemoveMask(ulong mask, bool isAdd)
        {
            if (isAdd)
            {
                m_Mask |= mask;
                m_RefCount++;
            }
            else
            {
                m_Mask &= ~mask;
                m_RefCount--;
            }

            if (m_MainAssetbundleLoader != null)
            {
                if (isAdd)
                {
                    m_MainAssetbundleLoader.AddMask(mask);
                }
                else
                {
                    m_MainAssetbundleLoader.RemoveMask(mask);
                }
            }

            if (m_DependencyLoaders != null)
            {
                foreach (var loader in m_DependencyLoaders)
                {
                    if (isAdd)
                    {
                        loader.AddMask(mask); 
                    }
                    else
                    {
                        loader.RemoveMask(mask);
                    }
                   
                }
            }
        }

        public void RemoveMask(ulong mask)
        {
            AddOrRemoveMask(mask,false);
        }

        private void UnloadAssetBundles()
        {
           MainLoaderReferer(false);
           DependLoaderReferer(false);
        }

        private void MainLoaderReferer(bool isAdd)
        {
            if(m_MainAssetbundleLoader != null)
            {
                if(isAdd)
                {
                    m_MainAssetbundleLoader.Plus_AB_RefCount();
                }
                else
                {
                    m_MainAssetbundleLoader.Minus_AB_RefCount();
                }
            }           
        }

        private void DependLoaderReferer(bool isAdd)
        {
            if (m_DependencyLoaders != null)
            {
                foreach (var loader in m_DependencyLoaders)
                {
                    if(isAdd)
                    {
                        loader.Plus_AB_RefCount();
                    }
                    else
                    {
                        loader.Minus_AB_RefCount();
                    }
                }
            }
        }

        #region GetAbLoader

        public List<AssetBundleLoader> TryStartDependenceLoader(AssetConfig config, ulong refMask, out string[] dependencies )
        {
            List<AssetBundleLoader> dependenceLoaders = new List<AssetBundleLoader>();
            dependencies  = AssetBundleManager.instance.GetAllDependencies(config.AssetBundleName);

            foreach (var dependAbName in dependencies)
            {
                AssetBundleInfoConfig assetConfig = LoadUtility.instance.GetABInfoConfigByABName(dependAbName);

                if (assetConfig == null)
                {
                    continue;
                }

                AssetBundleLoader dependenceLoader = TryStartAssetBundleLoader(assetConfig, refMask);
                dependenceLoaders.Add(dependenceLoader);
            }

            return dependenceLoaders;
        }

        public AssetBundleLoader TryStartAssetBundleLoader(AssetBundleInfoConfig config, ulong refMask, int refCount = 0)
        {
            string key = LoadUtility.instance.GenAssetBundlekey(config.AssetBundleName);
            AssetBundleLoader loader = LoaderPool.instance.GetLoader<AssetBundleLoader>(key);

            if(loader == null)
            {
                loader = new AssetBundleLoader(key,config);
                LoaderPool.instance.Add(loader);
            }
            loader.SetMask(refMask, refCount);
            return loader;
        }

        #endregion
        
        #region FixShaderWhenEditorMode

          private void ReplaceShader()
        {
#if UNITY_EDITOR_OSX || UNITY_EDITOR
            if (m_AssetBundleRequest.asset != null)
            {
                try
                {
                    if (m_AssetBundleRequest.asset is GameObject)
                    {
                        GameObject obj = m_AssetBundleRequest.asset as GameObject;
                        
                        ReplaceGameObjectShaderOnEditor(obj);
                    }
                    else if (m_AssetBundleRequest.asset is Material)
                    {
                        Material mat = m_AssetBundleRequest.asset as Material;
                        if (mat != null)
                        {
                            ReplaceShaderOnEditor(mat);
                        }
                    }
                }
                catch (Exception e)
                {
                    Debug.LogException(e);
                }
            }
#endif

        }

        public static void ReplaceGameObjectShaderOnEditor(GameObject obj)
        {
            #if UNITY_EDITOR
            Renderer[] renderers = obj.GetComponentsInChildren<Renderer>(true);
            foreach (var renderer in renderers)
            {
                UnityEngine.Material[] matArr = renderer.sharedMaterials;
                foreach (var mat in matArr)
                {
                    if (mat != null)
                    {
                        ReplaceShaderOnEditor(mat);
                    }
                }
            }

            UnityEngine.UI.Graphic[] css = obj.GetComponentsInChildren<UnityEngine.UI.Graphic>(true);
            foreach (var rer in css)
            {
                ReplaceShaderOnEditor(rer.material);
            }
            #endif
        }

        public static Material ReplaceShaderOnEditor(Material mat)
        {
            if (mat == null)
                return mat;
            #if UNITY_EDITOR
            var shaderName = mat.shader.name;
            
            var shaderInRuntime = Shader.Find(shaderName);
            if (shaderInRuntime != null)
            {
                mat.shader = shaderInRuntime;
            }
            else
            {
                Debug.LogError(string.Format("Cant not find the shader: {0} used in mat: {1}", shaderName, mat.name));
            }
#endif
            return mat;
        }

        #endregion

        public void UnLoad()
        {
            UnloadAssetBundles();
            LoaderProfiler.Instance.EnqueueAssetLife(m_Mask,m_Key,LoaderProfiler.PointType.UnLoadAssetAb);
            m_AssetPath = null;
            m_AssetType = null;
            m_OnLoad = null;
            m_AssetBundleRequest = null;
            m_Mask = 0;
            m_AssetConfig = null;
            m_AgentState = LoaderAgentState.Wait;
            m_Key = string.Empty;
            if (m_DependencyLoaders != null)
                m_DependencyLoaders.Clear();
            //TODO @chenjie 清除的逻辑还有待考虑
            m_DependencyLoaders = null;
            m_MainAssetbundleLoader = null;
        }
    } 

}

