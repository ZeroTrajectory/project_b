Shader "Unlit/CircleShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_ClipAngle("ClipAngle", Range(0,1)) = 0
		_Smooth("Smooth", Range(0,0.1)) = 0
	}
	SubShader
	{
		Tags { "Queue"="Transparent" }
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			fixed _ClipAngle;
			fixed _Smooth;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
			    fixed2 offsetUv = i.uv - 0.5;
			    fixed angle = atan2(offsetUv.x, -offsetUv.y);
			    fixed a = (angle/UNITY_PI + 1.) * 0.5;
			    a *= (1. - _Smooth);
			    a = smoothstep(_ClipAngle, _ClipAngle - _Smooth, a);
				fixed4 col = tex2D(_MainTex, i.uv);
				col.a *= a;
				return col;
			}
			ENDCG
		}
	}
}
