// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "DarkBoom/NoiseModifyCustom"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
        _NoiseMap("NoiseMap",2D) = "white" {}
        _NoiseDensity("NoiseDensity",range(0,0.5)) =0.1
        _NoiseSpeed("NoiseSpeed",range(1,100)) =50
        [Toggle(IsNoise)] _IsNoise("IsNoise",int) =0
        // [HideInInspector]_EdgeTopMin("EdgeTopMin",range(0,0.5)) = 0
        // [HideInInspector]_EdgeTopMax("EdgeTopMax",range(0,0.5)) = 0
        // [HideInInspector]_EdgeBottomMin("EdgeBottomMin",range(0,0.5))=0
        // [HideInInspector]_EdgeBottomMax("EdgeBottomMax",range(0,0.5))=0
        // [HideInInspector]_EdgeRightMin("EdgeRightMin",range(0,0.5)) =0
        // [HideInInspector]_EdgeRightMax("EdgeRightMax",range(0,0.5)) =0
        // [HideInInspector]_EdgeLeftMin("EdgeLeftMin",range(0,0.5)) =0
        // [HideInInspector]_EdgeLeftMax("EdgeLeftMax",range(0,0.5)) =0
        _Brightness("亮度",range(0,3)) = 1
        _Saturation("饱和度",range(0,3)) = 1
        _Contrast("对比度",range(0,3)) =1 
        
        // [HideInInspector][Toggle(Edge_ALPHACLIP)] _EdgeAlphaClip("Edge Alpha Clip",int) =0
        
        [HideInInspector] _RendererColor ("RendererColor", Color) = (1, 1, 1, 1)
        [HideInInspector] _Flip ("Flip", Vector) = (1, 1, 1, 1)
        [PerRendererData] _AlphaTex ("External Alpha", 2D) = "white" { }
        [PerRendererData] _EnableExternalAlpha ("Enable External Alpha", Float) = 0
        [HideInInspector]_ColorMask ("Color Mask", Float) = 15

        [HideInInspector][Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
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

        // Stencil
        // {
        //     Ref [_Stencil]
        //     Comp [_StencilComp]
        //     Pass [_StencilOp]
        //     ReadMask [_StencilReadMask]
        //     WriteMask [_StencilWriteMask]
        // }

        Cull Off
        Lighting Off
        ZWrite Off
        // ZTest [unity_GUIZTestMode]
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask [_ColorMask]

        Pass
        {
            Name "Default"
        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP
            #pragma multi_compile_local _ Edge_ALPHACLIP

            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                fixed4 color    : COLOR;
                float2 texcoord  : TEXCOORD0;
                float2 NoiseUV :TEXCOORD2;
                float4 worldPosition : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };
            sampler2D _NoiseMap;
            float4 _NoiseMap_ST;
            sampler2D _MainTex;
            // bool _EdgeAlphaClip;
            bool _IsNoise;
            fixed4 _Color;
            // fixed4 _TextureSampleAdd;
            float4 _ClipRect;
            float4 _MainTex_ST;
            // float _EdgeLeftMax;
            // float _EdgeLeftMin;
            // float _EdgeRightMax;
            // float _EdgeRightMin;
            // float _EdgeBottomMax;
            // float _EdgeBottomMin;
            // float _EdgeTopMax;
            // float _EdgeTopMin;
            half _Brightness;
            half _Saturation;
            half _Contrast;
            float _NoiseDensity;
            float _NoiseSpeed;

            float random (float2 st) {
                return frac(sin(dot(st.xy,float2(12.9898,78.233)))*43758.5453123);
            }

            v2f vert(appdata_t v)
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                OUT.worldPosition = v.vertex;
                OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);

                OUT.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
               
                OUT.NoiseUV =  v.texcoord.xy * _NoiseMap_ST.xy +_NoiseMap_ST;
                OUT.color = v.color * _Color;
                return OUT;
            }

            fixed4 frag(v2f IN) : SV_Target
            {
                //half4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;
                // half4 basecolor = (tex2D(_MainTex,IN.texcoord)+_TextureSampleAdd) * IN.color;
                half4 basecolor = (tex2D(_MainTex,IN.texcoord)) * IN.color;
                if(!_IsNoise)
                {
                    return basecolor;
                }
                float4 noiseOffset = tex2D(_NoiseMap,IN.texcoord);
                noiseOffset = (noiseOffset*2 - 1);  
                // float2 noiseuvOffset =  
                half4 noisemap = tex2D(_NoiseMap,float2(IN.NoiseUV.x*noiseOffset.r*unity_DeltaTime.x*_NoiseSpeed,IN.NoiseUV.y*noiseOffset.g*unity_DeltaTime.x*_NoiseSpeed));
                basecolor= lerp(basecolor,noisemap,_NoiseDensity);
                //饱和度 明度 对比度调整
                basecolor.rgb *= _Brightness; 

                float luminance = 0.2125 * basecolor.r + 0.7154 * basecolor.g + 0.0721 * basecolor.b;
                fixed3 luminanceColor = fixed3(luminance, luminance, luminance);
                basecolor.rgb = lerp(luminanceColor, basecolor, _Saturation);

                fixed3 avgColor = fixed3(0.5, 0.5, 0.5);
                basecolor.rgb = lerp(avgColor, basecolor, _Contrast);

                // //x轴向 right
                // float edgerightMin = min(_EdgeRightMin,_EdgeRightMax);
                // float edgerightMax = max(_EdgeRightMax,_EdgeRightMin);
                // basecolor.rgb *=step(IN.texcoord.x,(1-edgerightMin)); 
               
                // float xr = (IN.texcoord.x - (1-edgerightMax))/((1-edgerightMin)-(1-edgerightMax));
                // xr = saturate(xr);
                // basecolor.rgb *=lerp(1,0,xr);

                // //x轴向 left
                // float edgeleftMin = min(_EdgeLeftMin,_EdgeLeftMax);
                // float edgeleftMax = max(_EdgeLeftMax,_EdgeLeftMin);
                // basecolor.rgb *=step(edgeleftMin,IN.texcoord.x); 
                // float xl = (IN.texcoord.x - edgeleftMin)/(edgeleftMax-edgeleftMin);
                // basecolor.rgb *=lerp(0,1,saturate(xl));

                // //y轴向 Top
                // float edgetopMin = min(_EdgeTopMin,_EdgeTopMax);
                // float edgetopMax = max(_EdgeTopMin,_EdgeTopMax);
                // basecolor.rgb *=step(IN.texcoord.y,(1-edgetopMin)); 
                // float xt = (IN.texcoord.y - (1-edgetopMax))/((1-edgetopMin)-(1-edgetopMax));
                // xt = saturate(xt);
                // basecolor.rgb *=lerp(1,0,xt);

                // //y轴向 Bottom
                // float edgebottomMin = min(_EdgeBottomMin,_EdgeBottomMax);
                // float edgebottomMax = max(_EdgeBottomMin,_EdgeBottomMax);
                // basecolor.rgb *=step(edgebottomMin,IN.texcoord.y); 
                // float xb = (IN.texcoord.y - edgebottomMin)/(edgebottomMax-edgebottomMin);
                // basecolor.rgb *=lerp(0,1,saturate(xb));

                // if(_EdgeAlphaClip)
                // {
                //     basecolor.a = basecolor.a *lerp(1,0,xr)*lerp(0,1,saturate(xl))*lerp(1,0,xt)*lerp(0,1,saturate(xb));
                // }
                //
                fixed4 color = basecolor*_Color;
                #ifdef UNITY_UI_CLIP_RECT
                color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
                #endif

                #ifdef UNITY_UI_ALPHACLIP
                clip (color.a - 0.001);
                #endif

                return color;
            }
        ENDCG
        }
    }
}
