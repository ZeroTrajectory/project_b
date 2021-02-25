/****************************************************************
 * Project: Core.Load
 * File: ABUtility.cs
 * Create Date: 2020/12/11
 * Author: gaojiongjiong
 * Descript: AssetBundle Utilities.
****************************************************************/

using Core.Load;

public static class ABUtility
{
    public static string AddSuffix(string name, string suffix)
    {
        if(name.EndsWith(suffix)) return name;
        if(name.EndsWith(AssetConst.MANIFEST_AB_NAME)) return name;
        return name + suffix;
    }
}
