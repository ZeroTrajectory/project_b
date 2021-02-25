using System.Collections.Generic;
using System.IO;
using System.Text;
using UnityEditor;
using UnityEngine;
public class ResourceUseUtility
{
    private static ResourceUseUtility _instance;
    public static ResourceUseUtility instance
    {
        get
        {
            if(_instance == null)
            {
                _instance = new ResourceUseUtility();
            }
            return _instance;
        }
    }

    private Dictionary<string,string> _assetUseDict = new Dictionary<string,string>(); //使用到的资源
    public void AddResource(string assetPath)
    {
        Debug.Log("收集：" + assetPath);
        _assetUseDict[assetPath] = assetPath;
    }

    public void Save()
    {
#if UNITY_EDITOR
        _LoadRecord();
        StringBuilder assetUseListSB = new StringBuilder();
        foreach(var item in _assetUseDict)
        {
            assetUseListSB.AppendLine(item.Value);
        }
        string outPath = Get_AssetUseList_FullPath();
        using(FileStream fs = new FileStream(outPath,FileMode.Create))
        {
            byte[] bytes = Encoding.Default.GetBytes(assetUseListSB.ToString());
            fs.Write(bytes,0,bytes.Length);
            fs.Flush();
        }

        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
#endif
    }

    private void _LoadRecord()
    {
        string readPath = Get_AssetUseList_FullPath();
        if(File.Exists(readPath))
        {
            string s =  File.ReadAllText(readPath);               
            StringReader sr = new StringReader(s);
            while(sr.Peek() >= 0)
            {
                string line = sr.ReadLine();
                _assetUseDict[line] = line;
            }
        }
    }

    


    public static string Get_AssetUseList_FullPath()
    {
        return Application.dataPath + "/AssetUseList.csv";
    }
}

