/*ABObject相当于一个AB加载器，一个object对应一个AB，具有以下职能
1.记录AB的引用计数
2.记录AB的加载实例
3.记录AB加载的回调
4.记录AB的依赖AB
*/
using System.Collections.Generic;
using UnityEngine;

namespace Core.Load 
{
    enum LoadStatus
    {
        Wait,
        Loading,
        Loaded,
        WaitDelete,
        Deleted,
    }
    public class ABObject
    {
        private LoadStatus _status;
        private int _refCount;
        private AssetBundle _ab;
        private List<ABObject> _depends = new List<ABObject>();
    }
}

