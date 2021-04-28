Shader "DDS/Hologram"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)

		 _HologramTex ("Hologram Texture", 2D)= "white" {}
		 _RandomTex ("Random Texture", 2D)= "white" {}


		_StencilComp ("Stencil Comparison", Float) = 8
		_Stencil ("Stencil ID", Float) = 0
		_StencilOp ("Stencil Operation", Float) = 0
		_StencilWriteMask ("Stencil Write Mask", Float) = 255
		_StencilReadMask ("Stencil Read Mask", Float) = 255

		_ColorMask ("Color Mask", Float) = 15

		_Timer ("Timer", Float ) = 0

		_Rate ("Rate", Float ) = 0

		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
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
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask [_ColorMask]

		Pass
		{
			Name "Default"
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0

			#include "UnityCG.cginc"
			#include "UnityUI.cginc"

			#pragma multi_compile __ UNITY_UI_ALPHACLIP
			
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
				float4 worldPosition : TEXCOORD1;
				UNITY_VERTEX_OUTPUT_STEREO
			};
			
			fixed4 _Color;
			fixed4 _TextureSampleAdd;
			float4 _ClipRect;

			v2f vert(appdata_t IN)
			{
				v2f OUT;
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
				OUT.worldPosition = IN.vertex;
				OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);

				OUT.texcoord = IN.texcoord;
				
				OUT.color = IN.color * _Color;
				return OUT;
			}

			sampler2D _MainTex;
			sampler2D _HologramTex;
			sampler2D _RandomTex;
			float _Timer;
			float _Rate;

			fixed4 frag(v2f IN) : SV_Target
			{

			    //half4 random=tex2D(_MainTex,fixed2(0.15,_Timer*0.2));

//			    //随机数
//			    float random= ; 

			    //电波斜率
			    float slope= saturate(sin(_Timer)-0.5) *2;

			    //噪波
			    float noise=saturate(cos(_Timer)-0.5) *2;

			    //电波图
				half4 hologram =tex2D(_HologramTex, fixed2(IN.texcoord.x, (slope*IN.texcoord.x+IN.texcoord.y)*0.5+ _Timer));

				//噪波幅度
			    float noise_size=_Rate*(0.005+slope*0.03+noise*0.005)*round(hologram.a-0.2)*3;
			    //噪波偏移
			    float noise_lerp=_Rate*(0.005+slope*0.03+noise*0.005)*round(hologram.a-0.2) ;

			    //噪波图
				half4 color = (tex2D(_MainTex, fixed2( noise_lerp+IN.texcoord.x*(1-noise_size),IN.texcoord.y)) + _TextureSampleAdd) * IN.color;

				//底图
				half4 color_b = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;

				//颜色混合
				color =  color+ _Rate* (hologram*hologram.a*color.a)*(0.1+slope*0.3+noise*0.3);
				color = color*(color.a)+color_b * (1-color.a);


				//color.a = random.r;

				color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
				
				#ifdef UNITY_UI_ALPHACLIP
				clip (color.a - 0.001);
				#endif

				return color;
			}


		ENDCG
		}
	}
}