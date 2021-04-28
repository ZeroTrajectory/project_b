Shader "Custom/CornerClip" {
	Properties
	{
		[PerRendererData]_MainTex ("Base (RGB), Alpha (A)", 2D) = "black" {}
		[Toggle(ENALE_UI_CORNER_CLIP)]_enableCornerClip("Enable CornerClip", Float) = 1
		[ShowIf(ENALE_UI_CORNER_CLIP)]_clipX("ClipX", Range(0, 1)) = 0.1
		[ShowIf(ENALE_UI_CORNER_CLIP)]_clipY("ClipY",Range(0,1)) = 0.1
		[ShowIf(ENALE_UI_CORNER_CLIP)]_startX("StartX",Range(0,1)) = 0
		[ShowIf(ENALE_UI_CORNER_CLIP)]_startY("StartY",Range(0,1)) = 0

        [Header(Srpite)]
        [Toggle(SHOW_STENCIL)] _showSprite("Enable STENCIL",Float) = 0
		[ShowIf(SHOW_STENCIL)]_StencilComp("Stencil Comparison", Float) = 8
		[ShowIf(SHOW_STENCIL)]_Stencil("Stencil ID", Float) = 0
		[ShowIf(SHOW_STENCIL)]_StencilOp("Stencil Operation", Float) = 0
		[ShowIf(SHOW_STENCIL)]_StencilWriteMask("Stencil Write Mask", Float) = 255
		[ShowIf(SHOW_STENCIL)]_StencilReadMask("Stencil Read Mask", Float) = 255
		[ShowIf(SHOW_STENCIL)]_ColorMask("Color Mask", Float) = 15
		
		[Header(Fade Alpha)]
		[Toggle(ENALE_UI_FADE_ALPHA)] _enableFadeAlpha("Enable Fade Alpha",Float) = 0
		[ShowIf(ENALE_UI_FADE_ALPHA)]_Color ("Tint", Color) = (1,1,1,1)
		[ShowIf(ENALE_UI_FADE_ALPHA)]_LeftFade ("Left Fade", Range(0.001,1)) = 0.001
		[ShowIf(ENALE_UI_FADE_ALPHA)]_RightFade ("Right Fade", Range(0.001,1)) = 0.001
		[ShowIf(ENALE_UI_FADE_ALPHA)]_TopFade ("Top Fade", Range(0.001,1)) = 0.001
		[ShowIf(ENALE_UI_FADE_ALPHA)]_BottomFade ("Bottom Fade", Range(0.001,1)) = 0.001
	}

	SubShader
	{
		LOD 200

		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
		}

		Stencil
		{
			Ref[_Stencil]
			Comp[_StencilComp]
			Pass[_StencilOp]
			ReadMask[_StencilReadMask]
			WriteMask[_StencilWriteMask]
		}
		ColorMask[_ColorMask]

		Pass
		{
			Cull Off
			Lighting Off
			ZWrite Off
			Fog { Mode Off }
			Offset -1, -1
			ZTest [unity_GUIZTestMode]
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "cginc/DarkBoomCG.cginc"
            #pragma multi_compile __ UNITY_UI_CLIP_RECT
            #pragma multi_compile __ UNITY_UI_ALPHACLIP
            #pragma multi_compile __ ENALE_UI_FADE_ALPHA
            #pragma multi_compile __ ENALE_UI_CORNER_CLIP
            
			sampler2D _MainTex;
			fixed4 _TextureSampleAdd;
            float4 _ClipRect;
            fixed4 _Color;
            
			struct appdata_t
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				fixed4 color : COLOR;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				half2 texcoord : TEXCOORD0;
				fixed4 color : COLOR;
				float4 worldPosition : TEXCOORD1;
			};

			v2f o;
			v2f vert (appdata_t IN)
			{
			    v2f OUT;
				OUT.worldPosition = IN.vertex;
				OUT.vertex = UnityHalfTexelOffsetVertex(UnityObjectToClipPos(OUT.worldPosition));
				OUT.texcoord = IN.texcoord;
				OUT.color = IN.color * _Color;
				return OUT;
			}

			fixed4 frag (v2f IN) : SV_Target
			{
			    #ifdef FADE_ALPHA
			    half4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;
			    #else
				half4 color = tex2D(_MainTex, IN.texcoord) * IN.color;
				#endif
				color = UICornerClipFrag(IN.texcoord.xy,color);
                color = UnityUIClipRectFrag(IN.worldPosition.xy,color,_ClipRect);
                
  				return color;
			}
			ENDCG
		}
	}

	SubShader
	{
		LOD 100

		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}

		Pass
		{
			Cull Off
			Lighting Off
			ZWrite Off
			Fog { Mode Off }
			Offset -1, -1
			ColorMask RGB
			Blend SrcAlpha OneMinusSrcAlpha
			ColorMaterial AmbientAndDiffuse

			SetTexture [_MainTex]
			{
				Combine Texture * Primary
			}
		}
	}
	FallBack "Diffuse"
}
