Shader "DarkBoom/UI_Image_Gray"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
        [Toggle(IsGray)] _IsGray("IsGray",int) =0 
        [Toggle(IsUseClipRectFade)]_IsUseClipRectFade("IsUseClipRectFade", int) = 0
        
        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255

        _ColorMask ("Color Mask", Float) = 15
        
        		
		_LeftFade ("Left Fade", Range(0.001,1)) = 0.001
		_RightFade ("Right Fade", Range(0.001,1)) = 0.001
		_TopFade ("Top Fade", Range(0.001,1)) = 0.001
		_BottomFade ("Bottom Fade", Range(0.001,1)) = 0.001
		
		_ClipRectFade("ClipRectFade", Vector) = (0,0,1,1)

        [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
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

            #pragma multi_compile __ UNITY_UI_CLIP_RECT
            #pragma multi_compile __ UNITY_UI_ALPHACLIP

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
                float4 worldPosition : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            fixed4 _Color;
            fixed4 _TextureSampleAdd;
            float4 _ClipRect;
            float4 _MainTex_ST;
            fixed _IsGray;
            
            fixed _LeftFade;
			fixed _RightFade;
			fixed _TopFade;
			fixed _BottomFade;

			fixed _IsUseClipRectFade;
			float4 _ClipRectFade;

            v2f vert(appdata_t v)
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                OUT.worldPosition = v.vertex;
                OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);

                OUT.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);

                OUT.color = v.color * _Color;
                return OUT;
            }

            fixed3 getluminanceColor(fixed3 basecolor)
            {
                float luminance = 0.2125 * basecolor.r + 0.7154 * basecolor.g + 0.0721 * basecolor.b;
                fixed3 luminanceColor = fixed3(luminance, luminance, luminance);
                return luminanceColor;
            }

            fixed4 frag(v2f IN) : SV_Target
            {
                half4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;

                #ifdef UNITY_UI_CLIP_RECT
                color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
                #endif

                #ifdef UNITY_UI_ALPHACLIP
                clip (color.a - 0.001);
                #endif
                
                #ifdef UNITY_UI_CLIP_RECT

				if (_IsUseClipRectFade == 0)
				{

					half w = (_ClipRect.z - _ClipRect.x) * 0.5;
					half h = (_ClipRect.w - _ClipRect.y) * 0.5;

					half left = (IN.worldPosition.x - _ClipRect.x) / w;
					half right = (_ClipRect.z - IN.worldPosition.x) / w;

					half bottom = (IN.worldPosition.y - _ClipRect.y) / h;
					half top = (_ClipRect.w - IN.worldPosition.y) / h;

					color.a *= min(
						min(clamp(left / _LeftFade, 0, 1), clamp(right / _RightFade, 0, 1)),
						min(clamp(top / _TopFade, 0, 1), clamp(bottom / _BottomFade, 0, 1)));

				}
				else
				{
					half w = (_ClipRectFade.z - _ClipRectFade.x) * 0.5;
					half h = (_ClipRectFade.w - _ClipRectFade.y) * 0.5;

					half left = (IN.worldPosition.x - _ClipRectFade.x) / w;
					half right = (_ClipRectFade.z - IN.worldPosition.x) / w;

					half bottom = (IN.worldPosition.y - _ClipRectFade.y) / h;
					half top = (_ClipRectFade.w - IN.worldPosition.y) / h;

					color.a *= min(
						min(clamp(left / _LeftFade, 0, 1), clamp(right / _RightFade, 0, 1)),
						min(clamp(top / _TopFade, 0, 1), clamp(bottom / _BottomFade, 0, 1)));

				}
				
				//half edge = min(abs(IN.worldPosition.y - _ClipRect.y), abs(IN.worldPosition.y - _ClipRect.w)) / (_ClipRect.w - _ClipRect.y);
				//color.a *= clamp(edge * 8, 0, 1);
                #endif
                
                if(_IsGray)
                {
                   return fixed4(getluminanceColor(color.rgb),color.a);
                }
	         //   float grey = dot(color.rgb, fixed3(0.22, 0.707, 0.071));
		        return color;
            }
        ENDCG
        }
    }
}

