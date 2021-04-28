Shader "Custom/GradualMask"
{
   Properties
	{
		 [PerRendererData]_MainTex ("Base (RGB)", 2D) = "black" {}

		_StencilComp("Stencil Comparison", Float) = 8
		_Stencil("Stencil ID", Float) = 0
		_StencilOp("Stencil Operation", Float) = 0
		_StencilWriteMask("Stencil Write Mask", Float) = 255
		_StencilReadMask("Stencil Read Mask", Float) = 255
		_ColorMask("Color Mask", Float) = 15
		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip("Use Alpha Clip", Float) = 0


		_AlphaTex ("Alpha (A)", 2D) = "black" {}
		_TopAlpha ("Top Alpha", Range (0, 1)) = 1
		_BottomAlpha ("Bottom Alpha", Range (0, 1)) = 0
		_StartPos ("Alpha Start Y", Range (0, 1)) = 1
		_Exp("Exponent", Float) = 2
	}
	
	SubShader
	{
		LOD 200

		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}
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
			Cull Off
			Lighting Off
			ZWrite Off
			Fog { Mode Off }
			Offset -1, -1
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag			
			#include "UnityCG.cginc"
			#include "UnityUI.cginc"
			#pragma multi_compile __ UNITY_UI_CLIP_RECT
			#pragma multi_compile __ UNITY_UI_ALPHACLIP
			
			float4 _ClipRect;
			sampler2D _MainTex;
			sampler2D _AlphaTex;
			float4 _MainTex_ST;
			half _TopAlpha;
			half _BottomAlpha;
			half _StartPos;
			half _Exp;
			
			struct appdata_t
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				fixed4 color : COLOR;
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				half2 texcoord : TEXCOORD0;
				float4 worldPosition : TEXCOORD1;
				fixed4 color : COLOR;
			};
	
			v2f o;

			v2f vert (appdata_t v)
			{
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = v.texcoord;
				o.worldPosition = v.vertex;
				o.color = v.color;
				return o;
			}
				
			fixed4 frag (v2f IN) : COLOR
			{
				//IN.color.a = IN.texcoord.y * IN.texcoord.y * IN.texcoord.y;
				/*if (IN.texcoord.y < _StartPos)
				{
					//IN.color.a = pow(lerp(_BottomAlpha, _TopAlpha, IN.texcoord.y), _Exp);
					half a = (_TopAlpha - _BottomAlpha) / _StartPos * IN.texcoord.y + _BottomAlpha;
					IN.color.a = pow(a, _Exp);
				}*/
				float cmp = step(IN.texcoord.y, _StartPos);
				float aflactor = lerp(1, pow((_TopAlpha - _BottomAlpha) / _StartPos * IN.texcoord.y + _BottomAlpha, _Exp), cmp);
				IN.color.a *= aflactor;
                
				fixed4 col = tex2D(_MainTex, IN.texcoord) * IN.color;
				fixed4 alpha_col = tex2D(_AlphaTex, IN.texcoord);
				col.a *=  alpha_col.a;

#ifdef UNITY_UI_CLIP_RECT
				col.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
#endif

#ifdef UNITY_UI_ALPHACLIP
				clip(col.a - 0.001);
#endif

				return col;
			}
			ENDCG
		}
	}
	
	SubShader
	{
		LOD 100

		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}
		
		Pass
		{
			Cull Off
			Lighting Off
			ZWrite Off
			Fog { Mode Off }
			Offset -1, -1
			ColorMask RGB
			Blend SrcAlpha OneMinusSrcAlpha
			ColorMaterial AmbientAndDiffuse

			SetTexture [_AlphaTex]
			{
				Combine Texture
			}
			SetTexture[_MainTex]
			{
				Combine Texture, previous
			}
		}
	}
}
