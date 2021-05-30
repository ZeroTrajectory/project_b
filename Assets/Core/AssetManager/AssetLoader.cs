/*
AssetLoader是单个资源的加载器，只管加载，不关心资源本身
1.保存AssetObject和ABObject，以及加载回调函数
2.通过Update循环加载Asset和AB
*/

using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Core.Load
{
    public class AssetLoader
    {
        private LoadStatus _status;
        private AssetObject _assetObject;
        private ABObject _abObject;
        private Action<List<object>> _callbackList;

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

        public AssetLoader(string assetName,string abName)
        {
            _assetObject = AssetLoadMgr.I.GetAssetObject(assetName);
            _abObject = AssetLoadMgr.I.GetABObject(abName);
        }

        private void SwitchStatus()
        {

        }

        public void Update()
        {

        }

        public bool IsValid()
        {
            return true;
        }
    }
}

