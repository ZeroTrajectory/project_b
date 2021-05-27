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

        private static AssetBundleLoadMgr _instance = null;

        public static AssetBundleLoadMgr I
        {
            get
            {
                if(_instance == null)
                {
                    _instance = new AssetBundleLoadMgr();
                }
                return _instance;
            }
        }

        private AssetBundleLoadMgr()
        {
            _dependsDataDic = new Dictionary<string, string[]>();
            _abObjectList = new List<ABObject>();
            _removeList = new List<ABObject>();
        }

        public void LoadManifest(string path)
        {
            if(string.IsNullOrEmpty(path)) return;
            _dependsDataDic.Clear();
            AssetBundle ab = AssetBundle.LoadFromFile(path);
            if(ab == null)
            {
                Debug.LogError("AssetBundle is null!");
                return;
            }
            AssetBundleManifest manifest = ab.LoadAsset("AssetBundleManifest") as AssetBundleManifest;
            if (manifest == null)
            {
                Debug.LogError("AssetBundleManifest is null!");
                return;
            }
            foreach(string abName in manifest.GetAllAssetBundles())
            {
                _dependsDataDic[abName] = manifest.GetAllDependencies(abName);
            }
        }

        public ABObject GetABObject(string abName)
        {
            for(int i = 0; i < _abObjectList.Count; i++)
            {
                if(_abObjectList[i].abName == abName)
                {
                    return _abObjectList[i];
                }
            }
            ABObject obj = new ABObject(abName);
            _abObjectList.Add(obj);
            return obj;
        }

        public string[] GetDepends(string abName)
        {
            if(_dependsDataDic.ContainsKey(abName))
            {
                return _dependsDataDic[abName];
            }
            return null;
        }

        public string GetTotalPath(string abName)
        {
            //TODO
            string path = abName;
            return path;
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
                    _removeList[i].status = LoadStatus.WaitDelete;
                    _abObjectList.Remove(_removeList[i]);
                }
                _removeList.Clear();
            }
        }
    }
  
}
