// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Spine/Skeleton Clip" {
	Properties {
		_Cutoff ("Shadow alpha cutoff", Range(0,1)) = 0.1
		_WaterLevel ("Water level", float) = 0
		[NoScaleOffset] _MainTex ("Main Texture", 2D) = "black" {}
		_Color("Color_Tint",COLOR) = (1,1,1,1)
	}

	SubShader {
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane"}

		Fog { Mode Off }
		Cull Off
		ZWrite Off
		Blend One OneMinusSrcAlpha
		Lighting Off

		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#pragma multi_compile _ DISABLE_WATER_LEVEL
			
			sampler2D _MainTex;
			fixed _WaterLevel;
			float4 _Color;
			struct VertexInput {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 color : COLOR;
			};

			struct VertexOutput {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 posList : TEXCOORD1;
				float4 color : COLOR;
			};

			VertexOutput vert (VertexInput v) {
				VertexOutput o = (VertexOutput)0;
				o.uv = v.uv;
				o.pos = UnityObjectToClipPos(v.vertex); // Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'
				o.posList.x = mul(unity_ObjectToWorld, v.vertex).y;//x为世界坐标的y y为物体坐标的z
				o.posList.y = mul(unity_ObjectToWorld, float4(0.0,0,0.0,1.0)).z;
				o.color = v.color;
				return o;
			}

			float4 frag (VertexOutput i) : COLOR {
				float4 rawColor = tex2D(_MainTex,i.uv) * i.color*_Color;				
				#ifndef DISABLE_WATER_LEVEL
				    fixed clipWaterLevel = i.posList.y + _WaterLevel;//z代表了此刻角色原点y轴的位置，加上偏移算出水面y位置
				    clip(i.posList.x - clipWaterLevel);//物体世界坐标的y与计算出的水面对比算出clip
				#endif
				return rawColor;
			}
			ENDCG
		}

		// Pass {
		// 	Name "Caster"
		// 	Tags { "LightMode"="ShadowCaster" }
		// 	Offset 1, 1
		// 	ZWrite On
		// 	ZTest LEqual

		// 	Fog { Mode Off }
		// 	Cull Off
		// 	Lighting Off

		// 	CGPROGRAM
		// 	#pragma vertex vert
		// 	#pragma fragment frag
		// 	#pragma multi_compile_shadowcaster
		// 	#pragma fragmentoption ARB_precision_hint_fastest
		// 	#include "UnityCG.cginc"
		// 	sampler2D _MainTex;
		// 	fixed _Cutoff;			

		// 	struct v2f { 
		// 		V2F_SHADOW_CASTER;
		// 		float2  uv : TEXCOORD1;
		// 	};

		// 	v2f vert (appdata_base v) {
		// 		v2f o;
		// 		TRANSFER_SHADOW_CASTER(o)
		// 		o.uv = v.texcoord;
		// 		return o;
		// 	}

		// 	float4 frag (v2f i) : COLOR {
		// 		fixed4 texcol = tex2D(_MainTex, i.uv);
		// 		SHADOW_CASTER_FRAGMENT(i)
		// 	}
		// 	ENDCG
		// }
	}

	// SubShader {
	// 	Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }

	// 	Cull Off
	// 	ZWrite Off
	// 	Blend One OneMinusSrcAlpha
	// 	Lighting Off

	// 	Pass {
	// 		ColorMaterial AmbientAndDiffuse
	// 		SetTexture [_MainTex] {
	// 			Combine texture * primary DOUBLE, texture * primary
	// 		}
	// 	}
	// }
}
