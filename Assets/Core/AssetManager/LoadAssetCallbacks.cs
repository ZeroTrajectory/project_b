
namespace Core.Load
{
    /// <summary>
    /// 加载资源回调函数集。
    /// </summary>
    public sealed class LoadAssetCallbacks
    {
        private readonly LoadAssetSuccessCallback m_LoadAssetSuccessCallback;
        private readonly LoadAssetFailureCallback m_LoadAssetFailureCallback;
        private static long s_Count = 0;
        public string Id { get; private set; }

        /// <summary>
        /// 初始化加载资源回调函数集的新实例。
        /// </summary>
        /// <param name="loadAssetSuccessCallback">加载资源成功回调函数。</param>
        public LoadAssetCallbacks(LoadAssetSuccessCallback loadAssetSuccessCallback)
            : this(loadAssetSuccessCallback, null)
        {
           
        }

        /// <summary>
        /// 初始化加载资源回调函数集的新实例。
        /// </summary>
        /// <param name="loadAssetSuccessCallback">加载资源成功回调函数。</param>
        /// <param name="loadAssetFailureCallback">加载资源失败回调函数。</param>
        /// <param name="loadAssetUpdateCallback">加载资源更新回调函数。</param>
        /// <param name="loadAssetDependencyAssetCallback">加载资源时加载依赖资源回调函数。</param>
        public LoadAssetCallbacks(LoadAssetSuccessCallback loadAssetSuccessCallback, LoadAssetFailureCallback loadAssetFailureCallback)
        {
            if (loadAssetSuccessCallback == null)
            {
                UnityEngine.Debug.LogError("Load asset success callback is invalid.");
                return;
            }

            m_LoadAssetSuccessCallback = loadAssetSuccessCallback;
            m_LoadAssetFailureCallback = loadAssetFailureCallback;

            if(s_Count == long.MaxValue)
            {
                s_Count = 1;
                Id = s_Count.ToString();
                UnityEngine.Debug.LogError("[LoadAssetCallbacks] s_Count 溢出重置");
                return;
            }

            Id =( s_Count++).ToString();
        }

        /// <summary>
        /// 获取加载资源成功回调函数。
        /// </summary>
        public LoadAssetSuccessCallback LoadAssetSuccessCallback
        {
            get
            {
                return m_LoadAssetSuccessCallback;
            }
        }

        /// <summary>
        /// 获取加载资源失败回调函数。
        /// </summary>
        public LoadAssetFailureCallback LoadAssetFailureCallback
        {
            get
            {
                return m_LoadAssetFailureCallback;
            }
        }
    }
}
