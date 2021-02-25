using System;
using Core.Load;
using UnityEngine;

namespace Core.Load
{
    public interface ILoader
    {
        string loadSign { get; }
        string assetPath {get;}
        bool isDone{get;}
        string key{get;}
        float progress{get;}
        ulong refMask{get;}
        void AddMask(ulong mask);
        void RemoveMask(ulong mask);
        ELoadStatus loadStatus {get;}
        void OnUpdate();
        float Unload();
        void LoadAsync<T>() where T : UnityEngine.Object;
        void LoadAsync();
        string IdentityKey();
        void OnDestroy();
        bool IsValid();
    }
}