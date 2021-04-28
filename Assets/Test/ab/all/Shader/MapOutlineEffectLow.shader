// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

// Unlit alpha-blended shader.
// - no lighting
// - no lightmap support
// - no per-material color

Shader "DarkBoom/MapOutlineEffectLow" {
    Properties{
        _MainTex("Base (RGB) Trans (A)", 2D) = "white" {}
        [HideInInspector]
        _EdgeColor("Edge Color", Color) = (1,0,0,1)									//边界颜色

        // Solution 1
        [Header(Solution 1)]
        _EdgeAlphaThreshold("Edge Alpha Threshold", Float) = 1.0					//边界透明度和的阈值
        _EdgeDampRate("Edge Damp Rate", Float) = 2.0									//边缘渐变的分母
        _OriginAlphaThreshold("OriginAlphaThreshold", range(0.1, 1)) = 0.2			//原始颜色透明度剔除的阈值
        _Thin("Thin", range(0.1, 10.0)) = 1.0

        _MainTex2("Base (RGB) Trans (A)", 2D) = "white" {}
        _MainTex3("Base (RGB) Trans (A)", 2D) = "white" {}
        _MainTex4("Base (RGB) Trans (A)", 2D) = "white" {}
        _MainTex5("Base (RGB) Trans (A)", 2D) = "white" {}
        _MainTex6("Base (RGB) Trans (A)", 2D) = "white" {}
        _MainTex7("Base (RGB) Trans (A)", 2D) = "white" {}

        [HideInInspector]
        _EdgeColor2("Edge Color", Color) = (1,0,0,1)									//边界颜色
        [HideInInspector]
        _EdgeColor3("Edge Color", Color) = (1,0,0,1)									//边界颜色
        [HideInInspector]
        _EdgeColor4("Edge Color", Color) = (1,0,0,1)									//边界颜色
        [HideInInspector]
        _EdgeColor5("Edge Color", Color) = (1,0,0,1)									//边界颜色
        [HideInInspector]
        _EdgeColor6("Edge Color", Color) = (1,0,0,1)									//边界颜色
        [HideInInspector]
        _EdgeColor7("Edge Color", Color) = (1,0,0,1)									//边界颜色
    }

    SubShader {
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
        LOD 100

        CGINCLUDE
            #include "UnityCG.cginc"

            struct appdata_t {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f1 {
                float4 vertex : SV_POSITION;
                float2 uv[9] : TEXCOORD0;
            };

            struct v2f2 {
                float4 vertex : SV_POSITION;
                float2 texcoord : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half4 _MainTex_TexelSize;

            // Solution 1
            fixed _EdgeAlphaThreshold;
            fixed4 _EdgeColor;
            float _EdgeDampRate;
            float _OriginAlphaThreshold;
            float _Thin;

            sampler2D _MainTex2;
            float4 _MainTex2_ST;
            half4 _MainTex2_TexelSize;
            sampler2D _MainTex3;
            float4 _MainTex3_ST;
            half4 _MainTex3_TexelSize;
            sampler2D _MainTex4;
            float4 _MainTex4_ST;
            half4 _MainTex4_TexelSize;
            sampler2D _MainTex5;
            float4 _MainTex5_ST;
            half4 _MainTex5_TexelSize;
            sampler2D _MainTex6;
            float4 _MainTex6_ST;
            half4 _MainTex6_TexelSize;
            sampler2D _MainTex7;
            float4 _MainTex7_ST;
            half4 _MainTex7_TexelSize;

            fixed4 _EdgeColor2;
            fixed4 _EdgeColor3;
            fixed4 _EdgeColor4;
            fixed4 _EdgeColor5;
            fixed4 _EdgeColor6;
            fixed4 _EdgeColor7;

            half CalculateAlphaSumAround1(v2f1 i)
            {
                half texAlpha;
                half alphaSum = 0;

                for (int it = 0; it < 9; it++)
                {
                    texAlpha = tex2D(_MainTex, i.uv[it]).w;
                    alphaSum += texAlpha;
                }

                return alphaSum;

                //alphaSum += tex2D(_MainTex, i.texcoord + half2(-0.01, -0.01) * _OutlineSize * 0.7).a;
                //alphaSum += tex2D(_MainTex, i.texcoord + half2(0, -0.01) * _OutlineSize).a;
                //alphaSum += tex2D(_MainTex, i.texcoord + half2(0.01, -0.01) * _OutlineSize * 0.7).a;
                //alphaSum += tex2D(_MainTex, i.texcoord + half2(-0.01, 0) * _OutlineSize).a;
                //alphaSum += tex2D(_MainTex, i.texcoord + half2(0, 0) * _OutlineSize).a;
                //alphaSum += tex2D(_MainTex, i.texcoord + half2(0.01, 0) * _OutlineSize).a;
                //alphaSum += tex2D(_MainTex, i.texcoord + half2(-0.01, 0.01) * _OutlineSize * 0.7).a;
                //alphaSum += tex2D(_MainTex, i.texcoord + half2(0, 0.01) * _OutlineSize).a;
                //alphaSum += tex2D(_MainTex, i.texcoord + half2(0.01, 0.01) * _OutlineSize * 0.7).a;

                //alphaSum += tex2D(_MainTex, i.texcoord + half2(0, -0.01) * _OutlineSize).a;
                //alphaSum += tex2D(_MainTex, i.texcoord + half2(-0.01, 0) * _OutlineSize).a;
                //alphaSum += 4.0 * tex2D(_MainTex, i.texcoord + half2(0, 0) * _OutlineSize).a;
                //alphaSum += tex2D(_MainTex, i.texcoord + half2(0.01, 0) * _OutlineSize).a;
                //alphaSum += tex2D(_MainTex, i.texcoord + half2(0, 0.01) * _OutlineSize).a;
            }

            half CalculateAlphaSumAround11(v2f1 i, sampler2D _tex)
            {
                half texAlpha;
                half alphaSum = 0;

                for (int it = 0; it < 9; it++)
                {
                    texAlpha = tex2D(_tex, i.uv[it]).w;
                    alphaSum += texAlpha;
                }

                return alphaSum;
            }

            half CalculateAlphaSumAround12(v2f1 i, sampler2D _tex, half alpha)
            {
                half texAlpha;
                half alphaSum = alpha;

                for (int it = 0; it < 8; it++)
                {
                    texAlpha = tex2D(_tex, i.uv[it]).w;
                    alphaSum += texAlpha;
                }

                return alphaSum;
            }

            half CalculateAlphaSumAround2(v2f2 i, float radius)
            {
                half texAlpha;
                half alphaSum = 0;


                //float cnt = _LookupCnt;
                float cnt = 8;
                float perAngle = 2 * 3.14 / cnt;
                for (int j = 0; j < cnt; j++)
                {
                    float2 uv = i.texcoord + radius * float2(cos(perAngle * j), sin(perAngle * j));
                    alphaSum += tex2D(_MainTex, uv).a;
                }

                return alphaSum / cnt;
            }

            // Solution 1
            v2f1 vert1(appdata_t v)
            {
                v2f1 o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                half2 uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv[0] = uv + _MainTex_TexelSize.xy * half2(-1, -1);
                o.uv[1] = uv + _MainTex_TexelSize.xy * half2(0, -1);
                o.uv[2] = uv + _MainTex_TexelSize.xy * half2(1, -1);
                o.uv[3] = uv + _MainTex_TexelSize.xy * half2(-1, 0);
                o.uv[4] = uv + _MainTex_TexelSize.xy * half2(0, 0);
                o.uv[5] = uv + _MainTex_TexelSize.xy * half2(1, 0);
                o.uv[6] = uv + _MainTex_TexelSize.xy * half2(-1, 1);
                o.uv[7] = uv + _MainTex_TexelSize.xy * half2(0, 1);
                o.uv[8] = uv + _MainTex_TexelSize.xy * half2(1, 1);
                return o;
            }

            v2f1 vert2(appdata_t v)
            {
                v2f1 o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                half2 uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv[0] = uv + _MainTex_TexelSize.xy * half2(-1, -1);
                o.uv[1] = uv + _MainTex_TexelSize.xy * half2(0, -1);
                o.uv[2] = uv + _MainTex_TexelSize.xy * half2(1, -1);
                o.uv[3] = uv + _MainTex_TexelSize.xy * half2(-1, 0);
                o.uv[4] = uv + _MainTex_TexelSize.xy * half2(1, 0);
                o.uv[5] = uv + _MainTex_TexelSize.xy * half2(-1, 1);
                o.uv[6] = uv + _MainTex_TexelSize.xy * half2(0, 1);
                o.uv[7] = uv + _MainTex_TexelSize.xy * half2(1, 1);
                o.uv[8] = uv + _MainTex_TexelSize.xy * half2(0, 0);
                return o;
            }

            v2f1 vert3(appdata_t v)
            {
                v2f1 o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                half2 uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv[0] = uv + _MainTex_TexelSize.xy * half2(-1, -1) * _Thin;
                o.uv[1] = uv + _MainTex_TexelSize.xy * half2(0, -1) * _Thin;
                o.uv[2] = uv + _MainTex_TexelSize.xy * half2(1, -1) * _Thin;
                o.uv[3] = uv + _MainTex_TexelSize.xy * half2(-1, 0) * _Thin;
                o.uv[4] = uv + _MainTex_TexelSize.xy * half2(1, 0) * _Thin;
                o.uv[5] = uv + _MainTex_TexelSize.xy * half2(-1, 1) * _Thin;
                o.uv[6] = uv + _MainTex_TexelSize.xy * half2(0, 1) * _Thin;
                o.uv[7] = uv + _MainTex_TexelSize.xy * half2(1, 1) * _Thin;
                o.uv[8] = uv + _MainTex_TexelSize.xy * half2(0, 0) * _Thin;
                return o;
            }

            //fixed4 frag1(v2f1 i) : SV_Target
            //{
            //    //fixed4 col = tex2D(_MainTex, i.texcoord);
            //    half alphaSum = CalculateAlphaSumAround1(i);
            //    float isNeedShow = alphaSum > _EdgeAlphaThreshold;
            //    float damp = saturate((alphaSum - _EdgeAlphaThreshold) * _EdgeDampRate);
            //    fixed4 origin = tex2D(_MainTex, i.uv[4]);
            //    //fixed4 origin = tex2D(_MainTex, i.texcoord);
            //    float isOrigin = origin.a > _OriginAlphaThreshold;
            //    fixed3 finalColor = lerp(_EdgeColor.rgb, origin.rgb, isOrigin);

            //    return fixed4(finalColor.rgb * isNeedShow, isNeedShow * damp);
            //    //return fixed4(finalColor.rgb, isNeedShow);
            //    //return fixed4(origin.rgb, isNeedShow);
            //    //return fixed4(_EdgeColor.rgb, tex2D(_MainTex, i.uv[4]).a);
            //}

            fixed4 frag2(v2f1 i) : SV_Target
            {
                half alphaSum = CalculateAlphaSumAround11(i, _MainTex);
                half alphaSum2 = CalculateAlphaSumAround11(i, _MainTex2);
                half alphaSum3 = CalculateAlphaSumAround11(i, _MainTex3);
                half alphaSum4 = CalculateAlphaSumAround11(i, _MainTex4);
                half alphaSum5 = CalculateAlphaSumAround11(i, _MainTex5);
                half alphaSum6 = CalculateAlphaSumAround11(i, _MainTex6);

                //float isNeedShow = alphaSum > _EdgeAlphaThreshold;
                //float damp = saturate((alphaSum - _EdgeAlphaThreshold) * _EdgeDampRate);
                //fixed4 origin = tex2D(_MainTex, i.uv[4]);
                //float isOrigin = origin.a > _OriginAlphaThreshold;
                //fixed3 finalColor = lerp(_EdgeColor.rgb, origin.rgb, isOrigin);

                //return fixed4(finalColor.rgb * isNeedShow, isNeedShow * damp);

                float isNeedShow = alphaSum > _EdgeAlphaThreshold;
                float damp = saturate((alphaSum - _EdgeAlphaThreshold) * _EdgeDampRate);
                fixed4 origin = tex2D(_MainTex, i.uv[4]);
                float isOrigin = origin.a > _OriginAlphaThreshold;
                fixed3 finalColor = lerp(_EdgeColor.rgb, fixed3(0, 0, 0), isOrigin);

                return fixed4(finalColor.rgb * isNeedShow, isNeedShow * damp * (1 - isOrigin));
            }

            fixed4 frag21(v2f1 i) : SV_Target
            {
                half alphaSum = CalculateAlphaSumAround11(i, _MainTex);
                half alphaSum2 = CalculateAlphaSumAround11(i, _MainTex2);
                half alphaSum3 = CalculateAlphaSumAround11(i, _MainTex3);
                half alphaSum4 = CalculateAlphaSumAround11(i, _MainTex4);
                half alphaSum5 = CalculateAlphaSumAround11(i, _MainTex5);
                half alphaSum6 = CalculateAlphaSumAround11(i, _MainTex6);

                float isNeedShow = alphaSum > _EdgeAlphaThreshold;
                float damp = saturate((alphaSum - _EdgeAlphaThreshold) * _EdgeDampRate);
                fixed4 origin = tex2D(_MainTex, i.uv[4]);
                float isOrigin = origin.a > _OriginAlphaThreshold;
                fixed3 finalColor = lerp(_EdgeColor.rgb, fixed3(0, 0, 0), isOrigin);

                //return fixed4(finalColor.rgb * isNeedShow, isNeedShow * damp * (1 - isOrigin))
                //    * (1 - alphaSum2) * (1 - alphaSum3) * (1 - alphaSum4) * (1 - alphaSum5) * (1 - alphaSum6);
                return fixed4(finalColor.rgb * isNeedShow, isNeedShow * damp * (1 - isOrigin));
            }

            fixed4 CalcColor(v2f1 i, sampler2D _tex)
            {
                half alphaSum = CalculateAlphaSumAround11(i, _tex);

                float isNeedShow = alphaSum > _EdgeAlphaThreshold;
                float damp = saturate((alphaSum - _EdgeAlphaThreshold) * _EdgeDampRate);
                fixed4 origin = tex2D(_tex, i.uv[4]);
                float isOrigin = origin.a > _OriginAlphaThreshold;
                fixed3 finalColor = lerp(_EdgeColor.rgb, fixed3(0, 0, 0), isOrigin);

                return fixed4(finalColor.rgb * isNeedShow, isNeedShow * damp * (1 - isOrigin));
            }

            fixed4 CalcColor2(v2f1 i, sampler2D _tex, fixed4 edgeColor)
            {
                half alphaSum = CalculateAlphaSumAround11(i, _tex);

                float isNeedShow = alphaSum > _EdgeAlphaThreshold;
                float damp = saturate((alphaSum - _EdgeAlphaThreshold) * _EdgeDampRate);
                fixed4 origin = tex2D(_tex, i.uv[4]);
                float isOrigin = origin.a > _OriginAlphaThreshold;
                fixed3 finalColor = lerp(edgeColor.rgb, fixed3(0, 0, 0), isOrigin);

                return fixed4(finalColor.rgb * isNeedShow, isNeedShow * damp * (1 - isOrigin));
            }

            fixed4 CalcColor3(v2f1 i, sampler2D _tex, fixed4 edgeColor)
            {
                fixed4 color = fixed4(0, 0, 0, 0);

                fixed4 origin = tex2D(_tex, i.uv[8]);

                if (origin.r > 0.01)
                {
                    half alphaSum = CalculateAlphaSumAround12(i, _tex, origin.a);

                    float isNeedShow = alphaSum > _EdgeAlphaThreshold;
                    float damp = saturate((alphaSum - _EdgeAlphaThreshold) * _EdgeDampRate);
                    //fixed4 origin = tex2D(_tex, i.uv[4]);
                    float isOrigin = origin.a > _OriginAlphaThreshold;
                    fixed3 finalColor = lerp(edgeColor.rgb, fixed3(0, 0, 0), isOrigin);

                    color = fixed4(finalColor.rgb * isNeedShow, isNeedShow * damp * (1 - isOrigin));
                }

                return color;
            }

            fixed4 CalcColor4(v2f1 i, sampler2D _tex, fixed4 edgeColor)
            {
                fixed4 color = fixed4(0, 0, 0, 0);

                fixed4 origin = tex2D(_tex, i.uv[8]);

                if (origin.r > -0.01)
                {
                    half alphaSum = CalculateAlphaSumAround12(i, _tex, origin.a);

                    float isNeedShow = alphaSum > _EdgeAlphaThreshold;
                    float damp = saturate((alphaSum - _EdgeAlphaThreshold) * _EdgeDampRate);
                    //fixed4 origin = tex2D(_tex, i.uv[4]);
                    float isOrigin = origin.a > _OriginAlphaThreshold;
                    fixed3 finalColor = lerp(edgeColor.rgb, fixed3(0, 0, 0), origin.a);

                    color = fixed4(finalColor.rgb * isNeedShow, isNeedShow * damp * (1 - origin.a));
                }

                return color;
            }

            fixed4 frag3(v2f1 i) : SV_Target
            {
                fixed4 color = CalcColor(i, _MainTex6);

                //fixed4 color2;
                //if (color.a < 0.1)
                //{
                //    color2 = CalcColor(i, _MainTex5);
                //    color = lerp(color, color2, color2.a);
                //}
                //if (color.a < 0.1)
                //{
                //    color2 = CalcColor(i, _MainTex4);
                //    color = lerp(color, color2, color2.a);
                //}
                //if (color.a < 0.1)
                //{
                //    color2 = CalcColor(i, _MainTex3);
                //    color = lerp(color, color2, color2.a);
                //}
                //if (color.a < 0.1)
                //{
                //    color2 = CalcColor(i, _MainTex2);
                //    color = lerp(color, color2, color2.a);
                //}
                //if (color.a < 0.1)
                //{
                //    color2 = CalcColor(i, _MainTex);
                //    color = lerp(color, color2, color2.a);
                //}

                fixed4 color2 = CalcColor(i, _MainTex5);
                color = lerp(color, color2, color2.a);
                color2 = CalcColor(i, _MainTex4);
                color = lerp(color, color2, color2.a);
                color2 = CalcColor(i, _MainTex3);
                color = lerp(color, color2, color2.a);
                color2 = CalcColor(i, _MainTex2);
                color = lerp(color, color2, color2.a);
                color2 = CalcColor(i, _MainTex);
                color = lerp(color, color2, color2.a);
                return color;
            }

            fixed4 frag4(v2f1 i) : SV_Target
            {
                fixed4 color = CalcColor2(i, _MainTex6, _EdgeColor6);
                fixed4 color2 = CalcColor2(i, _MainTex5, _EdgeColor5);
                color = lerp(color, color2, color2.a);
                color2 = CalcColor2(i, _MainTex4, _EdgeColor4);
                color = lerp(color, color2, color2.a);
                color2 = CalcColor2(i, _MainTex3, _EdgeColor3);
                color = lerp(color, color2, color2.a);
                color2 = CalcColor2(i, _MainTex2, _EdgeColor2);
                color = lerp(color, color2, color2.a);
                color2 = CalcColor2(i, _MainTex, _EdgeColor);
                color = lerp(color, color2, color2.a);
                return color;
            }

            fixed4 frag5(v2f1 i) : SV_Target
            {
                fixed4 color = CalcColor2(i, _MainTex7, _EdgeColor7);
                fixed4 color2 = CalcColor2(i, _MainTex6, _EdgeColor6);
                fixed aa = 0.1;
                color = lerp(color, color2, color.a < aa);
                color2 = CalcColor2(i, _MainTex5, _EdgeColor5);
                color = lerp(color, color2, color.a < aa);
                color2 = CalcColor2(i, _MainTex4, _EdgeColor4);
                color = lerp(color, color2, color.a < aa);
                color2 = CalcColor2(i, _MainTex3, _EdgeColor3);
                color = lerp(color, color2, color.a < aa);
                color2 = CalcColor2(i, _MainTex2, _EdgeColor2);
                color = lerp(color, color2, color.a < aa);
                color2 = CalcColor2(i, _MainTex, _EdgeColor);
                color = lerp(color, color2, color.a < aa);
                return color;
            }

            fixed4 frag6(v2f1 i) : SV_Target
            {
                fixed4 color = CalcColor3(i, _MainTex7, _EdgeColor7);
                fixed4 color2 = CalcColor3(i, _MainTex6, _EdgeColor6);
                fixed aa = 0.1;
                color = lerp(color, color2, color.a < aa);
                color2 = CalcColor3(i, _MainTex5, _EdgeColor5);
                color = lerp(color, color2, color.a < aa);
                color2 = CalcColor3(i, _MainTex4, _EdgeColor4);
                color = lerp(color, color2, color.a < aa);
                color2 = CalcColor3(i, _MainTex3, _EdgeColor3);
                color = lerp(color, color2, color.a < aa);
                color2 = CalcColor3(i, _MainTex2, _EdgeColor2);
                color = lerp(color, color2, color.a < aa);
                color2 = CalcColor3(i, _MainTex, _EdgeColor);
                color = lerp(color, color2, color.a < aa);
                return color;
            }

            fixed4 frag7(v2f1 i) : SV_Target
            {
                fixed4 color = CalcColor4(i, _MainTex7, _EdgeColor7);
                fixed4 color2 = CalcColor4(i, _MainTex6, _EdgeColor6);
                fixed aa = 0.1;
                color = lerp(color, color2, color2.a);
                color2 = CalcColor4(i, _MainTex5, _EdgeColor5);
                color = lerp(color, color2, color2.a);
                color2 = CalcColor4(i, _MainTex4, _EdgeColor4);
                color = lerp(color, color2, color2.a);
                color2 = CalcColor4(i, _MainTex3, _EdgeColor3);
                color = lerp(color, color2, color2.a);
                color2 = CalcColor4(i, _MainTex2, _EdgeColor2);
                color = lerp(color, color2, color2.a);
                color2 = CalcColor4(i, _MainTex, _EdgeColor);
                color = lerp(color, color2, color2.a);
                return color;
            }

        ENDCG

        // Pass 0
        Pass {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
                #pragma vertex vert2
                #pragma fragment frag6
                #pragma target 2.0
                #pragma multi_compile_fog
            ENDCG
        }

        // Pass 1
        Pass {
            ZWrite Off
            //Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
                #pragma vertex vert3
                #pragma fragment frag6
                #pragma target 2.0
                #pragma multi_compile_fog
            ENDCG
        }
    }
}
