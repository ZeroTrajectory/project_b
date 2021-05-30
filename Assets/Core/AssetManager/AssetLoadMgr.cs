/*
AssetLoadMgr是资源加载卸载的唯一对外接口，传入加载的相对路径地址，加载的资源类型，回调加载完成
1.管理AssetLoader的循环遍历
2.记录AssetObject和ABObject，已经加载的资源直接取

##需要测试的东西
1.prefab上的image，如果被destroy了，对应的sprite是否还在内存中，如果在，是否能gc掉
*/
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Core.Load
{
    public enum LoadStatus
    {
        Wait,
        LoadDepends,
        LoadMain,
        LoadAsset,
        Loaded,
        LoadError,
        WaitDelete,
        Deleted,
    }
    public class AssetLoadMgr : MonoBehaviour
    {
        private Dictionary<string,string[]> _dependsDataDic;
        private List<AssetLoader> _assetLoaderList;
        private List<AssetLoader> _removeList;
        private Dictionary<string,ABObject> _abObjectDict;
        private Dictionary<string,AssetObject> _assetObjectDict;

        private static AssetLoadMgr _instance = null;

        public static AssetLoadMgr I
        {
            get
            {
                if(_instance == null)
                {
                    _instance = new AssetLoadMgr();
                }
                return _instance;
            }
        }

        private AssetLoadMgr()
        {
            _dependsDataDic = new Dictionary<string, string[]>();
            _assetLoaderList = new List<AssetLoader>();
            _removeList = new List<AssetLoader>();
            _abObjectDict = new Dictionary<string, ABObject>();
            _assetObjectDict = new Dictionary<string, AssetObject>();
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
            ABObject obj = null;
            if(!_abObjectDict.TryGetValue(abName,out obj))
            {
                obj = new ABObject(abName);
                _abObjectDict[abName] = obj;
            }
            return obj;
        }

        public AssetObject GetAssetObject(string assetName)
        {
            AssetObject obj = null;
            if(!_assetObjectDict.TryGetValue(assetName,out obj))
            {
                obj = new AssetObject(assetName);
                _assetObjectDict[assetName] = obj;
            }
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
            for(int i = 0; i < _assetLoaderList.Count; i++)
            {
                _assetLoaderList[i].Update();
                if(!_assetLoaderList[i].IsValid())
                {
                    _removeList.Add(_assetLoaderList[i]);
                }
            }
            if(_removeList.Count > 0)
            {
                for(int i = 0; i < _removeList.Count; i++)
                {
                    _removeList[i].status = LoadStatus.WaitDelete;
                    _assetLoaderList.Remove(_removeList[i]);
                }
                _removeList.Clear();
            }
        }
    }
}