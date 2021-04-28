Shader "DarkBoom/PatchImage"
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

        _Flashing("Flashing", Float) = 0.05
		_ColorMask("Color Mask", Float) = 15

		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip("Use Alpha Clip", Float) = 0


		[Space(150)]
		[Toggle(_ENABLE_PATCH)] _ENABLE_PATCH("EnablePatch", Int) = 0
		[NoScaleOffset]
		_PatchTex("PatchTex", 2D) = "white" {}
		_PatchRect("PatchRect", vector) = (0,0,100,100)
		_MaxWidth("MaxWidth", vector) = (2048, 2048, 0, 0)

		[Space(100)]
		[Toggle(_ENABLE_SIGNAL)] _ENABLE_SIGNAL("EnableSignal", Int) = 0
		[NoScaleOffset]
		_FlowLightTex("FlowLightTex", 2D) = "white" {}
		_SignalNoise("SignalNoise", Range(0, 1)) = 0
		_SignalHeight("SignalHeight", Range(0.0001, 1)) = 0.005

		[Space(100)]
		[Toggle(_ENABLE_DARK)] _ENABLE_DARK("EnableDark", Int) = 0
		_DarkTex("_DarkTex", 2D) = "white" {}

		//[Space(100)]
		//[Toggle(_ENABLE_BLUR)] _ENABLE_BLUR("EnableBlur", Int) = 0
		//_BlurSize("_BlurSize", range(0, 2)) = 0.5

		[Space(100)]
		[Toggle(_ENABLE_GRAY)] _ENABLE_GRAY("ENABLE_GRAY", Int) = 0
		_GraySize("_GraySize", range(0, 1)) = 1
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


#pragma multi_compile __ _ENABLE_PATCH
#pragma multi_compile __ _ENABLE_SIGNAL
#pragma multi_compile __ _ENABLE_DARK
//#pragma multi_compile __ _ENABLE_BLUR
#pragma multi_compile __ _ENABLE_GRAY

		

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
	float _Flashing;
	fixed4 _Color;
	fixed4 _TextureSampleAdd;
	float4 _ClipRect;
	float4 _MainTex_ST;

#if _ENABLE_PATCH
	sampler2D _PatchTex;
	float4 _PatchTex_ST;
	float4 _PatchRect;
	float2 _MaxWidth;
	
#endif

#if _ENABLE_SIGNAL
	float _SignalNoise;
	float _SignalHeight;
	sampler2D _FlowLightTex;
#endif

#if _ENABLE_DARK
	sampler2D _DarkTex;
#endif

//#if _ENABLE_BLUR
//	float _BlurSize;
//#endif

#if _ENABLE_GRAY
	float _GraySize;
#endif



	float random(float x, float y)
	{
		return frac(sin(dot(float2(x, y), float2(12.9898, 78.233))) * 43758.5453);
	}

	fixed4 Blur(sampler2D tex, half2 uv, float size)
	{
		fixed4 col = 0.08 * tex2D(tex, uv);
		col += 0.06 * tex2D(tex, uv + half2(0, -0.01) * size);
		col += 0.06 * tex2D(tex, uv + half2(0,  0.01) * size);
		col += 0.06 * tex2D(tex, uv + half2(-0.01, 0) * size);
		col += 0.06 * tex2D(tex, uv + half2( 0.01, 0) * size);
		col += 0.06 * tex2D(tex, uv + half2(-0.01, -0.01) * size);
		col += 0.06 * tex2D(tex, uv + half2(-0.01,  0.01) * size);
		col += 0.06 * tex2D(tex, uv + half2(0.01, -0.01) * size);
		col += 0.06 * tex2D(tex, uv + half2(0.01, 0.01) * size);

		half param = 2;
		col += 0.035 * tex2D(tex, uv + half2(0, -0.01) * size * param);
		col += 0.035 * tex2D(tex, uv + half2(0,  0.01) * size * param);
		col += 0.035 * tex2D(tex, uv + half2(-0.01,  0) * size * param);
		col += 0.035 * tex2D(tex, uv + half2( 0.01,  0) * size * param);
		col += 0.035 * tex2D(tex, uv + half2(-0.01, -0.01) * size * param);
		col += 0.035 * tex2D(tex, uv + half2(-0.01,  0.01) * size * param);
		col += 0.035 * tex2D(tex, uv + half2(0.01, -0.01) * size * param);
		col += 0.035 * tex2D(tex, uv + half2(0.01, 0.01) * size * param);

		param = 3;
		col += 0.04 * tex2D(tex, uv + half2(0, -0.01) * size * param);
		col += 0.04 * tex2D(tex, uv + half2(0,  0.01) * size * param);
		col += 0.04 * tex2D(tex, uv + half2(-0.01,  0) * size * param);
		col += 0.04 * tex2D(tex, uv + half2( 0.01,  0) * size * param);
		return col;
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
		float2 mTexcoord = IN.texcoord;

		half4 totalColor;

#if _ENABLE_PATCH//补丁表情
		float2 scaledTexcoord = IN.texcoord * _MaxWidth;
		if (scaledTexcoord.x > _PatchRect.x + 0.7 &&
			scaledTexcoord.y > _PatchRect.y + 0.7 &&
			scaledTexcoord.x < _PatchRect.x - 0.7 + _PatchRect.z &&
			scaledTexcoord.y < _PatchRect.y - 0.7 + _PatchRect.w
			)
		{
			float2 scale = _MaxWidth / _PatchRect.zw;
			float2 offset = -_PatchRect.xy * scale / _MaxWidth;
			

			//#if _ENABLE_BLUR
			//	totalColor = Blur(_PatchTex, IN.texcoord * scale + offset, _BlurSize * scale * 0.8);
			//#else
				totalColor = tex2D(_PatchTex, IN.texcoord * scale + offset);
			//#endif

		}
		else
		{
			
			//#if _ENABLE_BLUR
			//	totalColor = Blur(_MainTex, IN.texcoord, _BlurSize);
			//#else
				totalColor = tex2D(_MainTex, IN.texcoord);
			//#endif
		}
		
#else
	//#if _ENABLE_BLUR
	//	totalColor = Blur(_MainTex, IN.texcoord, _BlurSize);
	//#else
		totalColor = tex2D(_MainTex, IN.texcoord);
	//#endif
#endif



		
	


#if _ENABLE_SIGNAL//信号干扰效果
		//mTexcoord.x = mTexcoord.x + random(mTexcoord.y, _Time.y) * 0.01;//左右抖动策划不需要

		if (fmod((-mTexcoord.y + 1 + _Time.y * _Flashing) % 1, _SignalHeight * 2) > _SignalHeight)
		{
			totalColor.rgb = totalColor.rgb + half3(0.1686, 0.2196, 0.3215);//横向条纹
		}
		totalColor.rgb *= saturate(random(IN.texcoord.x, IN.texcoord.y * _Time.y % 1) + (1 - _SignalNoise));//噪点

		half flowLightOffset = (_Time.y * 0.3 % 1) * 2;
		float4 flowLightColor = tex2D(_FlowLightTex, float2(IN.texcoord.x, IN.texcoord.y - flowLightOffset));
		totalColor.rgb = totalColor.rgb + flowLightColor.rgb;//流光
		totalColor.rgb = totalColor.rgb * half3(0.5725, 0.7764, 1);//主色
#else

#endif
		half4 color = (totalColor + _TextureSampleAdd) * IN.color;

#if _ENABLE_DARK
		color.rgb *= tex2D(_DarkTex, float2(IN.texcoord.x, IN.texcoord.y)).a;
#endif


#if _ENABLE_GRAY
		fixed3 grayCol = dot(color.rgb, fixed3(0.3, 0.59, 0.11));
		color.rgb = lerp(color.rgb, grayCol, _GraySize);
#endif


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

	Fallback "UI/Default"
}
