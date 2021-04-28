Shader "Spine/Skeleton Clip 4Line" {
	Properties {
		_Clip_Offset ("Clip Offset", Range(-0.5, 0.5)) = 0
		_Line_0 ("Line 0", vector) = (0,0,0,0)
		_Line_1 ("Line 1", vector) = (0,0,0,0)
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
			
			sampler2D _MainTex;
			float4 _Color;
			fixed4 _Line_0;
			fixed4 _Line_1;
			fixed _Clip_Offset;

			struct VertexInput {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 color : COLOR;
			};

			struct VertexOutput {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 localPos : TEXCOORD1;
				float4 color : COLOR;
			};

			VertexOutput vert (VertexInput v) {
				VertexOutput o = (VertexOutput)0;
				o.uv = v.uv;
				o.pos = UnityObjectToClipPos(v.vertex); // Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'
				o.localPos = v.vertex;
				o.color = v.color;
				return o;
			}

			fixed LineDis(fixed2 startPos, fixed2 endPos, fixed2 pointPos)
			{
				fixed a = endPos.y - startPos.y;
				fixed b = startPos.x - endPos.x;
				fixed c = endPos.x * startPos.y - startPos.x * endPos.y;
				return (a * pointPos.x + b * pointPos.y + c) * rsqrt(a * a + b * b);
			}

			float4 frag (VertexOutput i) : COLOR {
				float4 rawColor = tex2D(_MainTex,i.uv) * i.color * _Color;	
				float clipValue = LineDis(_Line_0.xy, _Line_0.zw, i.localPos);
				clipValue = clipValue * LineDis(_Line_1.xy, _Line_1.zw, i.localPos);
				clip(clipValue - _Clip_Offset);
				//return fixed4(clipValue, 0, 0, 1);	
				return rawColor;
			}
			ENDCG
		}
	}
}
