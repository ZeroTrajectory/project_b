// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

// Unlit alpha-blended shader.
// - no lighting
// - no lightmap support
// - no per-material color

Shader "DarkBoom/MapOutlineEffect" {
    Properties{
        _MainTex("Base (RGB) Trans (A)", 2D) = "white" {}
        _EdgeColor("Edge Color", Color) = (1,0,0,1)									//边界颜色

        // Solution 1
        [Header(Solution 1)]
        _EdgeAlphaThreshold("Edge Alpha Threshold", Float) = 1.0					//边界透明度和的阈值
        _EdgeDampRate("Edge Damp Rate", Float) = 2.0									//边缘渐变的分母
        _OriginAlphaThreshold("OriginAlphaThreshold", range(0.1, 1)) = 0.2			//原始颜色透明度剔除的阈值

        // Solution 2
        [Header(Solution 2)]
        _EdgeAlphaThreshold2("Edge Alpha Threshold 2", Float) = 1.0					//边界透明度和的阈值
        _OutlineSize("OutlineSize", range(0, 300)) = 0.002
        [IntRange] _LookupCnt("LookupCnt", Range(1,256)) = 16
        _EdgeLightSize("EdgeLightSize", range(0, 300)) = 0.005

        // Glow 1
        [Header(Glow 1)]
        _OutlineSize2("OutlineSize2", range(0, 300)) = 0.002
        _GlowColor("Glow Color", Color) = (1,0,0,1)									//边界光颜色

        // Overlap
        [Header(Overlap)]
        _OriTex("Origin (RGB) Trans (A)", 2D) = "white" {}
        _OverlapAlpha("Overlap Alpha", range(0, 1.0)) = 0.3
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

            // Solution 2
            fixed _EdgeAlphaThreshold2;
            float _OutlineSize;
            float _EdgeLightSize;
            fixed4 _EdgeLightColor;
            float _LookupCnt;

            // Glow
            float _OutlineSize2;
            fixed4 _GlowColor;

            // Overlap
            sampler2D _OriTex;
            float4 _OriTex_ST;
            half4 _OriTex_TexelSize;

            fixed _OverlapAlpha;

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

            fixed4 frag1(v2f1 i) : SV_Target
            {
                //fixed4 col = tex2D(_MainTex, i.texcoord);
                half alphaSum = CalculateAlphaSumAround1(i);
                float isNeedShow = alphaSum > _EdgeAlphaThreshold;
                float damp = saturate((alphaSum - _EdgeAlphaThreshold) * _EdgeDampRate);
                fixed4 origin = tex2D(_MainTex, i.uv[4]);
                //fixed4 origin = tex2D(_MainTex, i.texcoord);
                float isOrigin = origin.a > _OriginAlphaThreshold;
                fixed3 finalColor = lerp(_EdgeColor.rgb, origin.rgb, isOrigin);

                return fixed4(finalColor.rgb * isNeedShow, isNeedShow * damp);
                //return fixed4(finalColor.rgb, isNeedShow);
                //return fixed4(origin.rgb, isNeedShow);
                //return fixed4(_EdgeColor.rgb, tex2D(_MainTex, i.uv[4]).a);
            }

            fixed4 frag11(v2f1 i) : SV_Target
            {
                //fixed4 col = tex2D(_MainTex, i.texcoord);
                half alphaSum = CalculateAlphaSumAround1(i);
                float isNeedShow = alphaSum > _EdgeAlphaThreshold;
                float damp = saturate((alphaSum - _EdgeAlphaThreshold) * _EdgeDampRate);
                fixed4 origin = tex2D(_MainTex, i.uv[4]);
                //fixed4 origin = tex2D(_MainTex, i.texcoord);
                float isOrigin = origin.a > _OriginAlphaThreshold;
                //fixed3 finalColor = lerp(_EdgeColor.rgb, origin.rgb, isOrigin);

                //return fixed4(finalColor.rgb * isNeedShow, isNeedShow * damp);

                fixed4 finalColor = fixed4(0, 0, 0, 0);
                //if (isNeedShow > 0)
                //{
                //    finalColor.a = 1;
                //    if (isOrigin > 0)
                //    {
                //        finalColor.r = 1;
                //    }
                //    else
                //    {
                //        finalColor.g = 1;
                //    }
                //}
                //finalColor = isNeedShow > 0 && isOrigin > 0;
                if (isNeedShow > 0 && isOrigin > 0)
                {
                    finalColor = origin;
                    finalColor.a = 1;
                }
                return finalColor;
            }
            
            // Solution 2
            v2f2 vert2(appdata_t v)
            {
                v2f2 o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag2(v2f2 i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.texcoord);
                half alphaSum = CalculateAlphaSumAround2(i, _OutlineSize);
                fixed4 color = col;
                // 里面
                //if (alphaSum < _OriginAlphaThreshold || alphaSum > 1.0 - _OriginAlphaThreshold)
                //{ }
                //else
                if (col.a > 0.5)
                {
                    if (alphaSum < 1.0 - _EdgeAlphaThreshold2)
                    {
                        color = _EdgeColor;
                    }
                    else
                    {
                        //color = lerp(col, _EdgeColor, (1.0 - alphaSum) / _EdgeAlphaThreshold2);
                        color = lerp(fixed4(0, 0, 0, 0), _EdgeColor, (1.0 - alphaSum) / _EdgeAlphaThreshold2);
                        //alphaSum = CalculateAlphaSumAround(i, _EdgeLightSize);
                        //if (alphaSum < 0.999)
                        //{
                        //    //color = lerp(_EdgeLightColor, color, alphaSum);
                        //    color = lerp(color, _EdgeLightColor, (1.0 - alphaSum));
                        //    color.a = 1.0 - alphaSum;
                        //}
                    }
                }
                // 外面
                else
                {
                    if (alphaSum > _EdgeAlphaThreshold2)
                    {
                        color = _EdgeColor;
                    }
                    else
                    {
                        //color = lerp(col, _EdgeColor, alphaSum / _EdgeAlphaThreshold2);
                        color = lerp(fixed4(0,0,0,0), _EdgeColor, alphaSum / _EdgeAlphaThreshold2);
                        //alphaSum = CalculateAlphaSumAround(i, _EdgeLightSize);
                        //if (alphaSum > 0.001)
                        //{
                        //    color = lerp(color, _EdgeLightColor, alphaSum);
                        //    color.a = alphaSum;
                        //}
                    }
                }
                return color;
            }


            // Glow1
            fixed4 frag3(v2f2 i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.texcoord);
                half alphaSum = CalculateAlphaSumAround2(i, _OutlineSize2);
                fixed4 color = _GlowColor;
                color.a *= alphaSum;
                color = lerp(color, col, color.a);
                return color;
            }

            // Glow2
            fixed4 frag4(v2f2 i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.texcoord);
                half alphaSum = CalculateAlphaSumAround2(i, _OutlineSize2);
                fixed4 color = _GlowColor;
                color.a *= alphaSum;
                color.a *= alphaSum;
                color = lerp(color, col, saturate(alphaSum*1.2));
                return color;
            }

            // Overlap
            fixed4 frag5(v2f2 i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.texcoord);
                if (col.a < _OverlapAlpha)
                {
                    col = lerp(tex2D(_OriTex, i.texcoord), col, col.a);
                }
                return col;
            }
                ENDCG

        // Pass 0
        Pass {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
                #pragma vertex vert2
                #pragma fragment frag2
                #pragma target 2.0
                #pragma multi_compile_fog
            ENDCG
        }

        // Pass 1
        Pass {
            ZWrite Off
            //Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
                #pragma vertex vert2
                #pragma fragment frag2
                #pragma target 2.0
                #pragma multi_compile_fog
            ENDCG
        }

        // Pass 2
        Pass {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
                #pragma vertex vert1
                #pragma fragment frag11
                #pragma target 2.0
                #pragma multi_compile_fog
            ENDCG
        }

        // Pass 3
        Pass {
            ZWrite Off
            //Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
                #pragma vertex vert1
                #pragma fragment frag11
                #pragma target 2.0
                #pragma multi_compile_fog
            ENDCG
        }

        // Pass 4
        Pass{
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
                #pragma vertex vert2
                #pragma fragment frag3
                #pragma target 2.0
                #pragma multi_compile_fog
            ENDCG
        }

        // Pass 5
        Pass{
            ZWrite Off
            //Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
                #pragma vertex vert2
                #pragma fragment frag3
                #pragma target 2.0
                #pragma multi_compile_fog
            ENDCG
        }

        // Pass 6
        Pass{
            ZWrite Off
            //Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
                #pragma vertex vert2
                #pragma fragment frag5
                #pragma target 2.0
                #pragma multi_compile_fog
            ENDCG
        }
    }
}
