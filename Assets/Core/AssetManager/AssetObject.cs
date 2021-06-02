/*
AssetObject是一个资源加载器，一个资源对应一个object，它具有以下职能：
1.存储资源路径、对应的AB文件、回调函数
2.卸载资源接口，同时对应AB的引用计数减少
*/
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Core.Load
{
    public class AssetObject
    {
        private string _assetName;
        private LoadStatus _status;
        private int _refCount;
        private ABObject _abObject;
        private List<Action<object>> _callbackList;
        private AssetBundleRequest _abReq;
        private object _asset;
        

        public LoadStatus status
        {
            get
            {
                return _status;
            }
            set
            {
                _status = value;
                SwitchStatus();
            }
        }
        public AssetObject(string assetName)
        {
            _assetName = assetName;
            _refCount = 1;
            InitABObject();
            _status = LoadStatus.Wait;
        }

        private void InitABObject()
        {
            string abName = AssetLoadMgr.I.GetABNameByAssetName(_assetName);
            _abObject = AssetLoadMgr.I.GetABObject(abName);
        }

        private void SwitchStatus()
        {
            switch(status)
            {
                case LoadStatus.Wait:
                    break;
                case LoadStatus.LoadDepends:
                case LoadStatus.LoadMain:
                    break;
                case LoadStatus.LoadAsset:
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

        private void StartLoad()
        {
            if(status < LoadStatus.LoadDepends)
                status = LoadStatus.LoadDepends;
        }

        public void Update()
        {
            if(status == LoadStatus.LoadDepends || 
                status == LoadStatus.LoadMain)
            {
                UpdateLoadAB();
            }
            else if(status == LoadStatus.LoadAsset)
            {
                UpdateLoadAsset();
            }
        }

        private void UpdateLoadAB()
        {
            if(_abObject == null)
            {
                status = LoadStatus.LoadError;
                return;
            }
            if(_abObject.IsDone())
            {
                status = LoadStatus.LoadAsset;
            }
        }

        private void UpdateLoadAsset()
        {
            if(_abReq == null)
            {
                status = LoadStatus.LoadError;
                return;
            }
            if(_abReq.isDone)
            {
                _asset = _abReq.asset;
                if(_asset == null)
                {
                    status = LoadStatus.LoadError;
                }
                else
                {
                    status = LoadStatus.Loaded;
                }
            }
        }

        private void LoadABDone(AssetBundle ab)
        {
            if(ab == null)
            {
                status = LoadStatus.LoadError;
                return;
            }
            _abReq = ab.LoadAssetAsync(_assetName);
            status = LoadStatus.LoadAsset;
        }

        private void LoadSuccess()
        {
            for(int i = 0; i < _callbackList.Count; i++)
            {
                _callbackList[i]?.Invoke(_asset);
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
    }

}