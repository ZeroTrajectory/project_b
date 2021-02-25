using System;
using Core.Load;
using UnityEngine;

namespace Core.Load
{
    public class MaterialLoaderTask : MonoBehaviour
    {
        public static MaterialLoaderTask GetTaskAndLoad(GameObject go,string assetPath, ulong mask, Action<Material> onLoad)
        {
            if(go == null)
            {
                Debug.LogError("[MaterialLoaderTask][GetTaskAndLoad] go = null,assetPath = " + assetPath);
                return null;
            }

            MaterialLoaderTask loaderTask = GetTask(go);

            if(loaderTask!=null)
            {
                loaderTask.Load(assetPath,mask,onLoad);
            }
                
            return loaderTask;
        }
        
        public static MaterialLoaderTask GetTask(GameObject go)
        {
            if (go == null)
            {
                return null;
            }
                
            MaterialLoaderTask task = go.GetComponent<MaterialLoaderTask>();
            if(task == null)
                task = go.AddComponent<MaterialLoaderTask>();
            return task;
        }
        
        public static void ReleaseTask(MaterialLoaderTask task)
        {
            if(task==null)
            {
                return;
            }
                
            task.Clear();
        }

        private string m_AssetPath;
        private ulong m_Mask;
        private Action<Material> m_OnLoad;
        private LoadAssetCallbacks m_LoadAssetCallbacks ;
        private enum ELoadState
        {
            Ready,
            Loading,
            Loaded,
        }

        private ELoadState m_LoadState;
        public void Load(string assetPath, ulong mask,Action<Material> onLoad)
        {
            if (!IsParameterValid(assetPath, mask, onLoad))
            {
                return;
            }

            UnLoadIfIsLoaded();
            m_AssetPath = assetPath;
            m_Mask = mask;
            m_OnLoad = onLoad;

            if (m_LoadAssetCallbacks == null)
            {
                m_LoadAssetCallbacks = new LoadAssetCallbacks(LoadAssetSuccess, LoadAssetFail);
            }

           DoLoad();
        }

        bool IsParameterValid(string assetPath, ulong mask,Action<Material> onLoad)
        {
            if(onLoad == null)
            {
                Debug.LogError("[MaterialLoaderTask][IsParameterValid] Action onLoad is null");
                return false;
            }
                
            if (mask == 0||string.IsNullOrEmpty(assetPath))
            {
                Debug.LogError("[MaterialLoaderTask][IsParameterValid] mask = 0 or assetPath is empty");
                onLoad(null);
                return false;
            }

            return true;
        }

        void UnLoadIfIsLoaded()
        {
            if (m_LoadState == ELoadState.Loaded||m_LoadState == ELoadState.Loading)
            {
                AssetManager.instance.Unload(m_AssetPath,m_Mask);
            }
        }

        void DoLoad()
        {
            AssetManager.instance.LoadAysnc(m_AssetPath,typeof(Material),m_LoadAssetCallbacks, m_Mask );
            m_LoadState = ELoadState.Loading;
        }

        void LoadAssetSuccess(string assetName, object asset, object userData)
        {
            Material loadedMat = (Material) asset;
            Material newMat = new Material(loadedMat.shader);
            LoadFinish(newMat);
        }

        void LoadAssetFail(string assetName, string errorMessage, object userData)
        {
            LoadFinish(null);
        }

        void LoadFinish(Material material)
        {
            if (m_OnLoad != null)
            {
                m_OnLoad(material);
            }

            m_OnLoad = null;
            m_LoadState = ELoadState.Loaded;
        }

        private void OnDestroy()
        {
            Clear();
        }

        public void Clear()
        {
            UnLoadIfIsLoaded();
            
            m_Mask = 0;
            m_OnLoad = null;
            m_AssetPath = string.Empty;
            m_LoadAssetCallbacks = null;
            m_LoadState = ELoadState.Ready;
        }
    }
}