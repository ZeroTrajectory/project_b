Shader "fx_shader/fx_lizifaguang_n"
{
	Properties
	{
		[HDR]_Color ("MainColor",Color)=(0.5,0.5,0.5,0.5)
		_MainTex ("Texture", 2D) = "white" {}		


	}
	SubShader
	{
		Tags {"QUEUE"="Transparent" "IGNOREPROJECTOR"="true" "RenderType"="Transparent" }
		ZWrite Off
		Cull Off
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			
			#include "UnityCG.cginc"

			struct appdata
			{	
				fixed4 color:COLOR;
				float4 vertex : POSITION;
				float4 texcoord0 : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv0 : TEXCOORD0;
				float4 vertex : SV_POSITION;
				fixed4 color:COLOR;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;


			fixed4 _Color;



			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color;
				o.uv0 = TRANSFORM_TEX(v.texcoord0,_MainTex);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{

				fixed4 _MainTex_var = tex2D(_MainTex, i.uv0);

						
				float3 MainTexAndColor =_MainTex_var.rgb * _Color.rgb * i.color.rgb;
				
			
				return fixed4(MainTexAndColor , _MainTex_var.a* _Color.a* i.color.a);
				
			}
			ENDCG
		}
	}
	
}
