using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;

public class AssetBundleTool
{
    public static string outDir = Application.dataPath + "/Test/TestAB";
    public static Dictionary<string,string> assetDic = new Dictionary<string, string>
    {
        {"/Test/ab/all","all"},
        {"/Test/ab/single","single"},
    };

    public static Dictionary<string,List<string>> m_assetBundleDic = new Dictionary<string, List<string>>();

    [MenuItem("Tools/AssetBundle/打AB")]
    public static void BuildBundleInEditor()
    {
        Clear();
        BuildBundle();
    }
    public static void BuildBundle()
    {   
        foreach(var item in assetDic)
        {
            DirectoryInfo directoryInfo = new DirectoryInfo(Application.dataPath + item.Key);
            switch(item.Value)
            {
                case "single":
                    CollectSingleFile(directoryInfo);
                    break;
            }
        }
        int i = 0;
        AssetBundleBuild[] abb = new AssetBundleBuild[m_assetBundleDic.Count];
        foreach(var item in m_assetBundleDic)
        {
            abb[i].assetBundleName = item.Key;
            abb[i].assetNames = item.Value.ToArray();
            i++;
        }
        if(!Directory.Exists(outDir))
        {
            Directory.CreateDirectory(outDir);
        }
        BuildPipeline.BuildAssetBundles(outDir,abb,BuildAssetBundleOptions.ChunkBasedCompression | BuildAssetBundleOptions.DeterministicAssetBundle,BuildTarget.Android);
    }

    public static void CollectSingleFile(DirectoryInfo directoryInfo)
    {
        FileInfo[] fileInfos = directoryInfo.GetFiles();
        for(int i = 0; i < fileInfos.Length; i++)
        {
            FileInfo info = fileInfos[i];
            string fileRelativePath = GetRelativePath(info.FullName);
            string extension = Path.GetExtension(fileRelativePath);
            if(extension.Equals(".meta"))
            {
                continue;
            }
            string bundleName = fileRelativePath.Replace(extension,".ab").ToLower();
            if(!string.IsNullOrWhiteSpace(fileRelativePath))
            {
                if(m_assetBundleDic.ContainsKey(bundleName))
                {
                    m_assetBundleDic[bundleName].Add(fileRelativePath);
                }
                else
                {
                    m_assetBundleDic[bundleName] = new List<string>{fileRelativePath};
                }
            }
        }
    }

    public static void CollectSubDirectory()
    {

    }

    public static void CollectDirectory()
    {

    }

    public static string GetRelativePath(string fullPath)
    {
        string relativePath = fullPath.Substring(fullPath.IndexOf("Assets"));
        relativePath = relativePath.Replace('\\','/');
        return relativePath;
    }

    public static void Clear()
    {
        m_assetBundleDic.Clear();
    }
}
