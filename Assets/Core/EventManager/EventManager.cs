using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace Core
{
    public class EventManager : MonoBehaviour
    {
        private static EventManager _instance;
        public static EventManager instance
        {
            get
            {
                return _instance;
            }
        }

        private Dictionary<string,LinkedList<Action<object>>> m_eventPool;

        private void Awake() 
        {
            _instance = this;   
        }

        public void Register(string eventName,Action<object> eventCallback)
        {
            if(m_eventPool.ContainsKey(eventName))
            {
                var linkedList = m_eventPool[eventName];
                linkedList.AddFirst(eventCallback);
            }
            else
            {
                var linkedList = new LinkedList<Action<object>>();
                linkedList.AddFirst(eventCallback);
                m_eventPool.Add(eventName,linkedList);
            }
        }

        public void UnRegister(string eventName,Action<object> eventCallback)
        {
            if(m_eventPool.ContainsKey(eventName))
            {
                var linkedList = m_eventPool[eventName];
                linkedList.Remove(eventCallback);
                if(linkedList.Count == 0)
                {
                    m_eventPool.Remove(eventName);
                }
            }
            else
            {
                Debug.LogWarningFormat("Remove event {0} is not exsit!",eventName);
            }
        }

        public void Notify(string eventName,object obj)
        {
            foreach(var linkedList in m_eventPool)
            {
                foreach(var callback in linkedList.Value)
                {
                    callback?.Invoke(obj);
                }
            }
        }
    }
}