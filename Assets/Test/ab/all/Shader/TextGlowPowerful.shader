// Powerful Text Glow shader，create by miaofl at 2021-04-02

Shader "DarkBoom/TextGlowPowerful" 
{
    Properties
    {
        [PerRendererData] _MainTex ("Main Texture", 2D) = "white" {}
        // _GlowColor ("Glow Color", Color) = (1, 1, 1, 1)    // 为了能够合批，不能直接修改
        // _GlowWidth ("Glow Width", Int) = 1                 // 为了能够合批，不能直接修改
        
        // _GlowOffsetX ("Glow OffsetX", Float) = 0           // 为了能够合批，不能直接修改
        // _GlowOffsetY ("Glow OffsetY", Float) = 0           // 为了能够合批，不能直接修改

        [Toggle(_ENABLE_QUALITY_HIGH)] _ENABLE_QUALITY_HIGH("EnableQualityHigh", Int) = 0

        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255

        _ColorMask ("Color Mask", Float) = 15
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent" 
            "IgnoreProjector"="True" 
            "RenderType"="Transparent" 
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp] 
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend SrcAlpha OneMinusSrcAlpha
        // Blend Off
        ColorMask [_ColorMask]

        // 第一个PASS，绘制出发光区域
        Pass
        {
            Name "TEXT_GLOW"

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // #pragma target 2.0

            #pragma multi_compile __ _ENABLE_QUALITY_HIGH

            //Add for RectMask2D
            #include "UnityUI.cginc"
            //End for RectMask2D

            sampler2D _MainTex;
            fixed4 _TextureSampleAdd;
            float4 _MainTex_TexelSize;

            // float4 _GlowColor;
            // int _GlowWidth;

            // float _GlowOffsetX;
            // float _GlowOffsetY;

            //Add for RectMask2D
            float4 _ClipRect;
            //End for RectMask2D

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv0 : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float2 uv2 : TEXCOORD2;
                float2 uv3 : TEXCOORD3;
                fixed4 color : COLOR;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float4 uv2 : TEXCOORD2;
                fixed4 uv3 : TEXCOORD3;
                //Add for RectMask2D
                float4 worldPosition : TEXCOORD4;
                //End for RectMask2D
                fixed4 color : COLOR;
            };

            fixed IsInRect(float2 pPos, float2 pClipRectMin, float2 pClipRectMax)
            {
                pPos = step(pClipRectMin, pPos) * step(pPos, pClipRectMax);
                return pPos.x * pPos.y;
            }

            /**
            * 获取指定角度方向，距离为xxx的像素的透明度
            * @param angleIndex 角度索引
            * @param dist 距离 [0.0, 1.0]
            * @return alpha [0.0, 1.0]
            */
            float getColorAlpha(int angleIndex, float dist, v2f IN, float glowAlpha) {
                #if _ENABLE_QUALITY_HIGH
                    const fixed sinArray[36] = {
                        0, 0.1736, 0.342, 0.5, 0.6428, 0.766, 0.866, 0.9397, 0.9848, 1, 0.9848, 0.9397, 
                        0.866, 0.766, 0.6428, 0.5, 0.342, 0.1736, 0, -0.1736, -0.342, -0.5, -0.6428, -0.766, 
                        -0.866, -0.9397, -0.9848, -1, -0.9848, -0.9397, -0.866, -0.766, -0.6428, -0.5, -0.342, -0.1736
                    };
                    const fixed cosArray[36] = {
                        1, 0.9848, 0.9397, 0.866, 0.766, 0.6428, 0.5, 0.342, 0.1736, 0, -0.1736, -0.342, 
                        -0.5, -0.6428, -0.766, -0.866, -0.9397, -0.9848, -1, -0.9848, -0.9397, -0.866, -0.766, -0.6428, 
                        -0.5, -0.342, -0.1736, 0, 0.1736, 0.342, 0.5, 0.6428, 0.766, 0.866, 0.9397, 0.9848
                    };
                #else
                    const fixed sinArray[12] = { 0, 0.5, 0.866, 1, 0.866, 0.5, 0, -0.5, -0.866, -1, -0.866, -0.5 };
                    const fixed cosArray[12] = { 1, 0.866, 0.5, 0, -0.5, -0.866, -1, -0.866, -0.5, 0, 0.5, 0.866 };
                #endif

                // 原始写法，保留不删，可以参考来看原理
                // float radian = angle * 0.01745329252; // 这个浮点数是 pi / 180;
                // float2 pos = IN.uv0 + _MainTex_TexelSize.xy * dist * (float2(cos(radian), sin(radian)));

                float2 pos = IN.uv0 + _MainTex_TexelSize.xy * dist * (float2(cosArray[angleIndex], sinArray[angleIndex]));
                fixed4 color = IsInRect(pos, IN.uv1, IN.uv2) * (tex2D(_MainTex, pos) + _TextureSampleAdd).a * glowAlpha;
                return color.a;
            }

            /**
            * 获取指定距离的周边像素的透明度平均值
            * @param dist 距离 [0.0, 1.0]
            * @return average alpha [0.0, 1.0]
            */
            float getAverageAlpha(float dist, v2f IN, float glowAlpha) {
                float totalAlpha = 0.0;
                // 以10度为一个单位，那么「周边一圈」就由0到360度中共计36个点的组成
                // 这里循环次数越多，模糊效果越好

                #if _ENABLE_QUALITY_HIGH
                    totalAlpha += getColorAlpha(0, dist, IN, glowAlpha);
                    totalAlpha += getColorAlpha(1, dist, IN, glowAlpha);
                    totalAlpha += getColorAlpha(2, dist, IN, glowAlpha);
                    totalAlpha += getColorAlpha(3, dist, IN, glowAlpha);
                    totalAlpha += getColorAlpha(4, dist, IN, glowAlpha);
                    totalAlpha += getColorAlpha(5, dist, IN, glowAlpha);
                    totalAlpha += getColorAlpha(6, dist, IN, glowAlpha);
                    totalAlpha += getColorAlpha(7, dist, IN, glowAlpha);
                    totalAlpha += getColorAlpha(8, dist, IN, glowAlpha);
                    totalAlpha += getColorAlpha(9, dist, IN, glowAlpha);
                    totalAlpha += getColorAlpha(10, dist, IN, glowAlpha);
                    totalAlpha += getColorAlpha(11, dist, IN, glowAlpha);
                    totalAlpha += getColorAlpha(12, dist, IN, glowAlpha);
                    totalAlpha += getColorAlpha(13, dist, IN, glowAlpha);
                    totalAlpha += getColorAlpha(14, dist, IN, glowAlpha);
                    totalAlpha += getColorAlpha(15, dist, IN, glowAlpha);
                    totalAlpha += getColorAlpha(16, dist, IN, glowAlpha);
                    totalAlpha += getColorAlpha(17, dist, IN, glowAlpha);
                    totalAlpha += getColorAlpha(18, dist, IN, glowAlpha);
                    totalAlpha += getColorAlpha(19, dist, IN, glowAlpha);
                    totalAlpha += getColorAlpha(20, dist, IN, glowAlpha);
                    totalAlpha += getColorAlpha(21, dist, IN, glowAlpha);
                    totalAlpha += getColorAlpha(22, dist, IN, glowAlpha);
                    totalAlpha += getColorAlpha(23, dist, IN, glowAlpha);
                    totalAlpha += getColorAlpha(24, dist, IN, glowAlpha);
                    totalAlpha += getColorAlpha(25, dist, IN, glowAlpha);
                    totalAlpha += getColorAlpha(26, dist, IN, glowAlpha);
                    totalAlpha += getColorAlpha(27, dist, IN, glowAlpha);
                    totalAlpha += getColorAlpha(28, dist, IN, glowAlpha);
                    totalAlpha += getColorAlpha(29, dist, IN, glowAlpha);
                    totalAlpha += getColorAlpha(30, dist, IN, glowAlpha);
                    totalAlpha += getColorAlpha(31, dist, IN, glowAlpha);
                    totalAlpha += getColorAlpha(32, dist, IN, glowAlpha);
                    totalAlpha += getColorAlpha(33, dist, IN, glowAlpha);
                    totalAlpha += getColorAlpha(34, dist, IN, glowAlpha);
                    totalAlpha += getColorAlpha(35, dist, IN, glowAlpha);
                    totalAlpha *= 0.027778; // 1 / 36 = 0.027778
                #else
                    totalAlpha += getColorAlpha(0, dist, IN, glowAlpha);
                    totalAlpha += getColorAlpha(1, dist, IN, glowAlpha);
                    totalAlpha += getColorAlpha(2, dist, IN, glowAlpha);
                    totalAlpha += getColorAlpha(3, dist, IN, glowAlpha);
                    totalAlpha += getColorAlpha(4, dist, IN, glowAlpha);
                    totalAlpha += getColorAlpha(5, dist, IN, glowAlpha);
                    totalAlpha += getColorAlpha(6, dist, IN, glowAlpha);
                    totalAlpha += getColorAlpha(7, dist, IN, glowAlpha);
                    totalAlpha += getColorAlpha(8, dist, IN, glowAlpha);
                    totalAlpha += getColorAlpha(9, dist, IN, glowAlpha);
                    totalAlpha += getColorAlpha(0, dist, IN, glowAlpha);
                    totalAlpha += getColorAlpha(11, dist, IN, glowAlpha);

                    totalAlpha *= 0.083333; // 1 / 12 = 0.083333
                #endif

                return totalAlpha;
            }

            /**
            * 获取发光的透明度
            */
            float getGlowAlpha(int glowColorSize, v2f IN, float glowAlpha) {
                // 将传入的指定距离，平均分成10圈，求出每一圈的平均透明度，
                // 然后求和取平均值，那么就可以得到该点的平均透明度
                float totalAlpha = 0.0;
                totalAlpha += getAverageAlpha(glowColorSize * 0.1, IN, glowAlpha);
                totalAlpha += getAverageAlpha(glowColorSize * 0.2, IN, glowAlpha);
                totalAlpha += getAverageAlpha(glowColorSize * 0.3, IN, glowAlpha);
                totalAlpha += getAverageAlpha(glowColorSize * 0.4, IN, glowAlpha);
                totalAlpha += getAverageAlpha(glowColorSize * 0.5, IN, glowAlpha);
                totalAlpha += getAverageAlpha(glowColorSize * 0.6, IN, glowAlpha);
                totalAlpha += getAverageAlpha(glowColorSize * 0.7, IN, glowAlpha);
                totalAlpha += getAverageAlpha(glowColorSize * 0.8, IN, glowAlpha);
                totalAlpha += getAverageAlpha(glowColorSize * 0.9, IN, glowAlpha);
                totalAlpha += getAverageAlpha(glowColorSize * 1.0, IN, glowAlpha);
                return totalAlpha * 0.5;
            }

            v2f vert(appdata IN)
            {
                v2f o;

                int offsetXInt = IN.uv1.x;
                int offsetYInt = IN.uv1.y;

                IN.vertex.x += offsetXInt/100.0;
                IN.vertex.y += -offsetYInt/100.0;

                //Add for RectMask2D
                o.worldPosition = IN.vertex;
                //End for RectMask2D

                o.vertex = UnityObjectToClipPos(IN.vertex);

                o.uv0 = IN.uv0;
                o.color = IN.color;

                // 解析出正确的uv值
                o.uv1 = float2(abs(IN.uv1.x - offsetXInt), abs(IN.uv1.y - offsetYInt));
                o.uv2 = float4(IN.uv2.x - (int)IN.uv2.x, IN.uv2.y, (int)IN.uv2.x, 0.0);

                int rg = round(IN.uv3.x);
                int ba = round(IN.uv3.y);
                int r = rg / 1000;
                int g = rg % 1000;
                int b = ba / 1000;
                int a = ba % 1000;

                // 存发光的颜色
                o.uv3 = fixed4(r/255.0, g/255.0, b/255.0, a/255.0);

                return o;
            }

            fixed4 frag(v2f IN) : SV_Target
            {
                fixed4 glowColor = IN.uv3;
                int glowWidth = round(IN.uv2.z);

                // 如果发光宽度为0，直接返回0透明度，减少计算量
                if (glowWidth == 0) {
                    return fixed4(0, 0, 0, 0);
                }

                float alpha = getGlowAlpha(glowWidth, IN, glowColor.a);
                fixed4 color = fixed4(glowColor.rgb, alpha);

                //Add for RectMask2D
                color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
                //End for RectMask2D

                return color;
            }

            ENDCG
        }

        // 第二个Pass，显示Text内容
        Pass {
            Name "TEXT_TEXT"

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            //Add for RectMask2D
            #include "UnityUI.cginc"
            //End for RectMask2D

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv0 : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float2 uv2 : TEXCOORD2;
                fixed4 color : COLOR;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float2 uv2 : TEXCOORD2;
                //Add for RectMask2D
                float4 worldPosition : TEXCOORD4;
                //End for RectMask2D
                fixed4 color : COLOR;
            };

            sampler2D _MainTex;
            fixed4 _TextureSampleAdd;

            //Add for RectMask2D
            float4 _ClipRect;
            //End for RectMask2D

            
            fixed IsInRect(float2 pPos, float2 pClipRectMin, float2 pClipRectMax)
            {
                pPos = step(pClipRectMin, pPos) * step(pPos, pClipRectMax);
                return pPos.x * pPos.y;
            }

            v2f vert(appdata IN)
            {
                v2f o;

                int offsetXInt = IN.uv1.x;
                int offsetYInt = IN.uv1.y;

                //Add for RectMask2D
                o.worldPosition = IN.vertex;
                //End for RectMask2D

                o.vertex = UnityObjectToClipPos(IN.vertex);
                o.uv0 = IN.uv0;
                o.color = IN.color;
                o.uv1 = float2(abs(IN.uv1.x - offsetXInt), abs(IN.uv1.y - offsetYInt));
                o.uv2 = float2(IN.uv2.x - (int)IN.uv2.x, IN.uv2.y);

                return o;
            }

            fixed4 frag(v2f IN) : SV_Target
            {
                fixed4 color = (tex2D(_MainTex, IN.uv0) + _TextureSampleAdd) * IN.color;//默认的文字颜色
                color.a *= IsInRect(IN.uv0, IN.uv1, IN.uv2);

                //Add for RectMask2D
                color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
                // #ifdef UNITY_UI_ALPHACLIP
                //     clip(color.a - 0.001);
                // #endif
                //End for RectMask2D
                
                return color;
            }
            ENDCG
        }
    }
}