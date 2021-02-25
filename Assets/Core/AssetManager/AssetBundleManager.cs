using System;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

namespace Core.Load
{
    public class AssetBundleManager
    {
        private static AssetBundleManager s_instance;
        public static AssetBundleManager instance
        {
            get
            {
                if(s_instance == null)
                {
                    s_instance = new AssetBundleManager();
                }

                return s_instance;
            }
        }
        
        private AssetBundleManifest m_AssetBundleManifest;

       
        public string[] GetAllDependencies(string assetBundleName)
        {
            if(m_AssetBundleManifest == null)
            {
                LoadManifest();
            }

            string[] strs = m_AssetBundleManifest.GetAllDependencies(assetBundleName);
            return strs;
        }

        public bool LoadManifest()
        {
            Debug.Log("load assetbundle manifest!");
            bool isValid = true;

            try 
            {
                string path = LoadUtility.instance.GetAssetBundlePath("AssetBundle");
                AssetBundle manifestAB = AssetBundle.LoadFromFile(path);
                if (m_AssetBundleManifest != null)
                {
                    Resources.UnloadAsset(m_AssetBundleManifest);
                }
                m_AssetBundleManifest = manifestAB.LoadAsset<AssetBundleManifest>("AssetBundleManifest");
                //m_AssetBundleManifest.hideFlags = HideFlags.HideInHierarchy | HideFlags.HideInInspector;
                manifestAB.Unload(false);
            }
            catch(Exception e)
            {
                isValid = false;
                Debug.LogError("Error AssetBundleManager.LoadManifest:" + e.ToString());
            }

            return isValid;
        }

    }

}


