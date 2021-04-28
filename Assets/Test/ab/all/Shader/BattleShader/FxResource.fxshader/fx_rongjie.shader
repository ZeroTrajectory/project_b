Shader "fx_shader/fx_rongjie"
{
	Properties
	{
		_Color ("MainColor",Color)=(0.5,0.5,0.5,0.5)
		_MainTex ("Texture", 2D) = "white" {}		
		_Noise ("DissolvedMap",2D)="white"{}
		_EdgeWidth ("EdgeWidth",Range(0.001,1))=0.1
		[HDR]_EdgeColor("EdgeColor",Color)=(1,1,1,1)
		_CutAmount("CutAmount",Range(0,1))=1
	}
	SubShader
	{
		Tags {"QUEUE"="Transparent" "IGNOREPROJECTOR"="true" "RenderType"="Transparent" }
		ZWrite Off
		Cull Off
		Blend SrcAlpha One

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
				float2 uv1 : TEXCOORD1;
				float4 vertex : SV_POSITION;
				fixed4 color:COLOR;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _Noise;
			float4 _Noise_ST;

			fixed4 _Color;
			fixed4 _EdgeColor;

			float _CutAmount;
			float _EdgeWidth;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color;
				o.uv0 = TRANSFORM_TEX(v.texcoord0,_MainTex);
				o.uv1 = TRANSFORM_TEX(v.texcoord0,_Noise);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 _Noise_var = tex2D(_Noise,i.uv1);
				fixed4 _MainTex_var = tex2D(_MainTex, i.uv0);
				float cutEdge =_Noise_var.a-_CutAmount* (1-i.color.a);
				//比噪波小的色块就输
				clip (cutEdge);
				//smoothstep最小值是0，最大值是_EdgeWidth。
				fixed t=1-smoothstep(0, _EdgeWidth, cutEdge);			
				fixed3 finalColor = lerp(_MainTex_var.rgb*i.color.rgb*_Color.rgb, _EdgeColor.rgb,t * step(0.0001, _CutAmount*(1-i.color.a)));				
				return fixed4(finalColor*i.color.rgb, _MainTex_var.a);
			
			}
			ENDCG
		}
	}
	
}
