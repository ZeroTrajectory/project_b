using System;
using System.Timers;
using Object = UnityEngine.Object;

namespace Core.Load
{
	public class EditorLoadAgent : ILoaderAgent
	{
		Type m_AssetType;
		string m_AssetPath;
		private string m_Key;
		private Action<Object,string> m_OnLoad;
		private Timer m_Timer;
		private bool m_CanLoad;
		public void StartLoad(string key,string assetPath, Type assetType,Action<Object,string> onLoad)
		{
			m_AssetPath = assetPath;
			m_AssetType = assetType;
			m_OnLoad = onLoad;
			m_Key = key;
			if (m_AssetType == null)
			{
				m_AssetType = typeof(UnityEngine.Object);
			}

			if(onLoad == null)
				return;
			float delayTime = LoaderProfiler.Instance.GetLoaderDelay();
			if (delayTime > 0)
			{
				m_Timer = new Timer(delayTime);
				m_Timer.AutoReset = false;
				m_Timer.Elapsed += (sender, args) =>
				{
					m_Timer.Stop();
					m_CanLoad = true;
				};
				m_Timer.Start();
			}
			else
			{
				m_CanLoad = true;
			}
		}


		public void OnUpdate()
		{
			if (m_CanLoad)
			{
				DoLoad();
			}
		}
		
		void DoLoad()
		{
			#if UNITY_EDITOR
			Object asset = UnityEditor.AssetDatabase.LoadAssetAtPath(m_AssetPath, m_AssetType);
			
			string errorMsg = null;
			if (asset == null)
			{
				errorMsg = string.Format("加载失败:{0}",m_AssetPath);
			}

			if (m_OnLoad != null)
			{
				m_OnLoad(asset,errorMsg);
			}

			m_CanLoad = false;
#endif
		}

		public void AddMask(ulong mask)
		{
		}

		public void RemoveMask(ulong mask)
		{
		}

		public void UnLoad()
		{
			LoaderProfiler.Instance.EnqueueAssetLife(ulong.MinValue,m_Key,LoaderProfiler.PointType.UnLoadAssetAb);
			m_AssetType = null;
			m_AssetPath = "";
			m_OnLoad = null;
			m_CanLoad = false;
			m_Key = string.Empty;
			if (m_Timer != null)
			{
				m_Timer.Stop();
				m_Timer.Dispose();
				m_Timer = null;
			}
		}

        public void UpdateMask(ulong mask)
        {
            
        }
    }
}

