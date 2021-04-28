Shader "Custom/Sprite-Outline"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)

		_OutlineThickness ("Outline Thickness", Float) = 1.0
		_Threshold ("Threshold", Range(0,1)) = 0.5
        _OutlineColor ("Outline Color", Color) = (0,1,0,1)
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
 
		Cull Off
		Lighting Off
		ZWrite Off
		//Blend One OneMinusSrcAlpha
		Blend SrcAlpha OneMinusSrcAlpha
 
		Pass
		{
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0
			#pragma multi_compile _ PIXELSNAP_ON
			#pragma multi_compile _ ETC1_EXTERNAL_ALPHA
			#include "UnityCG.cginc"
			
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
				fixed4 color    : COLOR;
				float2 texcoord  : TEXCOORD0;
				UNITY_VERTEX_OUTPUT_STEREO
			};
			
			fixed4 _Color;
			float _OutlineThickness;
			float _Threshold;  
            fixed4 _OutlineColor;
 
			v2f vert(appdata_t IN)
			{
				v2f OUT;
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
				OUT.vertex = UnityObjectToClipPos(IN.vertex);
				OUT.texcoord = IN.texcoord;
				OUT.color = IN.color * _Color;
				#ifdef PIXELSNAP_ON
				OUT.vertex = UnityPixelSnap (OUT.vertex);
				#endif
 
				return OUT;
			}
 
			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			sampler2D _AlphaTex;
 
			fixed4 SampleSpriteTexture (float2 uv)
			{
				fixed4 color = tex2D (_MainTex, uv);
 
#if ETC1_EXTERNAL_ALPHA
				// get the color from an external texture (usecase: Alpha support for ETC1 on android)
				color.a = tex2D (_AlphaTex, uv).r;
#endif //ETC1_EXTERNAL_ALPHA
 
				return color;
			}
 
			fixed4 frag(v2f IN) : SV_Target
			{
				fixed4 c = SampleSpriteTexture (IN.texcoord) ;


				fixed4 pixelUp = tex2D(_MainTex, IN.texcoord + fixed2(0, _MainTex_TexelSize.y*_OutlineThickness));  
                fixed4 pixelDown = tex2D(_MainTex, IN.texcoord - fixed2(0, _MainTex_TexelSize.y*_OutlineThickness));  
                fixed4 pixelRight = tex2D(_MainTex, IN.texcoord + fixed2(_MainTex_TexelSize.x*_OutlineThickness, 0));  
                fixed4 pixelLeft = tex2D(_MainTex, IN.texcoord - fixed2(_MainTex_TexelSize.x*_OutlineThickness, 0));  
                fixed4 pixel5 = tex2D(_MainTex, IN.texcoord + fixed2(_MainTex_TexelSize.x*_OutlineThickness, _MainTex_TexelSize.y*_OutlineThickness));  
                fixed4 pixel6 = tex2D(_MainTex, IN.texcoord + fixed2(-_MainTex_TexelSize.x*_OutlineThickness, _MainTex_TexelSize.y*_OutlineThickness));  
                fixed4 pixel7 = tex2D(_MainTex, IN.texcoord + fixed2(_MainTex_TexelSize.x*_OutlineThickness, -_MainTex_TexelSize.y*_OutlineThickness));  
                fixed4 pixel8 = tex2D(_MainTex, IN.texcoord + fixed2(-_MainTex_TexelSize.x*_OutlineThickness, -_MainTex_TexelSize.y*_OutlineThickness));  

                fixed4 outline =  max(max(max(pixelUp, pixelDown), max(pixelRight,pixelLeft)) ,
                max(max(pixel5, pixel6), max(pixel7,pixel8)) ) * _OutlineColor;

                if(c.a > _Threshold)
                	return c * IN.color;
                return lerp(c.rgba * IN.color ,outline,1- c.a);
		
				//return float4(IN.texcoord.x, IN.texcoord.y,1,1);//tex2D(_MainTex, IN.texcoord);
				return c;
			}
		ENDCG
		}
	}
}