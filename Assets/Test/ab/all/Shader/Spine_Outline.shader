// This is a premultiply-alpha adaptation of the built-in Unity shader "UI/Default" in Unity 5.6.2 to allow Unity UI stencil masking.

Shader "Spine/Spine_withOutline"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
        _EdgeColor("Edge Color",Color) = (0,0,0,1)
		_EdgeAlphaThreshold("EdgeRange",float) = 0.1
		_EdgeDampRate("EdgeRate",float) = 1
		[HideInInspector]_OriginAlphaThreshold("OriginAlphaThreshold",float) =1
		[HideInInspector]_StencilComp ("Stencil Comparison", Float) = 8
		[HideInInspector]_Stencil ("Stencil ID", Float) = 0
		[HideInInspector]_StencilOp ("Stencil Operation", Float) = 0
		[HideInInspector]_StencilWriteMask ("Stencil Write Mask", Float) = 255
		[HideInInspector]_StencilReadMask ("Stencil Read Mask", Float) = 255

		[HideInInspector]_ColorMask ("Color Mask", Float) = 15

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
		Fog { Mode Off }
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask [_ColorMask]

		Pass
		{
			CGPROGRAM
			#pragma vertex outlineVert
			#pragma fragment outlineFrag
			#pragma target 2.0
			#include "UnityCG.cginc"
            fixed4 _EdgeColor;
			float _EdgeAlphaThreshold;
			float _EdgeDampRate;
			float _OriginAlphaThreshold;
			sampler2D _MainTex;
			float4 _MainTex_TexelSize;

			struct appdata{
				float4 vertex   : POSITION;
				float2 uv  : TEXCOORD0;
			};
			struct v2f
            {
                float4 vertex : SV_POSITION;
                half2 uv[9] : TEXCOORD0;
            };

			v2f outlineVert (appdata v)
            {
                v2f o;
                
                o.vertex = UnityObjectToClipPos(v.vertex);
				
                o.uv[0] = v.uv + _MainTex_TexelSize.xy * half2(-1, -1);
                o.uv[1] = v.uv + _MainTex_TexelSize.xy * half2(0, -1);
                o.uv[2] = v.uv + _MainTex_TexelSize.xy * half2(1, -1);
                o.uv[3] = v.uv + _MainTex_TexelSize.xy * half2(-1, 0);
                o.uv[4] = v.uv + _MainTex_TexelSize.xy * half2(0, 0);
                o.uv[5] = v.uv + _MainTex_TexelSize.xy * half2(1, 0);
                o.uv[6] = v.uv + _MainTex_TexelSize.xy * half2(-1, 1);
                o.uv[7] = v.uv + _MainTex_TexelSize.xy * half2(0, 1);
                o.uv[8] = v.uv + _MainTex_TexelSize.xy * half2(1, 1);


                return o;
            }
			half CalculateAlphaSumAround(v2f i)
			{
				float alphaSum = 0;
				for(int j=0;j<9;j++)
				{
					alphaSum+=tex2D(_MainTex,i.uv[j]).a;
				}
				return alphaSum;
			}


			fixed4 outlineFrag(v2f i):SV_Target
			{
				half alphaSum = CalculateAlphaSumAround(i);//累加alpha
				float isNeedShow = alphaSum >_EdgeAlphaThreshold;//阈值判断边缘
				float damp = saturate((alphaSum-_EdgeAlphaThreshold)*_EdgeDampRate);
				fixed4 origin =tex2D(_MainTex,i.uv[4]);//本色
				float isOrigin = origin.a >_OriginAlphaThreshold;
				fixed3 finalColor = lerp(_EdgeColor.rgb, origin.rgb, isOrigin);
				return fixed4(finalColor.rgb,isNeedShow*damp);
			}
			ENDCG
		}




		Pass
		{
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0

			#include "UnityCG.cginc"
			#include "UnityUI.cginc"

			#pragma multi_compile __ UNITY_UI_ALPHACLIP

			struct VertexInput {
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput {
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				half2 texcoord  : TEXCOORD0;
				float4 worldPosition : TEXCOORD1;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			fixed4 _Color;
			fixed4 _TextureSampleAdd;
			float4 _ClipRect;

			VertexOutput vert (VertexInput IN) {
				VertexOutput OUT;

				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);

				OUT.worldPosition = IN.vertex;
				OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);
				OUT.texcoord = IN.texcoord;

				#ifdef UNITY_HALF_TEXEL_OFFSET
				OUT.vertex.xy += (_ScreenParams.zw-1.0) * float2(-1,1);
				#endif

				OUT.color = IN.color * float4(_Color.rgb * _Color.a, _Color.a); // Combine a PMA version of _Color with vertexColor.
				return OUT;
			}

			sampler2D _MainTex;

			fixed4 frag (VertexOutput IN) : SV_Target
			{
				half4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;

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