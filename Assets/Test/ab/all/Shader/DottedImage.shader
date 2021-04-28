Shader "Custom/DottedImage"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_EffectSpeed ("EffectSpeed", Float) = 0.5	//动画速度，正负控制方向
		_TilingX ("TilingX", Float) = 1				//水平个数，建议和transform的scalex一致
		_Gap ("Gap", Range(0,10)) = 0.5				//虚线断开处长度，相对于实线比例

		_StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255
 
        _ColorMask ("Color Mask", Float) = 15
	}
	SubShader
	{
		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
			"PreviewType" = "Plane"
			"CanUseSpriteAtlas" = "True"
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
		ZTest[unity_GUIZTestMode]
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
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};
 
			struct v2f
			{
				float4 pos : POSITION;
				fixed4 color : COLOR;
				float2 uv : TEXCOORD0;
			};
 
			sampler2D _MainTex;
			float4 _MainTex_ST; 
			float _EffectSpeed;
			float _TilingX;
			float _Gap;

			v2f vert (appdata IN)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(IN.vertex);
				float2 uv = TRANSFORM_TEX(IN.texcoord, _MainTex);
				o.uv = uv + float2(uv.x, 0.0)*(_TilingX - 1) + (float2(1.0, 0.0) * _Time.y * _EffectSpeed); 
				o.color = IN.color;
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				float modx = fmod(abs(i.uv.x),1 + _Gap);
				float edge = step(modx,1);
				fixed4 col = tex2D(_MainTex, float2(modx, i.uv.y)) * edge;
				return col * i.color;
			}
			ENDCG
		}
	}
}
