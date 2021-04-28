Shader "DarkBoom/DeepSeaMask"
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
		[Space(100)]
		[Toggle(_ENABLE_OUTCLIP)] _EnableOutClip("Enable out clip", Float) = 0
		_MaskOffsetX("MaskOffsetX", range(-1, 1)) = 0
		_MaskOffsetScaleX("MaskOffsetScaleX", range(0.25, 1.5)) = 1
		_MaskOffsetY("MaskOffsetY", range(-1, 1)) = 0
		_MaskOffsetScaleY("MaskOffsetScaleY", range(0.25, 1.5)) = 1
		[NoScaleOffset]
		_MaskTex1("MaskTex1", 2D) = "white" {}
		[NoScaleOffset]
		_MaskTex2("MaskTex2", 2D) = "white" {}

		[Space(100)]
		[Toggle(_ENABLE_BG)] _ENABLE_BG("EnableBG", Int) = 0
		[NoScaleOffset]
		_BackGround("BackGround", 2D) = "black" {}

		[Space(100)]
		[Toggle(_ENABLE_FG)] _ENABLE_FG("EnableFG", Int) = 0
		[NoScaleOffset]
		_ForeGround("ForeGround", 2D) = "black" {}

		[Enum(Mask1, 1, Mask2 , 2, Mask3, 3, Mask4, 4)] 
		_MaskType ("MaskType", Int) = 1

		_MainAlpha("MainAlpha", range(0, 5)) = 1

		[Toggle]
		_AddColorMode("_AddColorMode", Int) = 0

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
#pragma vertex vert
#pragma fragment frag
#pragma target 2.0

#include "UnityCG.cginc"
#include "UnityUI.cginc"

#pragma multi_compile __ UNITY_UI_CLIP_RECT
#pragma multi_compile __ UNITY_UI_ALPHACLIP
#pragma multi_compile __ _ENABLE_OUTCLIP

#pragma shader_feature __ _ENABLE_BG
#pragma shader_feature __ _ENABLE_FG


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
		fixed4 color : COLOR;
		float2 texcoord  : TEXCOORD0;
		float4 worldPosition : TEXCOORD1;
		UNITY_VERTEX_OUTPUT_STEREO
	};

	sampler2D _MainTex;
	fixed4 _Color;
	fixed4 _TextureSampleAdd;
	float4 _ClipRect;
	float4 _MainTex_ST;
	float _MaskOffsetX;
	float _MaskOffsetScaleX;
	float _MaskOffsetY;
	float _MaskOffsetScaleY;
	sampler2D _MaskTex1;
	sampler2D _MaskTex2;
#ifdef _ENABLE_BG
	sampler2D _BackGround;
#endif
#ifdef _ENABLE_FG
	sampler2D _ForeGround;
#endif
	float _MainAlpha;
	float _MaskType;
	bool _AddColorMode;


	half4 blend_color(half4 c1, half4 c2)
	{
		half4 result = half4(0, 0, 0, max(c1.a, c2.a));
		result.rgb = c1.rgb * (1 - c2.a) + c2.rgb * c2.a;
		return result;
	}

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

	fixed4 frag(v2f IN) : SV_Target
	{
		half4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd);// * IN.color;
		if(IN.texcoord.y < 0 || IN.texcoord.y > 1)
		{
			color.a = 0;
		}
        color.a = clamp(color.a * _MainAlpha , 0, 1);
		half4 maskColor;
		float2 maskTexcoord = float2((IN.texcoord.x + _MaskOffsetX) / _MaskOffsetScaleX, (IN.texcoord.y + _MaskOffsetY) / _MaskOffsetScaleY ); 
		if(_MaskType >= 3)
		{
			maskColor = tex2D(_MaskTex2, maskTexcoord);
		}
		else
		{
			maskColor = tex2D(_MaskTex1, maskTexcoord);
		}
		float maskAlpha = 1; 
		if(_MaskType == 1 || _MaskType == 3)
		{
			maskAlpha = maskColor.r;
		}
		else if(_MaskType == 2 || _MaskType == 4)
		{
			maskAlpha = maskColor.g;
		}
#ifdef _ENABLE_OUTCLIP
		maskAlpha *= step(0, maskTexcoord.x);
		maskAlpha *= step(maskTexcoord.x, 1);
		maskAlpha *= step(0, maskTexcoord.y);
		maskAlpha *= step(maskTexcoord.y, 1);
#endif

		if(_AddColorMode)
		{
			color.rgb += IN.color.rgb * IN.color.a;
		}

#ifdef _ENABLE_BG
		half4 bgColor = tex2D(_BackGround, IN.texcoord);//用的是变换前的大底图，和人像图一样大，会被裁剪
		//half4 bgColor = half4(0, 0, 0, 0.7);
		color = blend_color(bgColor, color);
#endif

#ifdef _ENABLE_FG
		half4 fgColor = tex2D(_ForeGround, maskTexcoord);
		color = blend_color(color, fgColor);
#endif
		color.a *= maskAlpha;
		
		if(!_AddColorMode)
		{
			color *= IN.color;
		}
	
#ifdef UNITY_UI_CLIP_RECT
		color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
#endif

#ifdef UNITY_UI_ALPHACLIP
		clip(color.a - 0.001);
#endif
		
		
		return color;
	}
		ENDCG
	}
	}
}
