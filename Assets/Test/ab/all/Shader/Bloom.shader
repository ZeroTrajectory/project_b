Shader "DarkBoom/Bloom"
{
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
		_BloomTex("Bloom (RGB)", 2D) = "black"{}
		_LuminanceThreshold("Luminance Threshold", Float) = 0.5
		_BlurSize("Blur Size", Float) = 1.0
		_BloomValue("BloomValue", Float) = 8
		_BloomColor("BloomValue", Color) = (1, 0.9287547, 0.7122642, 1.0)
	}

	SubShader
	{
		CGINCLUDE
#include "UnityCG.cginc"
		sampler2D _MainTex;
		half4 _MainTex_TexelSize;
		sampler2D _BloomTex;
		float _LuminanceThreshold;
		float _BlurSize;
		float _BloomValue;
		half4 _BloomColor;

		struct appdata
		{
			float4 vertex:POSITION;
			float2 uv:TEXCOORD0;
		};

		struct v2f
		{
			float4 pos : SV_POSITION;
			half2 uv : TEXCOORD0;
		};

		struct v2fBloom
		{
			float4 pos : SV_POSITION;
			half4 uv : TEXCOORD0;
		};

		//亮度值采样
		fixed luminance(fixed4 color) {
			return 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
		}
		//-------------bright--------------------------------------
		//顶点着色器与之前相同
		v2f vertExtractBright(appdata_img v) {
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv = v.texcoord;
			return o;
		}
		fixed4 fragExtractBright(v2f i) : SV_Target
		{
			fixed4 c = tex2D(_MainTex, i.uv);
			fixed val = clamp(luminance(c) - _LuminanceThreshold, 0.0, 1.0);
			return c * val;
		}
		//--------------bloom--------------------------------------
		v2fBloom vertBloom(appdata_img v) {
			v2fBloom o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv.xy = v.texcoord;
			o.uv.zw = v.texcoord;
			//平台差异化处理
			//判断是否时DirectX平台(uv从顶部开始)
	#if UNITY_UV_STARTS_AT_TOP
			if (_MainTex_TexelSize.y < 0.0)
				o.uv.w = 1.0 - o.uv.w;
	#endif
			return o;
		}

		fixed4 fragBloom(v2fBloom i) : SV_Target
		{
			return tex2D(_MainTex, i.uv.xy) + (tex2D(_BloomTex,i.uv.zw) + tex2D(_BloomTex,i.uv.zw)) * _BloomColor * _BloomValue;
		}
		//--------------blurSimple--------------------------------------
		v2f vertBlurSimple(appdata v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv = v.uv;// TRANSFORM_TEX(v.uv, _MainTex);
			return o;
		}

		fixed4 fragBlurSimple(v2f i) : SV_Target
		{
			fixed4 col = 0.28 * tex2D(_MainTex,i.uv);
			col += 0.11 * tex2D(_MainTex, i.uv + half2(0.01,  0.01) * _BlurSize);
			col += 0.11 * tex2D(_MainTex, i.uv + half2(0.01, -0.01) * _BlurSize);
			col += 0.11 * tex2D(_MainTex, i.uv + half2(-0.01,  0.01) * _BlurSize);
			col += 0.11 * tex2D(_MainTex, i.uv + half2(-0.01, -0.01) * _BlurSize);

			col += 0.07 * tex2D(_MainTex, i.uv + half2(0.01,   0.01) * _BlurSize * 2);
			col += 0.07 * tex2D(_MainTex, i.uv + half2(0.01,  -0.01) * _BlurSize * 2);
			col += 0.07 * tex2D(_MainTex, i.uv + half2(-0.01,  0.01) * _BlurSize * 2);
			col += 0.07 * tex2D(_MainTex, i.uv + half2(-0.01, -0.01) * _BlurSize * 2);

			return col;
		}
		//--------------blur--------------------------------------
	
		fixed4 fragBlurHorizontal(v2f i) : SV_Target
		{
			fixed4 col = 0.28 * tex2D(_MainTex,i.uv);
			col += 0.22 * tex2D(_MainTex, i.uv + half2(-0.01, 0) * _BlurSize);
			col += 0.22 * tex2D(_MainTex, i.uv + half2( 0.01, 0) * _BlurSize);
			col += 0.14 * tex2D(_MainTex, i.uv + half2(-0.01,  0) * _BlurSize * 2);
			col += 0.14 * tex2D(_MainTex, i.uv + half2( 0.01,  0) * _BlurSize * 2);
			return col;
		}

		fixed4 fragBlurVertical(v2f i) : SV_Target
		{
			fixed4 col = 0.28 * tex2D(_MainTex,i.uv);
			col += 0.22 * tex2D(_MainTex, i.uv + half2(0, -0.01) * _BlurSize);
			col += 0.22 * tex2D(_MainTex, i.uv + half2(0,  0.01) * _BlurSize);
			col += 0.14 * tex2D(_MainTex, i.uv + half2(0, -0.01) * _BlurSize * 2);
			col += 0.14 * tex2D(_MainTex, i.uv + half2(0,  0.01) * _BlurSize * 2);
			return col;
		}

		ENDCG

		ZTest Always 
		Cull Off 
		Zwrite Off

		Pass
		{
			Name "bright"
			CGPROGRAM
	#pragma vertex vertExtractBright
	#pragma fragment fragExtractBright		
			ENDCG
		}
		Pass
		{
			Name "blur_simple"
				CGPROGRAM
#pragma vertex vertBlurSimple
#pragma fragment fragBlurSimple
				ENDCG
		}
		Pass
		{
			Name "bloom"
			CGPROGRAM
	#pragma vertex vertBloom
	#pragma fragment fragBloom	
			ENDCG
		}
		//-------------------------------------------------

		Pass 
		{
			NAME "blur_vertical"
			CGPROGRAM
#pragma vertex vertBlurSimple  
#pragma fragment fragBlurVertical
			ENDCG
		}

		Pass 
		{
			NAME "blur_horizontal "
			CGPROGRAM
#pragma vertex vertBlurSimple  
#pragma fragment fragBlurHorizontal
			ENDCG
		}
	}
	Fallback Off
}