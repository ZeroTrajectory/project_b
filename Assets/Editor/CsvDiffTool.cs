using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;
using UnityEditor;
using UnityEngine;

public class CsvDiffTool
{
    public static string outPath = Application.dataPath + "/Test";
    public static string csvA = outPath + "/A.csv";
    public static string csvB = outPath + "/B.csv";

    public static Dictionary<string,string> aDic = new Dictionary<string, string>();
    public static Dictionary<string,string> bDic = new Dictionary<string, string>();
    public static StringBuilder stringBuilder = new StringBuilder();
    [MenuItem("Tools/A比B多的")]
    public static void CompareAandB()
    {
        Compare();
        CompareDic(aDic,bDic,outPath+"/A比B多的.csv");
    }
    [MenuItem("Tools/B比A多的")]
    public static void CompareBandA()
    {
        Compare();
        CompareDic(bDic,aDic,outPath+"/B比A多的.csv");
    }

    [MenuItem("Tools/CsvDiffTool")]
    public static void Compare()
    {
        aDic.Clear();
        bDic.Clear();
        string aContent = System.IO.File.ReadAllText(csvA);
        string bContent = System.IO.File.ReadAllText(csvB);
        ParseCsv(aContent,aDic);
        ParseCsv(bContent,bDic);
    }

    public static void ParseCsv(string content,Dictionary<string,string> dic)
    {
        StringReader sr = new StringReader(content);
        int i = 0;
        while(sr.Peek() >= 0)
        {
            i++;
            string line = sr.ReadLine();
            if(string.IsNullOrEmpty(line) || i <= 1)
            {
                continue;
            }
            string[] splits = line.Split(',');
            string tb = splits[1];
            if(string.IsNullOrEmpty(tb))
            {
                tb = splits[5];
            }
            if(dic.ContainsKey(tb))
            {
                dic[string.Format("({0}){1}",i,tb)] = line;
            }
            else
            {
                dic[tb] = line;
            }
        }
    }

    public static void CompareDic(Dictionary<string,string> dic1,Dictionary<string,string> dic2,string outPath)
    {
        stringBuilder.Clear();
        foreach(var cell in dic1)
        {
            if(!dic2.ContainsKey(cell.Key))
            {
                stringBuilder.AppendLine(cell.Value);
            }
        }
        FileOutTool.OutPutFile(outPath,stringBuilder.ToString());
    }
}
