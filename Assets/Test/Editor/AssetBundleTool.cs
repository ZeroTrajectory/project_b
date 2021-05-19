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
        {"/Image","single"},
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
                case "all":
                    CollectDirectory(directoryInfo);
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

    public static void CollectDirectory(DirectoryInfo directoryInfo)
    {
        List<string> fileList = new List<string>();
        string dirFullName = GetRelativePath(directoryInfo.FullName);
        string bundleName = string.Format("{0}{1}",dirFullName,".ab").ToLower();
        CollectFiles(dirFullName,fileList);
        if(fileList.Count  > 0)
        {
            m_assetBundleDic[bundleName] = fileList;
        }
    }

    public static void CollectFiles(string dirFullPath,List<string> fileList)
    {
        DirectoryInfo directoryInfo = new DirectoryInfo(dirFullPath);
        foreach(var fileInfo in directoryInfo.GetFiles())
        {
            string fileRelativePath = GetRelativePath(fileInfo.FullName);
            string extension = Path.GetExtension(fileRelativePath);

            if(extension.Contains(".meta") || extension.Contains(".gitkeep")
            || extension.Contains(".DS_Store"))
            {
                continue;
            }
            if(!fileList.Exists(x => x == fileRelativePath))
            {
                fileList.Add(fileRelativePath);
            }
        }
        
        foreach(var item in directoryInfo.GetDirectories())
        {
            CollectFiles(item.FullName,fileList);
        }
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
