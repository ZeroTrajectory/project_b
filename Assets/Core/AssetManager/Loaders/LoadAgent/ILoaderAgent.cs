using System;
using Object = UnityEngine.Object;

namespace Core.Load
{
   
    
    public interface ILoaderAgent
    {
        void StartLoad(string key,string assetPath, Type assetType,Action<Object,string> onLoad);
        void OnUpdate();
        void UpdateMask(ulong mask);
        void AddMask(ulong mask);
        void RemoveMask(ulong mask);
        void UnLoad();
    }
}

