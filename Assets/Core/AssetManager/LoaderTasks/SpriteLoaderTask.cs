using System;
using Core.Load;
using UnityEngine;
using UnityEngine.UI;

namespace Core.Load
{
    public class SpriteLoaderTask : MonoBehaviour
    {
        public static SpriteLoaderTask GetTaskAndLoad(Image img, string assetPath, ulong mask, Action<Sprite> onLoad)
        {
            SpriteLoaderTask loaderTask = GetTask(img);
            if(loaderTask!=null)
                loaderTask.Load(assetPath,mask,onLoad);
            return loaderTask;
        }

        public static SpriteLoaderTask GetTaskAndLoad(RawImage rawImage, string assetPath, ulong mask, Action<Sprite> onLoad)
        {
            SpriteLoaderTask loaderTask = GetTask(rawImage?.gameObject);
            if (loaderTask != null)
                loaderTask.Load(assetPath, mask, onLoad);
            return loaderTask;
        }

        public static SpriteLoaderTask GetTask(Image img)
        {
            if (img == null)
                return null;
            return GetTask(img.gameObject);
        }

        public static SpriteLoaderTask GetTask(GameObject go)
        {
            if (go == null)
                return null;
            SpriteLoaderTask task = go.GetComponent<SpriteLoaderTask>();
            if(task == null)
                task = go.AddComponent<SpriteLoaderTask>();
            return task;
        }
        
        public static void ReleaseTask(SpriteLoaderTask task)
        {
            if(task==null)
                return;
            task.Clear();
        }

        [SerializeField]
        private string m_AssetPath;
        [SerializeField]
        private ulong m_Mask;
        private Action<Sprite> m_OnLoad;
        private LoadAssetCallbacks m_LoadAssetCallbacks ;
        private enum ELoadState
        {
            Ready,
            Loading,
            Loaded,
        }

        private ELoadState m_LoadState;

        public void Load(string assetPath, ulong mask,Action<Sprite> onLoad)
        {
            if (mask == 1)
            {
                Debug.LogErrorFormat("Load Sprite On Auto Mask,{0}   @guozicheng", assetPath);
            }

            if (!IsParameterValid(assetPath, mask, onLoad))
            {
                return;
            }
            
            UnLoadIfIsLoaded();
            // m_Mask |= mask;
            m_AssetPath = assetPath;
            m_Mask |= LoadMask.REFCOUNT;
            m_OnLoad += onLoad;
            if (m_LoadAssetCallbacks == null)
            {
                m_LoadAssetCallbacks = new LoadAssetCallbacks(LoadAssetSuccess, LoadAssetFail);
            }
           DoLoad();
        }

        bool IsParameterValid(string assetPath, ulong mask,Action<Sprite> onLoad)
        {
            if(onLoad == null)
                return false;
            if (string.IsNullOrEmpty(assetPath))
            {
                onLoad(null);
                return false;
            }

            return true;
        }

        void UnLoadIfIsLoaded()
        {
            if(string.IsNullOrEmpty(m_AssetPath))
            {
                return;
            }
            
            if (m_LoadState == ELoadState.Loaded||m_LoadState == ELoadState.Loading)
            {
                AssetManager.instance.UnloadAssetLoader(m_AssetPath, m_Mask, m_LoadAssetCallbacks.Id);
                m_Mask = 0;
            }
        }

        void DoLoad()
        {
           // Debug.LogError("SpriteLoderTask:"+IdentityString());
            AssetManager.instance.LoadAysnc(m_AssetPath,typeof(Sprite),m_LoadAssetCallbacks, m_Mask );
            m_LoadState = ELoadState.Loading;
        }

        void LoadAssetSuccess(string assetName, object asset, object userData)
        {
            LoadFinish((Sprite) asset);
        }

        void LoadAssetFail(string assetName, string errorMessage, object userData)
        {
            LoadFinish(null);
        }

        void LoadFinish(Sprite sprite)
        {
            if (m_OnLoad != null)
            {
                m_OnLoad(sprite);
            }
            m_OnLoad = null;
            m_LoadState = ELoadState.Loaded;
        }

        public void Clear()
        {
         //   Debug.LogErrorFormat("Clear SpriteLoaderTask:{0}",IdentityString());
            UnLoadIfIsLoaded();
            m_AssetPath = string.Empty;
            m_Mask = 0;
            m_OnLoad = null;
            m_LoadAssetCallbacks = null;
            m_LoadState = ELoadState.Ready;
        }

        public string IdentityString()
        {
            string id = m_LoadAssetCallbacks == null ? " -1" : m_LoadAssetCallbacks.Id;
            return string.Format("{0}, {1}, {2}, {3}, {4},{5} , {8}, {6}-{7}", gameObject.name, m_AssetPath, m_LoadState, m_Mask, GetInstanceID(),gameObject.GetInstanceID(),
                Time.realtimeSinceStartup, Time.frameCount, id);
        }

    }

}

