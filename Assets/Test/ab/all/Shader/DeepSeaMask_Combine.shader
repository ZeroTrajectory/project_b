Shader "DarkBoom/DeepSeaMaskCombine"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		_Color("Tint", Color) = (1,1,1,1)

		_StencilComp("Stencil Comparison", Float) = 8
		_Stencil("Stencil ID", Float) = 0
		_StencilOp("Stencil Operation", Float) = 0
		_StencilWriteMask("Stencil Write Mask", Float) = 255
		_StencilReadMask("Stencil Read Mask", Float) = 255

		_ColorMask("Color Mask", Float) = 15

		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip("Use Alpha Clip", Float) = 0

		[Space(20)]
		[Header(MainTex area)]	
		_MainTex_Offset("MainTex Offset", vector) = (0,0,1,1)

		[Space(20)]
		[Header(Mask area)]	
		[Toggle(_ENABLE_OUTCLIP)] _EnableOutClip("Enable out clip", Float) = 0
		[NoScaleOffset]
		_MaskTex1("MaskTex1", 2D) = "white" {}
		[NoScaleOffset]
		_MaskTex2("MaskTex2", 2D) = "white" {}
		[Enum(DeepSeaMaskType)] 
		_MaskType ("MaskType", Float) = 1
		[Enum(DeepSeaMaskChannel)]
		_MaskChannel ("MaskChannel", Float) = 1
		_Mask_Offset("Mask Offset", vector) = (0,0,1,1)

		[Space(20)]
		[Header(Background area)]	
		[NoScaleOffset]
		_BG_Tex1("Background 1", 2D) = "black" {}
		_BG_Tex1_Offset("Background 1 Offset", vector) = (0,0,1,1)
		[NoScaleOffset]
		_BG_Tex2("Background 2", 2D) = "black" {}
		_BG_Tex2_Offset("Background 2 Offset", vector) = (0,0,1,1)
		[NoScaleOffset]
		_FG_Tex1("Foreground 1", 2D) = "black" {}
		_FG_Tex1_Offset("Foreground 1 Offset", vector) = (0,0,1,1)
		[NoScaleOffset]
		_FG_Tex2("Foreground 2", 2D) = "black" {}
		_FG_Tex2_Offset("Foreground 2 Offset", vector) = (0,0,1,1)
		
		[Space(20)]
		[Header(Special effect area)]	
		_MainAlpha("MainAlpha", range(0, 5)) = 1
		[Toggle]
		_AddColorMode("_AddColorMode", Int) = 0

		[Space(100)]
		[Toggle(_ENABLE_FADE_RECT)] _EnableFadeRect("Enable fade rect", Float) = 0
		
		_LeftFade ("Left Fade", Range(0.001,1)) = 0.001
		_RightFade ("Right Fade", Range(0.001,1)) = 0.001
		_TopFade ("Top Fade", Range(0.001,1)) = 0.001
		_BottomFade ("Bottom Fade", Range(0.001,1)) = 0.001
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
			"PreviewType" = "Plane"
			"CanUseSpriteAtlas" = "True"
		}

		Stencil
		{
			Ref[_Stencil]
			Comp[_StencilComp]
			Pass[_StencilOp]
			ReadMask[_StencilReadMask]
			WriteMask[_StencilWriteMask]
		}

		Cull Off
		Lighting Off
		ZWrite Off
		ZTest[unity_GUIZTestMode]
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask[_ColorMask]

		Pass
		{
			Name "Default"
			CGPROGRAM
			#pragma vertex vert_deepSea
			#pragma fragment frag
			#pragma target 2.0

			#include "UnityCG.cginc"
			#include "UnityUI.cginc"
			#include "cginc/DeepSeaMask.cginc"
			#ifdef _ENABLE_FADE_RECT
			#include "cginc/RectMask2DFade.cginc"
			#endif

			#pragma multi_compile __ UNITY_UI_CLIP_RECT
			#pragma multi_compile __ UNITY_UI_ALPHACLIP
			#pragma multi_compile __ _ENABLE_OUTCLIP
			#pragma multi_compile __ _ADDCOLORMODE_ON	
			#pragma multi_compile __ _ENABLE_FADE_RECT		

			fixed4 frag(v2f IN) : SV_Target
			{
				half4 color = calculateDeepSeaMaskColor(IN);
				
				#ifdef UNITY_UI_CLIP_RECT
					color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
				#endif

				#ifdef UNITY_UI_ALPHACLIP
					clip(color.a - 0.001);
				#endif				
				
				#ifdef _ENABLE_FADE_RECT
					color = calculateFadeRectMask(IN, color);
				#endif
				return color;
			}
			ENDCG
		}
	}
}
