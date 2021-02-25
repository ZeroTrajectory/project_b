/****************************************************************
 * Project: Core.Load
 * File: AssetBundleList.cs
 * Create Date: 2020/12/10
 * Author: gaojiongjiong
 * Descript: AssetBundleList is specially for the list that the 
 * key is ab name.
****************************************************************/

using Core.Load;
using System.Collections.Generic;
using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif

public class AssetBundleList<TValue> : Dictionary<string, TValue>
{
    private string m_Suffix;

    public AssetBundleList(string suffix)
    {
        m_Suffix = suffix;
    }

    public new TValue this[string key]
    {
        get
        {
            return base[AddSuffix(key)];
        }
        set
        {
            base[AddSuffix(key)] = value;
        }
    }

    public new bool ContainsKey(string key)
    {
        return base.ContainsKey(AddSuffix(key));
    }

    public new void Add(string key, TValue value)
    {
        base.Add(AddSuffix(key), value);
    }
    public new bool Remove(string key)
    {
        return base.Remove(AddSuffix(key));
    }

    public new bool TryGetValue(string key, out TValue value)
    {
        return base.TryGetValue(AddSuffix(key), out value);
    }

    private string AddSuffix(string key)
    {
        //if(key.EndsWith(m_Suffix)) return key;
        //if(key.Equals(AssetConst.MANIFEST_AB_NAME)) return key;
        //return key + m_Suffix;
        return ABUtility.AddSuffix(key, m_Suffix);
    }
}

#if UNITY_EDITOR
public class AssetBundleListTester
{
    //[MenuItem("Test/AssetBundleList")]
    public static void Test()
    {
        AssetBundleList<string> list = new AssetBundleList<string>(AssetConst.AB_SUFFIX);
        list["aaa"] = "AAA";
        list["bbb"] = "BBB";
        list["ccc" + AssetConst.AB_SUFFIX] = "CCC";
        foreach(string key in list.Keys)
        {
            Debug.Log(key);
        }
        Debug.Log(list["aaa"]);
        Debug.Log(list["aaa.ab"]);
        Debug.Log(list["ccc"]);
        Debug.Log(list["ccc.ab"]);
    }
}
#endif
