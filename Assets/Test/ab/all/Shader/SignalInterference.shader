// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "UI/SignalInterference"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		_Color("Tint", Color) = (1, 1, 1, 1)

		_LightTex("Light Texture", 2D) = "white" {}
		_LightColor("Light Color",Color) = (1,1,1,1)
		_LightPower("Light Power",Range(0,5)) = 1
		_LightDuration("Light Duration",Range(0,10)) = 1
		_LightInterval("Light Interval",Range(0,20)) = 4

		[MaterialToggle] PixelSnap("Pixel snap", float) = 0

		_StencilComp("Stencil Comparison", Float) = 8
		_Stencil("Stencil ID", Float) = 0
		_StencilOp("Stencil Operation", Float) = 0
		_StencilWriteMask("Stencil Write Mask", Float) = 255
		_StencilReadMask("Stencil Read Mask", Float) = 255
		//_ColorMask("Color Mask", Float) = 15

		_StripeColor("_Stripe Color", Color) = (1, 1, 1, 1)
		_NoiseRange("NoiseRange", Range(0,1))  = 1
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

		Cull Off
		Lighting Off
		ZWrite Off

		Stencil
		{
			Ref[_Stencil]
			Comp[_StencilComp]
			Pass[_StencilOp]
			ReadMask[_StencilReadMask]
			WriteMask[_StencilWriteMask]
		}

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			//ColorMask[_ColorMask]
			//Blend One One

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile _ PIXELSNAP_ON
			#include "UnityCG.cginc"

			struct appdata_t
			{
				float4 vertex : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
		};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				half2 texcoord : TEXCOORD0;
				float2 lightuv : TEXCOORD1;
				fixed4 color : COLOR;
			};

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _NoiseRange;

			float hash31(float3 p)
			{
				float f = dot(p, float3(127.1, 269.5, 311.7));
				//   return -1.0 + 2.0 * frac(sin(f) * 43758.5453123);
				return frac(sin(f) * 43758.5453123);
			}

			float perlin(float t) {
				return cos(_Time.x) * hash31(_Time.x * t * 5) * 0.1;// +sin(_Time.x * t * 5) * 10;
			}

			fixed4 fringecolor(fixed4 src, fixed4 dsc)
			{
				fixed3 rgb = src.rgb * dsc.rgb;
				fixed a = src.a * dsc.a;

				return fixed4(rgb.r,rgb.g,rgb.b,a);
			}

			v2f vert(appdata_t IN)
			{
				v2f OUT;
				OUT.vertex = UnityObjectToClipPos(IN.vertex);
				OUT.texcoord = IN.texcoord;

#ifdef PIXELSNAP_ON
				OUT.vertex = UnityPixelSnap(OUT.vertex);
#endif
				OUT.color = IN.color * _Color;
				return OUT;
			}

			fixed4 frag(v2f IN) : SV_Target
			{
				fixed4 c = tex2D(_MainTex, IN.texcoord + fixed2(perlin(IN.texcoord.y),0) * _NoiseRange) * IN.color;

				return c;
			}
		ENDCG
		}

		Pass
		{
			Blend One One

			CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma multi_compile _ PIXELSNAP_ON
#include "UnityCG.cginc"

		struct appdata_t
		{
			float4 vertex : POSITION;
			float2 texcoord : TEXCOORD0;
		};

		struct v2f
		{
			float4 vertex : SV_POSITION;
			half2 texcoord : TEXCOORD0;
		};

		fixed4 _StripeColor;

		sampler2D _MainTex;

		v2f vert(appdata_t IN)
		{
			v2f OUT;
			//OUT.vertex = UnityObjectToClipPos(IN.vertex);
			OUT.vertex = UnityObjectToClipPos(IN.vertex);
			OUT.texcoord = IN.texcoord;

#ifdef PIXELSNAP_ON
			OUT.vertex = UnityPixelSnap(OUT.vertex);
#endif

				return OUT;
			}

			fixed4 frag(v2f IN) : SV_Target
			{
				fixed4 c = tex2D(_MainTex, IN.texcoord);

				c.rgba = float4(_StripeColor.r, _StripeColor.g, _StripeColor.b, c.a * _StripeColor.a);

				fixed flash = fmod(_Time.y, 0.2);
				if (flash >= 0.1) {
					if (fmod(IN.texcoord.y, 0.01) <= 0.005)
						c.a = 0;
				}
				else
				{
					if (fmod(IN.texcoord.y + 0.002, 0.01) <= 0.005)
						c.a = 0;
				}

				c.rgb *= c.a;

				return c;
			}
			ENDCG
		}

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma multi_compile _ PIXELSNAP_ON
#include "UnityCG.cginc"

			struct appdata_t
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				half2 texcoord : TEXCOORD0;
				float2 lightuv : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _LightTex;
			float4  _LightTex_ST;

			half _LightInterval;
			half _LightDuration;

			half4 _LightColor;
			half _LightPower;

			half _LightOffSetX;
			half _LightOffSetY;

			v2f vert(appdata_t IN)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(IN.vertex);
				fixed currentTimePassed = saturate(fmod(_Time.y * 0.2, 1) * 4) ;
				//uv offset, Sprite wrap mode need "Clamp"
				fixed offsetX = currentTimePassed / _LightDuration;
				fixed offsetY = currentTimePassed / _LightDuration;

				o.lightuv = IN.texcoord + fixed2(offsetX, offsetY);
				o.lightuv = TRANSFORM_TEX(o.lightuv, _LightTex);
				
				o.texcoord = TRANSFORM_TEX(IN.texcoord, _MainTex);
				return o;
			}

			fixed4 frag(v2f IN) : SV_Target
			{
				fixed4 mainCol = tex2D(_MainTex, IN.texcoord);
				fixed4 lightCol = tex2D(_LightTex, IN.lightuv);
				lightCol *= _LightColor;

				fixed4 fininalCol;
				fininalCol.rgb = lightCol.rgb + mainCol.rgb * _LightPower /** mainCol.a*/;
				fininalCol.a = lightCol.a * mainCol.a;
				return fininalCol;
			}
			ENDCG
		}
	}
}