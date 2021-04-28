Shader "fx_shader/Post"
{
	Properties
	{
		[HDR]_Color("Color", Color) = (1,1,1,1)
		[NoScaleOffset]_Maintex("Maintex", 2D) = "white" {}
		[Toggle]_AutoSwitch("AutoSwitch", Float) = 0
		_ScaleOffset("ScaleOffset", Vector) = (1,1,0,0)
		_Power("Power", Float) = 1
		_Rotator("Rotator", Float) = 0
		_Mask("Mask", 2D) = "white" {}
	}
	
	SubShader
	{

		Tags { "RenderType"="Opaque" "Queue"="Transparent" "Transparent"="0" }
		LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off
		ColorMask RGBA
		ZWrite Off
		ZTest LEqual
		
		
		
		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 texcoord : TEXCOORD0;
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 color : COLOR;
				float4 texcoord : TEXCOORD0;
			};

			uniform half4 _Color;
			uniform sampler2D _Maintex;
			uniform half _Rotator;
			uniform half _Power;
			uniform half4 _ScaleOffset;
			uniform half _AutoSwitch;
			uniform sampler2D _Mask;
			uniform float4 _Mask_ST;
			
			v2f vert ( appdata v )
			{
				v2f o;
				o.color = v.color;
				o.texcoord.xy = v.texcoord.xy;
				o.texcoord.zw = 0;
				float3 vertexValue = float3(0, 0, 0);
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				fixed4 finalColor;
				float2 uv01 = i.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float cos3 = cos( ( ( ( 1.0 - length( (uv01*2.0 + -1.0) ) ) * 2.0 * _Rotator ) * UNITY_PI ) );
				float sin3 = sin( ( ( ( 1.0 - length( (uv01*2.0 + -1.0) ) ) * 2.0 * _Rotator ) * UNITY_PI ) );
				float2 rotator3 = mul( uv01 - float2( 0.5,0.5 ) , float2x2( cos3 , -sin3 , sin3 , cos3 )) + float2( 0.5,0.5 );
				float2 UVrotator37 = rotator3;
				float2 temp_output_4_0 = (UVrotator37*2.0 + -1.0);
				float2 break6 = temp_output_4_0;
				float2 appendResult14 = (float2(pow( length( temp_output_4_0 ) , _Power ) , ( ( atan2( break6.y , break6.x ) / UNITY_PI ) + 1.0 )));
				float2 appendResult17 = (float2(_ScaleOffset.x , _ScaleOffset.y));
				float2 appendResult49 = (float2(_ScaleOffset.z , _ScaleOffset.w));
				float2 appendResult18 = (float2(( _ScaleOffset.z * _Time.y ) , ( _ScaleOffset.w * _Time.y )));
				float2 uv_Mask = i.texcoord.xy * _Mask_ST.xy + _Mask_ST.zw;								
				finalColor = ( _Color * i.color * ( tex2D( _Maintex, (appendResult14*appendResult17 + lerp(appendResult49,appendResult18,_AutoSwitch)) ) * tex2D( _Mask, uv_Mask ).r ) );
				return finalColor;
			}
			ENDCG
		}
	}		
}
