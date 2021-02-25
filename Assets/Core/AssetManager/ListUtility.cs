using System;
using System.Collections.Generic;
using UnityEngine;

public class ListUtility
{
    private static ListUtility _instance;
    public static ListUtility instance
    {
        get
        {
            if(_instance == null)
            {
                _instance = new ListUtility();
            }

            return _instance;
        }
    }
    

    public void FindAll<T>(List<T> search,List<T> result,Predicate<T> match) 
    { 
        if( match == null) 
        {
            Debug.LogError("match is null");
            return;
        }
        result.Clear();
        for(int i = 0 ; i < search.Count; i++) {
            if(match(search[i])) {
                result.Add(search[i]);
            }
        }
    }
}
