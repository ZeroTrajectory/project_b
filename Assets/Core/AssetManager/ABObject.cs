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
    public enum LoadStatus
    {
        Wait,
        Loading,
        Loaded,
        LoadError,
        WaitDelete,
        Deleted,
    }
    public class ABObject
    {
        private string _path;
        private LoadStatus _status;
        private int _refCount;
        private AssetBundle _ab;
        private AssetBundleCreateRequest _abCreateReq;
        private List<ABObject> _dependsList = new List<ABObject>();
        private List<Action<AssetBundle>> _callbackList = new List<Action<AssetBundle>>();

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

        public ABObject(string path,Action<AssetBundle> callback)
        {
            _path = path;
            _callbackList.Add(callback);
            status = LoadStatus.Wait;
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
                    StartLoad();
                    break;
                case LoadStatus.Loading:
                    break;
                case LoadStatus.Loaded:
                    LoadSuccess();
                    break;
                case LoadStatus.LoadError:
                    LoadFail();
                    break;
                case LoadStatus.WaitDelete:
                    break;
            }
        }

        public void Update()
        {
            if(status == LoadStatus.Loading)
            {
                UpdateLoading();
            }
        }

        private void StartLoad()
        {
            status = LoadStatus.Loading;
            _abCreateReq = AssetBundle.LoadFromFileAsync(_path);
        }

        private void UpdateLoading()
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

        }
    }
}

