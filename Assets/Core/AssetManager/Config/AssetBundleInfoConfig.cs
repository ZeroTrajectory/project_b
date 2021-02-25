using System;
using System.Collections.Generic;
using System.IO;
using Core.Load;
using UnityEngine;

public class AssetBundleInfoConfig
{
    public string AssetBundleName;
    public string AssetBundleVariant;
    public string Version;
    public ELoadType LoadType;
    public string BundleHash;
    public float BundleSize;

    public string WriteLine()
    {
        return string.Format("{0},{1},{2},{3},{4},{5}",AssetBundleName,AssetBundleVariant,Version,(int)LoadType,BundleHash,BundleSize);
    }

    private void ParseLine(string line)
    {
        if (string.IsNullOrEmpty(line))
        {
            return;
        }

        string[] splits = line.Split(',');

        if(splits.Length < 6)
        {
            //GameFrameworkInfo.LogError(line);
            return;
        }
     
        AssetBundleName = splits[0];
        AssetBundleVariant = splits[1];
        Version = splits[2];
        LoadType = (ELoadType)Convert.ToInt32(splits[3]);
#if UNITY_EDITOR
        if (LoadUtility.instance != null && LoadUtility.instance.hackLoadType)
        {
            LoadType = LoadUtility.instance.loadType;
        }
#endif
        BundleHash = splits[4];
        BundleSize = Convert.ToSingle(splits[5]);
    }

    //public static Dictionary<string, AssetBundleInfoConfig> Parse(string content)
    public static AssetBundleList<AssetBundleInfoConfig> Parse(string content)
    {
        StringReader sr = new StringReader(content);
        //Dictionary<string, AssetBundleInfoConfig> dict = new Dictionary<string, AssetBundleInfoConfig>();
        AssetBundleList<AssetBundleInfoConfig> dict = new AssetBundleList<AssetBundleInfoConfig>(AssetConst.AB_SUFFIX);

        int i = 0;
        while(sr.Peek() >= 0)
        {
            i++;
            string line = sr.ReadLine();
            if (string.IsNullOrEmpty(line) || i <=1)
            {
                continue;
            }

            AssetBundleInfoConfig ac = new AssetBundleInfoConfig();
            ac.ParseLine(line);

            if (string.IsNullOrEmpty(ac.AssetBundleName))
            {
                continue;
            }

            if (dict.ContainsKey(ac.AssetBundleName))
            {
                dict[ac.AssetBundleName] = ac;
            }
            else
            {
                dict.Add(ac.AssetBundleName,ac);
            }
        }

        return dict;
    }

    
}

//public class AssetBundleDownloadConfig : AssetBundleInfoConfig
//{
//    public float FileBytes
//    {
//        get => BundleSize * 1024;
//    }
//    public float DownloadedBytes { get; set; } = 0.0f;
//}