
using System;
using System.Collections.Generic;
using System.IO;
using Core.Load;
using UnityEngine;

public class AssetConfig
{
    public string AssetPath;
    public string AssetBundleName;
    public string AssetMD5Hash;
    public string Version;
    // public string AssetBundleVariant;
    // public string Version;
    // public ELoadType LoadType;
    // public string BundleHash;
    // public float BundleSize;


    private void ParseLine(string line)
    {
        if (string.IsNullOrEmpty(line))
        {
            return;
        }

        string[] splits = line.Split(',');

        if(splits.Length < 2)
        {
            Debug.LogError(line);
            return;
        }

        AssetPath = splits[0];
        AssetBundleName = splits[1];
        AssetMD5Hash = splits[2];
        Version = splits[3];
        // AssetBundleVariant = splits[2];
        // Version = splits[3];
        // LoadType = (ELoadType)Convert.ToInt32(splits[4]);
        // BundleHash = splits[5];
        // BundleSize = Convert.ToSingle(splits[6]);
    }

    public string WriteLine()
    {
        //return string.Format("{0},{1},{2},{3},{4},{5},{6}",AssetPath,AssetBundleName,AssetBundleVariant,Version,(int)LoadType,BundleHash,BundleSize);
        string metafilePath = AssetPath + ".meta";
        string md5 = string.Empty;
        if (File.Exists(metafilePath))
            md5 = MD5Utility.GetFileMD5Hash(metafilePath);
        return string.Format("{0},{1},{2},{3},{4}",AssetPath,AssetBundleName,AssetMD5Hash,Version,md5);
    }

    public static Dictionary<string, AssetConfig> Parse(string content)
    {
        StringReader sr = new StringReader(content);
        Dictionary<string, AssetConfig> dict = new Dictionary<string, AssetConfig>();

        int i = 0;
        while(sr.Peek() >= 0)
        {
            i++;
            string line = sr.ReadLine();
            if (string.IsNullOrEmpty(line) || i <=1)
            {
                continue;
            }

            AssetConfig ac = new AssetConfig();
            ac.ParseLine(line);

            if (string.IsNullOrEmpty(ac.AssetPath))
            {
                continue;
            }

            if (dict.ContainsKey(ac.AssetPath))
            {
                dict[ac.AssetPath] = ac;
            }
            else
            {
                dict.Add(ac.AssetPath,ac);
            }
        }

        return dict;
    }

}
