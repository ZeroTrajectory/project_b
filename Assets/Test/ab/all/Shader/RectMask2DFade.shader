Shader "Custom/RectMask2DFade"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		
		_LeftFade ("Left Fade", Range(0.001,1)) = 0.001
		_RightFade ("Right Fade", Range(0.001,1)) = 0.001
		_TopFade ("Top Fade", Range(0.001,1)) = 0.001
		_BottomFade ("Bottom Fade", Range(0.001,1)) = 0.001
		
		_IsUseClipRectFade("IsUseClipRectFade", Float) = 0
		_ClipRectFade("ClipRectFade", Vector) = (0,0,1,1)
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
		
        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        
		Blend SrcAlpha OneMinusSrcAlpha		

        //ColorMask [_ColorMask]

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "UnityUI.cginc"
			#include "cginc/RectMask2DFade.cginc"
			
            #pragma multi_compile __ UNITY_UI_CLIP_RECT
            #pragma multi_compile __ UNITY_UI_ALPHACLIP
			
			half4 frag(v2f IN) : SV_Target
			{
				half4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;

				#ifdef UNITY_UI_CLIP_RECT
				color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
				#endif

				#ifdef UNITY_UI_ALPHACLIP
				clip(color.a - 0.001);
				#endif

				color = calculateFadeRectMask(IN, color);

				return color;
			}
			ENDCG
		}
	}
}
