// This is a premultiply-alpha adaptation of the built-in Unity shader "UI/Default" in Unity 5.6.2 to allow Unity UI stencil masking.

Shader "Spine/SkeletonGraphicStencil (Premultiply Alpha)"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		_Color2("Tint2", Color) = (1,1,1,1)

		_StencilComp ("Stencil Comparison", Float) = 8
		_Stencil ("Stencil ID", Float) = 0
		_StencilOp ("Stencil Operation", Float) = 0
		_StencilWriteMask ("Stencil Write Mask", Float) = 255
		_StencilReadMask ("Stencil Read Mask", Float) = 255

		_ColorMask ("Color Mask", Float) = 15

		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0

		[Space(50)]
		[Toggle(_ENABLE_SIGNAL)] _ENABLE_SIGNAL("EnableSignal", Int) = 0
		[NoScaleOffset]
		_FlowLightTex("FlowLightTex", 2D) = "white" {}
		_SignalNoise("SignalNoise", Range(0, 1)) = 0

		[Space(50)]
		[Toggle(_ENABLE_DARK)] _ENABLE_DARK("EnableDark", Int) = 0
		_DarkTex("_DarkTex", 2D) = "white" {}

		[Space(50)]
		[Toggle(_ENABLE_BLUR)] _ENABLE_BLUR("EnableBlur", Int) = 0
		_BlurSize("_BlurSize", range(0, 2)) = 0.2

		[Space(50)]
		[Toggle(_ENABLE_GRAY)] _ENABLE_GRAY("ENABLE_GRAY", Int) = 0
		_GraySize("_GraySize", range(0, 1)) = 1
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
		Fog { Mode Off }
		Blend SrcAlpha OneMinusSrcAlpha
		//Blend One Zero
		ColorMask [_ColorMask]

		Pass
		{
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0

			#include "UnityCG.cginc"
			#include "UnityUI.cginc"

			#pragma multi_compile __ UNITY_UI_ALPHACLIP
			#pragma multi_compile __ _ENABLE_SIGNAL
			#pragma multi_compile __ _ENABLE_DARK
			#pragma multi_compile __ _ENABLE_BLUR
			#pragma multi_compile __ _ENABLE_GRAY

			struct VertexInput {
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput {
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				half3 texcoord  : TEXCOORD0;
				float4 worldPosition : TEXCOORD1;
				fixed4 color2 : TEXCOORD2;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			fixed4 _Color;
			fixed4 _Color2;
			fixed4 _TextureSampleAdd;
			float4 _ClipRect;
			
#if _ENABLE_SIGNAL
	float _SignalNoise;
	sampler2D _FlowLightTex;
#endif

#if _ENABLE_DARK
	sampler2D _DarkTex;
	float _OffsetY =0;
	float _SpineScale = 0.5;
#endif

#if _ENABLE_BLUR
	float _BlurSize;
#endif

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

		VertexOutput vert (VertexInput IN) {
			VertexOutput OUT;

			UNITY_SETUP_INSTANCE_ID(IN);
			UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);

			OUT.worldPosition = IN.vertex;
			OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);
			OUT.texcoord.xy = IN.texcoord;
			OUT.texcoord.z = IN.vertex.y;

			#ifdef UNITY_HALF_TEXEL_OFFSET
			OUT.vertex.xy += (_ScreenParams.zw-1.0) * float2(-1,1);
			#endif

			OUT.color = IN.color * float4(_Color.rgb * _Color.a, _Color.a); // Combine a PMA version of _Color with vertexColor.
			OUT.color2 = _Color2;
			return OUT;
		}

		sampler2D _MainTex;

		fixed4 frag (VertexOutput IN) : SV_Target
		{
			float3 mTexcoord = IN.texcoord;

			half4 totalColor;
			#if _ENABLE_BLUR
				totalColor = Blur(_MainTex, IN.texcoord, _BlurSize);
			#else
				totalColor = tex2D(_MainTex, IN.texcoord);
			#endif
			#if _ENABLE_SIGNAL//信号干扰效果
				if (totalColor.a > 0.01 && fmod((-mTexcoord.z * 0.001 + 1 + _Time.y * 0.05) % 1, 0.01) > 0.005)
				{
					totalColor.rgb = totalColor.rgb + half3(0.1686, 0.2196, 0.3215);//横向条纹
				}
				totalColor.rgb *= saturate(random(IN.texcoord.x, IN.texcoord.y * _Time.y % 1) + (1 - _SignalNoise));//噪点

				half flowLightOffset = (_Time.y * 0.2 % 1) * 30;

				float4 flowLightColor = tex2D(_FlowLightTex, float2(IN.texcoord.x, mTexcoord.z * 0.01 + 15 - flowLightOffset));
				totalColor.rgb = totalColor.rgb + flowLightColor.rgb;
				totalColor.rgb = totalColor.rgb * half3(0.5725, 0.7764, 1);//主色
			#else

			#endif

			half4 color = (totalColor + _TextureSampleAdd) * IN.color;

			#if _ENABLE_GRAY
				fixed3 grayCol = dot(color.rgb, fixed3(0.3, 0.59, 0.11));
				color.rgb = lerp(color.rgb, grayCol, _GraySize);
			#endif
			

			#if _ENABLE_DARK
				half spineDefaultHeight = 2048;
				if(_SpineScale == 0)
				{
				    _SpineScale = 0.5;
				}
				color.rgb *= tex2D(_DarkTex, float2(IN.texcoord.x, (IN.texcoord.z+spineDefaultHeight*_SpineScale*0.5-_OffsetY)/(spineDefaultHeight*(_SpineScale-0.1)))).a;
			#endif

		    //修复改动canvasGroup的alpha时会导致高亮的问题
			color.rgb *= IN.color.a;
			color *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);

			#ifdef UNITY_UI_CLIP_RECT
			    color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
			#endif

			#ifdef UNITY_UI_ALPHACLIP
				clip (color.a - 0.001);
			#endif

			color.rgb = IN.color2.rgb;
			color.a = IN.color.a;
			return color;
		}
		ENDCG
		}
	}
}