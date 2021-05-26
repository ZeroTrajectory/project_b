/*
AssetBundleLoadMgr管理AB的加载队列，通过循环遍历所有改变加载状态
*/

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Core.Load
{
    public class AssetBundleLoadMgr
    {
        private Dictionary<string,string[]> _dependsDataDic;
        private List<ABObject> _abObjectList;
        private List<ABObject> _removeList;

        private AssetBundleLoadMgr()
        {
            _dependsDataDic = new Dictionary<string, string[]>();
            _abObjectList = new List<ABObject>();
            _removeList = new List<ABObject>();
        }

        public void Update()
        {
            for(int i = 0; i < _abObjectList.Count; i++)
            {
                _abObjectList[i].Update();
                if(!_abObjectList[i].IsValid())
                {
                    _removeList.Add(_abObjectList[i]);
                }
            }
            if(_removeList.Count > 0)
            {
                for(int i = 0; i < _removeList.Count; i++)
                {
                    _abObjectList.Remove(_removeList[i]);
                }
                _removeList.Clear();
            }
        }
    }
  
}
