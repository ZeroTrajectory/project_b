/*
ABObject相当于一个AB加载器，一个object对应一个AB，具有以下职能
1.记录AB的引用计数、AB的加载实例、AB加载的回调、AB的依赖AB
2.实现AB异步加载（通过update实现）
*/
using System;
using System.Collections.Generic;
using UnityEngine;

namespace Core.Load 
{
    public class ABObject
    {
        private string _abName;
        private LoadStatus _status;
        private int _refCount;
        private AssetBundle _ab;
        private AssetBundleCreateRequest _abCreateReq;
        private List<ABObject> _dependsList = new List<ABObject>();
        private List<Action<AssetBundle>> _callbackList = new List<Action<AssetBundle>>();
        private bool _dependsIsDone = false;

        public string abName
        {
            get
            {
                return _abName;
            }
        }

        public LoadStatus status
        {
            set
            {
                _status = value;
                SwitchStatus();
            }
            get
            {
                return _status;
            }
        }

        public ABObject(string abName)
        {
            _abName = abName;
            _refCount = 0;
            InitDepends();
            status = LoadStatus.Wait;           
        }

        public void AddCallback(Action<AssetBundle> callback)
        {
            if(callback != null)
                _callbackList.Add(callback);
            AddRefCount();
        }

        private void InitDepends()
        {
            string[] depends = AssetLoadMgr.I.GetDepends(_abName);
            for(int i = 0; i < depends.Length; i++)
            {
                ABObject obj = AssetLoadMgr.I.GetABObject(depends[i]);
                _dependsList.Add(obj);
            }
        }

        public void AddRefCount()
        {
            _refCount++;
            for(int i = 0; i < _dependsList.Count; i++)
            {
                _dependsList[i].AddRefCount();
            }
        }

        public void SubRefCount()
        {
            _refCount--;
            for(int i = 0; i < _dependsList.Count; i++)
            {
                _dependsList[i].SubRefCount();
            }
        }

        public bool IsValid()
        {
            return _refCount != 0;
        }

        private void SwitchStatus()
        {
            switch(_status)
            {
                case LoadStatus.Wait:
                    break;
                case LoadStatus.LoadDepends:
                    LoadDepends();
                    break;
                case LoadStatus.LoadMain:
                    LoadMain();
                    break;
                case LoadStatus.Loaded:
                    LoadSuccess();
                    break;
                case LoadStatus.LoadError:
                    LoadFail();
                    break;
                case LoadStatus.WaitDelete:
                    UnLoad();
                    break;
            }
        }

        public void Update()
        {
            if(status == LoadStatus.LoadDepends)
            {
                UpdateLoadDepends();
            }
            else if(status == LoadStatus.LoadMain)
            {
                UpdateLoadMain();
            }
        }

        public void StartLoad()
        {       
            if(status < LoadStatus.LoadDepends)
                status = LoadStatus.LoadDepends;
        }

        private void LoadDepends()
        {
            for(int i = 0; i < _dependsList.Count; i++)
            {
                _dependsList[i].StartLoad();
            }
        }

        private void LoadMain()
        {
            string path = AssetLoadMgr.I.GetTotalPath(_abName);
            _abCreateReq = AssetBundle.LoadFromFileAsync(path);
        }

        private void UpdateLoadDepends()
        {
            _dependsIsDone = true;
            for(int i = 0; i < _dependsList.Count; i++)
            {
                _dependsIsDone &= _dependsList[i].IsDone();
            }
            if(_dependsIsDone)
            {
                status = LoadStatus.LoadMain;
            }
        }

        private void UpdateLoadMain()
        {
            if(_abCreateReq == null)
            {
                status = LoadStatus.LoadError;
                return;
            }
            if(_abCreateReq.isDone)
            {
                _ab = _abCreateReq.assetBundle;
                if(_ab == null)
                {
                    status = LoadStatus.LoadError;
                }
                else
                {
                    status = LoadStatus.Loaded;
                }
            }
        }

        public bool IsDone()
        {
            return status == LoadStatus.Loaded || status == LoadStatus.LoadError;
        }

        private void LoadSuccess()
        {
            for(int i = 0; i < _callbackList.Count; i++)
            {
                _callbackList[i]?.Invoke(_ab);
            }
            _callbackList.Clear();
        }

        private void LoadFail()
        {
            for(int i = 0; i < _callbackList.Count; i++)
            {
                _callbackList[i]?.Invoke(null);
            }
            _callbackList.Clear();
        }

        private void UnLoad()
        {
            if(_ab != null)
                _ab.Unload(true);
            _ab = null;
            _abName = string.Empty;
            _abCreateReq = null;
            _dependsList.Clear();
            _callbackList.Clear();
            _status = LoadStatus.Deleted;
            _dependsIsDone = false;
        }
    }
}

