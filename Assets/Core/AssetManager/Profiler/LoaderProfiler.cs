using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using UnityEngine;
using Random = UnityEngine.Random;

namespace Core.Load
{
    public class LoaderProfiler
    {
        private static LoaderProfiler s_Instance;
        public static LoaderProfiler Instance
        {
            get
            {
                if(s_Instance ==null)
                    s_Instance = new LoaderProfiler();
                return s_Instance;
            }
        }
        
        [System.Flags]
        public enum LogLevel
        {
            None = 0,
            Mask = 1,
            WatchList = 1<<2,
            LogSingle = 1<<3,
        }

        public LogLevel logLevel;
        public bool enableDelayLoad;
        public float defaultDelayTime = 0f;
        public float minDelayTime = 0.08f;
        public float maxDelayTime = 0.1f;
        public float GetLoaderDelay()
        {
            if (enableDelayLoad)
            {
                return Random.Range(minDelayTime, maxDelayTime);
            }
            return defaultDelayTime;
        }
        public List<string> watchList = new  List<string>();
        
#if UNITY_EDITOR
        public bool enable = true;
#else
        public bool enable = false;
        #endif

        #region Data Model
        public struct TimePoint
        {
            public float realTime;
            public float frameCount;
            public float time;

            public static TimePoint CreateTimePoint()
            {
                return new TimePoint() {
                    realTime = Time.realtimeSinceStartup,
                    frameCount = Time.frameCount, 
                    time = Time.time,
                };
            }

            public override string ToString()
            {
                return string.Format("timestamp: rt:{0}-fm:{1}-tt:{2}",realTime,frameCount,time);
            }
        }
        public struct LoadPoint<T2>
        {
            public TimePoint timePoint;
            public string opt ;
            public T2 pointType;
            public ulong mask;

            public LoadPoint(ulong mask, T2 pointType, string opt,TimePoint timePoint)
            {
                this.mask = mask;
                this.pointType = pointType;
                this.opt = opt;
                this.timePoint = timePoint;
            }

            public override string ToString()
            {
                return string.Format("pointType:{2}, mask:{3} opt:【{1}】  {0} ",timePoint,opt,pointType,mask);
            }
        }
        public class SequencePoint<T,T2> 
        {
            public T key;
           
            
            public SequencePoint(T key)
            {
                this.key = key;
            }

            public List<LoadPoint<T2>> loadPoints = new List<LoadPoint<T2>>();

            public void EnquePoint(T2 pointType,string opt,ulong mask)
            {
                loadPoints.Add(new LoadPoint<T2>()
                {
                    opt =  opt,
                    pointType =  pointType,
                    mask =  mask,
                    timePoint = TimePoint.CreateTimePoint(),
                });
            }

            public override string ToString()
            {
                StringBuilder builder = new StringBuilder();
                builder.AppendFormat("{0}:  {1}\r\n",key, loadPoints.Count);
                foreach (var point in loadPoints)
                {
                    if (point.timePoint.realTime != 0)
                    {
                        builder.AppendLine(point.ToString());
                    }
                }

                builder.AppendLine();
                return builder.ToString();
            }

            public bool HasPoints(List<T2> pointTypes)
            {
                if (pointTypes == null)
                    return false;
                bool has = true;
                for (int i = 0; i < pointTypes.Count; i++)
                {
                    has &= loadPoints.Exists(p => Convert.ToInt16(p.pointType) == Convert.ToInt16(pointTypes[i]));
                }
                return has;
            }
        }
        #endregion

        #region Asset life trace
        public enum PointType
        {
            AskLoadAsset =0,//上层逻辑请求加载Asset
            AskLoadAbDependency = 1 , //请求加载ab的依赖
            AskLoadAb = 2, //请求加载asset的ab
            LoadedAbDependency = 3, //ab的依赖加载完成
            LoadedAb = 4, //ab的依赖加载完成
            LoadedAsset = 5,
            ReturnAsset = 6, //返回加载的资源给上层逻辑
            AskUnloadAsset = 7, //请求UnloadAsset
            UnLoadAsset = 8, //unload asset
            UnLoadAssetAb = 9, //unload asset ab
            AskUnloadMask = 11,  //unload mask
            UnloadAutoMask = 12,
            RemoveLoaderMask = 13,
            RemoveLoader = 16,
            UnLoadLoader = 17,
            AddLoaderMask = 18,
            SetABLoaderMask = 19,
            AddAssetLoadCb = 21,
        }
        
        private Dictionary<string, SequencePoint<string,PointType>> m_AssetPoints = new Dictionary<string, SequencePoint<string,PointType>>();
        private Dictionary<ulong, SequencePoint<ulong,PointType>> m_MaskPoints = new Dictionary<ulong, SequencePoint<ulong,PointType>>();

        public void EnqueueAssetLife(ulong key, string assetPath, PointType pointType, string opt = "")
        {
            if (!enable)
            {
                return;
            }

#if DEBUG
           
            if (!string.IsNullOrEmpty(assetPath))
            {
                SequencePoint<string,PointType> point = null;
                if (!m_AssetPoints.TryGetValue(assetPath, out point))
                {
                    point = new SequencePoint<string,PointType>(assetPath);
                    m_AssetPoints.Add(assetPath, point);
                }

                point.EnquePoint(pointType, opt,key);
                if (HasLogLevel(LogLevel.WatchList) && watchList.Find((x) => { return assetPath.Contains(x); })!=null)
                {
                    if (HasLogLevel(LogLevel.LogSingle))
                    {
                        Debug.LogFormat("Watch Asset:{0}\r\npointType:{1},mask:{2},opt:【{3}】", assetPath,pointType,key,opt);
                    }
                    else
                    {
                        Debug.LogFormat("Watch Asset:{0}",point);
                    }
                }
            }

            SequencePoint<ulong,PointType> pointMask = null;
            if (!m_MaskPoints.TryGetValue(key, out pointMask))
            {
                pointMask = new SequencePoint<ulong,PointType>(key);
                m_MaskPoints.Add(key,pointMask);
            }
            pointMask.EnquePoint(pointType,opt,key);
#endif
        }

        public void ClearAssetLife()
        {
            m_AssetPoints.Clear();
            m_MaskPoints.Clear();
        }

        public void PrintAssetLift()
        {
           // Debug.Log(string.Join("\r\n", m_AssetPoints));
            //Debug.Log(string.Join("\r\n", m_MaskPoints));
            foreach (var point in m_AssetPoints)
            {
                Debug.LogFormat("{0}{1}",point.Key,point.Value);
            }
        }

        public string SerializeAssetPoints()
        {
            StringBuilder builder = new StringBuilder();
            foreach (var point in m_AssetPoints)
            {
                builder.AppendLine(point.Value.ToString());
            }
            return builder.ToString();
        }

        public string SerializeMaskPoints()
        {
            return null;
        }

        public string GetSuccessLoaded()
        {
            List<PointType> pointTypes = new List<PointType>(){PointType.AskLoadAsset,PointType.ReturnAsset};
            return FilterPoints(pointTypes,null);
        }

        public string GetFailLoaded()
        {
            List<PointType> pointTypes = new List<PointType>(){PointType.AskLoadAsset};
            List<PointType> notHasPoints = new List<PointType>(){PointType.ReturnAsset};
            return FilterPoints(pointTypes, notHasPoints);
        }

        public string FilterPoints( List<PointType> hasPointTypes ,List<PointType> notHasPointTypes)
        {
            StringBuilder builder = new StringBuilder();
            int index = 0;
            foreach (var kv in m_AssetPoints)
            {
                if (kv.Value.HasPoints(hasPointTypes)&&!kv.Value.HasPoints(notHasPointTypes))
                {
                    builder.AppendLine(string.Format("{0}{1}", kv.Key, kv.Value));
                    index++;
                }
            }

            builder.AppendFormat("total count:{0}, filter count:{1}",m_AssetPoints.Count, index);
            return builder.ToString();
        }
        #endregion

        #region HelperFunc

        public void RecordLoad(string assetPath)
        {
#if UNITY_EDITOR
            if (LoaderPool.instance.enableCollectUseAsset)
            {
                var dependencies = UnityEditor.AssetDatabase.GetDependencies(assetPath);
                foreach (var de in dependencies)
                {
                    ResourceUseUtility.instance.AddResource(de);
                }
            }
#endif
        }

        #endregion


        #region Loader Status Trace
        private Dictionary<string,SequencePoint<string,ELoadStatus>> m_Loaders = new Dictionary<string, SequencePoint<string, ELoadStatus>>();
        
        public string DumpLoaders()
        {
            StringBuilder builder = new StringBuilder();
            LoaderPool pool = LoaderPool.instance;
            TimePoint timePoint = TimePoint.CreateTimePoint();
            builder.AppendLine(string.Format("<====>loader count:{0}, automaskloader count:{1}, {2}",
                pool.LoadersCount,pool.AutoMaskLoaderCount, timePoint));
            int index = 0;
            ILoader loader = pool.GetNextAutoMaskLoader(index++);
            while (loader!=null)
            {
                builder.AppendLine(string.Format("auto mask loader:{0}",loader.IdentityKey()));
                loader = pool.GetNextAutoMaskLoader(index++);
            }

            LinkedListNode<ILoader> node = null;
            pool.TryGetLastLoader(ref node);
            float abMemroySize = 0;
            int abCount = 0;
            while (node != null)
            {
                loader = node.Value;
                if (loader is AssetBundleLoader)
                {
                    abMemroySize += (loader as AssetBundleLoader).BuildSize();
                    abCount++;
                }

                builder.AppendLine(string.Format("current loader:{0}",loader.IdentityKey()));
                pool.TryGetLastLoader(ref node);
            }

            builder.AppendLine(string.Format("<====>assetbundle count:{0}, assetbundle memory size:{1}, max clean size:{2}",
                abCount, abMemroySize,LoaderPool.MAX_CLEAN_MEMORY));
            return builder.ToString();
        }

        public void EnqueueLoaderStatus(string assetPath, ELoadStatus loadStatus, ulong mask, string opt,string loadSign)
        {
            if (!enable)
            {
                return;
            }

#if DEBUG
            if (string.IsNullOrEmpty(assetPath))
            {
                if (loadStatus != ELoadStatus.Deleted)
                    Debug.LogError("assetpath isnull " + loadStatus + "   " + loadSign);
                return;
            }
            SequencePoint<string, ELoadStatus> node;
            if (!m_Loaders.TryGetValue(assetPath, out node))
            {
                node = new SequencePoint<string, ELoadStatus>(string.Format("{0}_{1}",loadSign,assetPath));
                m_Loaders.Add(assetPath,node);
            }
            node.EnquePoint(loadStatus,opt,mask);
            if (HasLogLevel(LogLevel.WatchList) &&watchList.Find((x) => { return assetPath.Contains(x); })!=null)
            {
                Debug.LogFormat("Watch Asset Loader Status:{0}",node);
            }
#endif
        }

        public string GetLoadersString()
        {
            StringBuilder builder = new StringBuilder();
            foreach (var kv in m_Loaders)
            {
                builder.AppendLine(string.Format("{0}",kv.Value));
            }
            return builder.ToString();
        }

        public void ClearLoaderStatus()
        {
            m_Loaders.Clear();
        }

        #endregion

        #region Loader List Trace

        public enum ELoaderListTrack
        {
            FirstAdd,
            Get,
            AskDelete,
            DoDelete,
            Gc,
            CleanUp,
            UnloadMask,
            UnloadAssetPath,
        }

        private LinkedList<SequencePoint<string,ELoaderListTrack>> m_LoaderList = new LinkedList<SequencePoint<string, ELoaderListTrack>>();

        private bool HasLogLevel(LogLevel level)
        {
            return (logLevel & level) == level;
        }

        public void EnqueueLoaderListOpt(string key, ELoaderListTrack pointType,string opt="")
        {
            if(!enable)
                return;
            SequencePoint<string, ELoaderListTrack> point = null;
            foreach (var ll in m_LoaderList)
            {
                if (ll.key == key)
                {
                    point = ll;
                    break;
                }
            }

            if (point == null)
            {
                point = new SequencePoint<string, ELoaderListTrack>(key);
                m_LoaderList.AddLast(point);
            }
            point.EnquePoint(pointType,opt,0);
            if (HasLogLevel(LogLevel.WatchList) && watchList.Find((x) => { return key.Contains(x); })!=null)
            {
                Debug.LogFormat("Watch Asset Loader List:{0}",point);
            }
        }

        public string GetLoaderListTrack()
        {
            StringBuilder builder = new StringBuilder();
            foreach (var ll in m_LoaderList)
            {
                builder.AppendLine(ll.ToString());
            }
            return builder.ToString();
        }

        public void ClearLoaderListTrack()
        {
            m_LoaderList.Clear();
        }

        #endregion


        #region LoaderMask Trace
        public enum ELoadMaskOpt
        {
            AllocMask,
            DeallocMask,
            ResetMask
        }
        private List<string> m_MaskTrace =new List<string>();

        public void EnqueueLoadMaskOpt(ulong mask, ELoadMaskOpt loadMaskOpt)
        {
            if(!enable)
                return;
            string value = string.Format("{0},mask:{1},   bits: {2}, time:{3}-{4}-{5}",loadMaskOpt, mask, LoadMask.BitPrint(),
                Time.realtimeSinceStartup, Time.frameCount, Time.time);
            if (HasLogLevel(LogLevel.Mask))
            {
                Debug.Log(value);
            }

            m_MaskTrace.Add(value);
        }

        public string DumpMaskInfo()
        {
            return string.Join("\r\n", m_MaskTrace);
        }

        #endregion
        
    }

}

