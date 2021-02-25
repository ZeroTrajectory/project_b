using System;
using System.Text;
using UnityEngine;
using UnityEngine.Networking;

namespace Core.Load
{
    public class LoadMask
    {
        public const ulong NONE = 0;
        public const ulong PERSIST = 1 << 1;
        public const ulong BATTLE = 1 << 2;
        public const ulong ONLY_ASSET = 1 << 3;  //独立的资源，不依赖其他的ab，一般是大的背景图，配置表之类的，卸载逻辑是走assetpath+mask的模式
        public const ulong BACKHOUSE = 1 << 4;
        public const ulong WORLDMAP = 1 << 5;
        public const ulong WORLDMAPFX = 1 << 6;
        public const ulong SCENE = 1 << 7;
        public const ulong REFCOUNT = 1 << 8; 
        public const ulong WORLD_MAP_STORY = 1 << 9;

        private static ulong m_BitMask = 0ul;

        public static void ResetMask()
        {
            m_BitMask = 0ul;
            LoaderProfiler.Instance.EnqueueLoadMaskOpt(0,LoaderProfiler.ELoadMaskOpt.ResetMask);
        }

        public static ulong AllocMask()
        {
            for (int i = 10; i < 64; i++)
            {
                ulong mask = 1ul << i;
                if ((m_BitMask & mask) == 0)
                {
                    m_BitMask |= mask;
                    LoaderProfiler.Instance.EnqueueLoadMaskOpt(mask,LoaderProfiler.ELoadMaskOpt.AllocMask);
                    return mask;
                }
            }

            Debug.LogError("Alloc Mask is full");
            return 0;
        }

        public static void DeallocMask(ulong mask)
        {
            if (mask != 0)
            {
                m_BitMask &= ~mask;
                LoaderProfiler.Instance.EnqueueLoadMaskOpt(mask,LoaderProfiler.ELoadMaskOpt.DeallocMask);
            }
        }

        public static bool HasMask(ulong mask, ulong hasMask)
        {
            return  (mask & hasMask) !=0;
        }

        public static void UnLoadMask(ref ulong mask, ulong hasMask)
        {
            mask &= ~hasMask;
        }

        public static string BitPrint()
        {
            return bit_print(m_BitMask);
        }

        static string bit_print(ulong a)
        {
            StringBuilder str = new StringBuilder();
            int i;
            int n = sizeof(ulong) * 8;
            ulong mask = 1ul << (n - 1);
            for (i = 1; i <= n; ++i)
            {
                str.Append(((a & mask) == 0) ? '0' : '1');
                a <<= 1;
                if (i % 8 == 0 && i < n)
                    str.Append(' ');
            }

            return str.ToString();
        }
    }
}