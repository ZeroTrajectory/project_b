using Core.Load;
using UnityEngine;

namespace Core.Load
{
    public static class AssetConst
    {
        public const int VersionLength = 4;
        public const string ASSETLIST_UNITY_PATH = "Assets/AssetList.csv";
        public static string ASSETLIST_FULL_PATH = Application.dataPath + "/AssetList.csv";
        public const string ABLIST_UNITY_PATH   =  "Assets/ABList.csv";
        public static string ABLIST_FULL_PATH    = Application.dataPath + "/ABList.csv";
        public const string ABEXLIST_UNITY_PATH   =  "Assets/ABExList.csv";
        public const string AB_SUFFIX = ".ab";

        public const string CRIWARE_DIR = "gamemain/criware";

        public const string CRIWARE_VEDIO_AB_DIR = "gamemain/criware/criwarevideo";
        public const string SLG_IMAGE_AB_DIR = "gamemain/ui/uiimages2/slgmapbg";
        public const string MANIFEST_AB_NAME = "AssetBundle";
        public const string ASSETLIST_AB_NAME = "assetlist";
        public const string ABEXLIST_AB_NAME = "assetexlist";



        #region "running path"
        public const string AB_PATH_FROM_STORAGE = "{0}/{1}/AssetBundle/{2}";
        public const string AB_PATH_FROM_STREAMING = "{0}/AssetBundle/{1}";
        
        
        public const string AB_URL_PATH = "{0}/{1}/AssetBundle/{2}";
        #endregion

        #region "asset key"
        public const string DEPEND_KEY = "depend_{0}";
        public const string ASSET_KEY = "asset_{0}";
        public const string ASSETBUNDLE_KEY = "ab_{0}";
        public const string BYTES_KEY = "byte_{0}";
        public const string SCENE_KEY = "scene_{0}";
        public const string FILE_KEY = "file_{0}";
        #endregion
        public const string HOTUPDATE_TEMP_RELOCATE = "relocate";

    }
}

