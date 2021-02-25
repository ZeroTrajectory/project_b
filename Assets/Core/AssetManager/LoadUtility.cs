using System.Collections.Generic;
using System.IO;
using Core.Load;
using UnityEngine;

public class LoadUtility
{
    private static LoadUtility _instance;
    public static LoadUtility instance
    {
        get
        {
            return _instance;
        }
    }

    public static void SetInstance(LoadUtility loadUtility)
    {
        _instance = loadUtility;
    }

    private Dictionary<string, AssetConfig> m_AssetListDict;

    public Dictionary<string, AssetConfig> AssetListDict
    {
        get
        {
            return m_AssetListDict;
        }
        set
        {
            m_AssetListDict = value;
        }
    }

    //private Dictionary<string, AssetBundleInfoConfig> m_AssetBundleInfoDic;
    private AssetBundleList<AssetBundleInfoConfig> m_AssetBundleInfoDic;
    //public Dictionary<string, AssetBundleInfoConfig> assetBundleInfoDic
    public AssetBundleList<AssetBundleInfoConfig> assetBundleInfoDic
    {
        get
        {
            return m_AssetBundleInfoDic;
        }
        set
        {
            m_AssetBundleInfoDic = value;
        }
    }

    private Dictionary<string, AssetBundleInfoConfig> m_ABExInfoDic;
    public Dictionary<string, AssetBundleInfoConfig> abExInfoDic
    {
        get
        {
            return m_ABExInfoDic;
        }
        set
        {
            m_ABExInfoDic = value;
        }
    }

    private bool m_EditorResourceMode;
    public bool EditorResourceMode
    {
        get
        {
            return m_EditorResourceMode;
        }
        set
        {
            m_EditorResourceMode = value;
        }
    }
    
    public bool hackLoadType;
    public ELoadType loadType;

    public bool hackPersistDataPath;
    public string customPersistDataPath="";

    public ELoadModel GetLoadModelAndLoadAgent(out ILoaderAgent loadAgent)
    {
        ELoadModel loadModel = ELoadModel.AssetBundle;
#if UNITY_EDITOR
        loadModel = LoaderPool.instance.useAssetBundle ? ELoadModel.AssetBundle : ELoadModel.EditorModel;
#endif
        if (loadModel == ELoadModel.AssetBundle)
        {
            loadAgent=new AbLoaderAgent();
        }
        else
        {
            loadAgent = new EditorLoadAgent();
        }
        return loadModel;
    }

    /// <summary>
    /// 通过资源名，查找是否有AssetBundle
    /// </summary>
    /// <param name="assetPath"></param>
    /// <returns></returns>
    public AssetConfig GetAssetConfig(string assetPath)
    {
        if(m_AssetListDict == null)
        {
            m_AssetListDict = new Dictionary<string, AssetConfig>();
            Debug.LogError("AssetList is null");
        }

        AssetConfig assetConfig = null;
        if(m_AssetListDict.TryGetValue(assetPath,out assetConfig))
        {
            return assetConfig;
        }
        else
        {
            Debug.LogError(string.Format("=== AssetList Config con't find : {0}", assetPath));
            return null;
        }
    }

    public bool HasAsset(string assetPath)
    {
        #if UNITY_EDITOR
            if(EditorResourceMode)
            {
                return true;
            }
        #endif

        AssetConfig assetConfig = GetAssetConfig(assetPath);
        return assetConfig != null;
    }

    public AssetBundleInfoConfig GetABInfoConfigByABName(string abName)
    {
        if(m_AssetBundleInfoDic == null)
        {
            //m_AssetBundleInfoDic = new Dictionary<string, AssetBundleInfoConfig>();
            m_AssetBundleInfoDic = new AssetBundleList<AssetBundleInfoConfig>(AssetConst.AB_SUFFIX);
        }

        AssetBundleInfoConfig abInfo = null;
        if(m_AssetBundleInfoDic.TryGetValue(abName,out abInfo))
        {
            return abInfo;
        }
        else
        {
            Debug.LogError(string.Format("=== AssetBundleList Config con't find : {0}",abName));
            return null;
        }
    }
    //================================================================================================================

    public  ELoadType GetDefaultLoadType
    {
        get
        {
            #if UNITY_EDITOR
            if (instance.hackLoadType)
                return instance.loadType;
            #endif
            return ELoadType.StreamingAssets;
        }
    }

    public string GetAssetBundleName(string assetPath)
    {
        string result = string.Empty;
        AssetConfig assetConfig = LoadUtility.instance.GetAssetConfig(assetPath);
        if(assetConfig != null)
        {
            result = assetConfig.AssetBundleName;
        }
        return result;
    }
       
    public string GetAssetBundlePath(string assetBundleName)
    {
        AssetBundleInfoConfig abInfo = GetABInfoConfigByABName(assetBundleName);

        if(abInfo == null)
        {
            return string.Empty;
        }
        return GetAssetBundlePath(assetBundleName, abInfo.LoadType, abInfo.Version);
    }

    public string GetAssetBundlePath(string assetBundleName, ELoadType loadType,string version)
    {
        string assetBundleFullPath = string.Empty;
        switch(loadType)
        {
            case ELoadType.StreamingAssets:
                assetBundleFullPath = GetBundlePathFromStreamingAssets(assetBundleName);
                break;
            case ELoadType.Remote:
                assetBundleFullPath = GetBundlePathFromStorage(assetBundleName,version);
                break;
            default:
                assetBundleFullPath = GetBundlePathFromStreamingAssets(assetBundleName);
                break;
        }
        return assetBundleFullPath;
    }

    public string GenDependkey(string key)
    {
        return string.Format(AssetConst.DEPEND_KEY,key);
    }
    
    public string GenAssetkey(string key)
    {
        return string.Format(AssetConst.ASSET_KEY,key);
    }

    public string GenAssetBundlekey(string assetBundleName)
    {
        return string.Format(AssetConst.ASSETBUNDLE_KEY,assetBundleName);
    }

    public string GenByteskey(string assetBundleName)
    {
        return string.Format(AssetConst.BYTES_KEY,assetBundleName);
    }

    public string GetAssetBundlekey(string assetPath)
    {
        return string.Format(AssetConst.ASSETBUNDLE_KEY, GetAssetConfig(assetPath).AssetBundleName);
    }

    public string GenScenekey(string key)
    {
        return string.Format(AssetConst.SCENE_KEY,key);
    }

    public string GenFilekey(string key)
    {
        return string.Format(AssetConst.FILE_KEY, key);
    }

//=====================================================================================
    public string GetBundlePathFromStorage(string assetBundleName,string version,string dirPath = null)
    {
        assetBundleName = ABUtility.AddSuffix(assetBundleName, AssetConst.AB_SUFFIX);
#if UNITY_EDITOR
        if (hackPersistDataPath)
            dirPath = customPersistDataPath;
#endif
        if (string.IsNullOrEmpty(dirPath))
        {
            dirPath = Application.persistentDataPath;
        }
        return string.Format(AssetConst.AB_PATH_FROM_STORAGE,dirPath,version,assetBundleName);
    }

    public string GetBundlePathFromStreamingAssets(string assetBundleName)
    {
        assetBundleName = ABUtility.AddSuffix(assetBundleName, AssetConst.AB_SUFFIX);
        return string.Format(AssetConst.AB_PATH_FROM_STREAMING,Application.streamingAssetsPath,assetBundleName);
    }

    public string GetRemoteUrl(string assetBundleName,string version)
    {
        assetBundleName = ABUtility.AddSuffix(assetBundleName, AssetConst.AB_SUFFIX);
        return string.Format(AssetConst.AB_URL_PATH,CDNServerURL,version,assetBundleName);
    }

    public string GetRemoteUrl(string assetBundleName,string version,int CDNLineIndex)
    {
        assetBundleName = ABUtility.AddSuffix(assetBundleName, AssetConst.AB_SUFFIX);
        string url = GetCDNServerURL(CDNLineIndex);
        return string.Format(AssetConst.AB_URL_PATH,url,version,assetBundleName);
    }

    public string GetRemoteSubUrl(string assetBundleName,string version)
    {
        assetBundleName = ABUtility.AddSuffix(assetBundleName, AssetConst.AB_SUFFIX);
        return string.Format("/{0}/AssetBundle/{1}",version,assetBundleName);
    }

    
    /// <summary>
    ///  Assets/AssetList.csv
    /// </summary>
    /// <returns></returns>
    public string Get_AssetList_RelativePath()
    {
        return AssetConst.ASSETLIST_UNITY_PATH;
    }

    public string Get_AssetBundleList_RelativePath()
    {
        return AssetConst.ABLIST_UNITY_PATH;
    }

    public string Get_AssetBundleExList_RelativePath()
    {
        return AssetConst.ABEXLIST_UNITY_PATH;
    }

    public string Get_CriwareAB_RelativePath()
    {
        return AssetConst.CRIWARE_DIR;
    }

    public string Get_SLGBGMap_RelativePath()
    {
        return AssetConst.SLG_IMAGE_AB_DIR;
    }

    public string Get_VideosAB_RelativePath()
    {
        return AssetConst.CRIWARE_VEDIO_AB_DIR;
    }

    public string Get_SLGAB_RelativePath()
    {
        return AssetConst.SLG_IMAGE_AB_DIR;
    }

    /*public string Get_SoundsAB_RelativePath()
    {
        return AssetConst.CRIWARE_AUDIO_PATH;
    }*/

    /// <summary>
    /// assetlist
    /// </summary>
    /// <returns></returns>
    public string GetAssetListBundleName()
    {
        return AssetConst.ASSETLIST_AB_NAME;
    }

    public string GetABExListBundleName()
    {
        return AssetConst.ABEXLIST_AB_NAME;
    }



    private int m_CDNLineIndex = 0;
    public string CDNServerURL
    {
        get
        {
            string fileUrl = m_UpdatePrefixUri[m_CDNLineIndex];
            return fileUrl;
        }
       
    }

    public void SwitchCDNURL(bool reset)
    {
        if (reset) 
        {
            m_CDNLineIndex = 0;
        }
        else
        {
            if(!IsCDNLineOverflow(m_CDNLineIndex + 1))
                m_CDNLineIndex++;
        } 
        Debug.LogError("CDN Switch to : " + CDNServerURL);
    }

    public string GetCDNServerURL(int CDNLineIndex)
    {
        if(!IsCDNLineOverflow(CDNLineIndex))
        {
            return m_UpdatePrefixUri[CDNLineIndex];
        }
        return CDNServerURL;
    }

    public bool IsCDNLineOverflow(int CDNLineIndex)
    {
        return CDNLineIndex >= m_UpdatePrefixUri.Length;
    }

    public int GetCDNLineCount()
    {
        if(m_UpdatePrefixUri == null) return 0;
        return m_UpdatePrefixUri.Length;
    }
    
    private string[] m_UpdatePrefixUri;
    public string[] UpdatePrefixUri
    {
        get
        {
            return m_UpdatePrefixUri;
        }
        set
        {
            m_UpdatePrefixUri = value;
        }
    }
 
   

  
}
