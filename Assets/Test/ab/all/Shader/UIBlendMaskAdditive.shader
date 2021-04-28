//  
// @yanfei 2019.2.11
//
Shader "UI/BlendMaskAdditive"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
	    _MaskTex("Mask Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
        _BlendColor("BlendColor", Color) = (1, 1, 1, 1)
        _ColorFactor("ColorFactor", Range (0, 1)) = 0
        _AlphaFactor("AlphaFactor", Range (0, 1)) = 1
		_MovingFactor("MovingFactor", Range (0, 2)) = 0

		_StencilComp ("Stencil Comparison", Float) = 8
		_Stencil ("Stencil ID", Float) = 0
		_StencilOp ("Stencil Operation", Float) = 0
		_StencilWriteMask ("Stencil Write Mask", Float) = 255
		_StencilReadMask ("Stencil Read Mask", Float) = 255

        _ColorMask ("Color Mask", Float) = 15

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
        //Blend SrcAlpha OneMinusSrcAlpha
		Blend SrcAlpha One
        ColorMask [_ColorMask]

        Pass
        {
            Name "Default"
        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            //#pragma multi_compile UIBLEND_NORMAL UIBLEND_GRAY_LIGHTEN_1 UIBLEND_GRAY_LIGHTEN_2 UIBLEND_GRAY_LIGHTEN_3 UIBLEND_GRAY_ITEM_1

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

            fixed4 _Color;
            fixed4 _BlendColor;
            float _ColorFactor;
            float _AlphaFactor;
			float _MovingFactor;
            float4 _ClipRect;

            v2f vert(appdata_t v)
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                OUT.worldPosition = v.vertex;
                OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);

                OUT.texcoord = v.texcoord;

                OUT.color = v.color * _Color;
                return OUT;
            }

            sampler2D _MainTex;
			sampler2D _MaskTex;

            fixed4 frag(v2f IN) : SV_Target
            {				
                half4 color = tex2D(_MainTex, IN.texcoord) * IN.color;

                #ifdef UNITY_UI_CLIP_RECT
                color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
                #endif

                #ifdef UNITY_UI_ALPHACLIP
                clip (color.a - 0.001);
                #endif
				
				float2 maskcoord = float2(frac(-_MovingFactor + IN.texcoord.x + 1), frac(-_MovingFactor + IN.texcoord.y + 1));
				half4 mcolor = tex2D(_MaskTex, maskcoord);
				float f = 1 - abs(_MovingFactor - 1);

				mcolor.a = lerp(lerp(0, mcolor.a, sign(min(max(0, f - IN.texcoord.x), max(0, f - IN.texcoord.y)))), 
					            lerp(0, mcolor.a, sign(min(max(0, IN.texcoord.x + f - 1), max(0, IN.texcoord.y + f - 1)))), sign(max(0, _MovingFactor - 1)));
				
                fixed4 fcolor = color; // color will be handled
				fcolor.rgb = fcolor.rgb + mcolor.rgb * mcolor.a * _AlphaFactor;
				//fcolor = mcolor;

                fcolor = clamp(fcolor, 0, 1);

                return fcolor;
            }
        ENDCG
        }
    }
}
