Shader "DarkBoom/Blur"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
        _BlurSize("_BlurSize", range(0, 300)) = 1
		_BlurRect("Rect", vector) = (0, 0, 1, 1)
		_GrayStrength("GrayStrength", range(0, 1)) = 0
	}

	SubShader
	{
		CGINCLUDE
#include "UnityCG.cginc"
		sampler2D _MainTex;
		half4 _MainTex_TexelSize;
		float _BlurSize;
		half4 _BlurRect;
		half _GrayStrength;
		half2 _TmpUV;
		fixed4 _TmpColor;

		struct appdata
		{
			float4 vertex:POSITION;
			float2 uv:TEXCOORD0;
		};

		struct v2f
		{
			float4 pos : SV_POSITION;
			half2 uv : TEXCOORD0;
		};
		//--------------blur--------------------------------------

		v2f vertBlurSimple(appdata v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv = v.uv;// TRANSFORM_TEX(v.uv, _MainTex);
			return o;
		}

		bool inRect(half2 uv)
		{
			return uv.x >= _BlurRect.x && uv.x <= _BlurRect.z && uv.y >= _BlurRect.y && uv.y <= _BlurRect.w;
		}
	
		fixed4 fragBlurHorizontal(v2f i) : SV_Target
		{
			fixed4 col;
			if(inRect(i.uv))
			{
				fixed _EdgeDamping = 50;
				col = 0.28 * tex2D(_MainTex,i.uv);

				_TmpUV = i.uv + half2(-0.01, 0) * _BlurSize * 0.6;
				_TmpColor = tex2D(_MainTex, _TmpUV);
				if(_TmpUV.x < 0)
					_TmpColor.a = _TmpUV.x * _EdgeDamping;
				col += 0.36 * _TmpColor;


				_TmpUV = i.uv + half2(0.01, 0) * _BlurSize * 0.6;
				_TmpColor = tex2D(_MainTex, _TmpUV);
				if(_TmpUV.x > 1)
					_TmpColor.a = (1 - _TmpUV.x) * _EdgeDamping;
				col += 0.36 * _TmpColor;

				/*
				_TmpUV = i.uv + half2(-0.01, 0) * _BlurSize * 2 * 0.6;
				_TmpColor = tex2D(_MainTex, _TmpUV);
				if(_TmpUV.x < 0)
					_TmpColor.a = _TmpUV.x * _EdgeDamping;
				col += 0.14 * _TmpColor;


				_TmpUV = i.uv + half2(0.01, 0) * _BlurSize * 2 * 0.6;
				_TmpColor = tex2D(_MainTex, _TmpUV);
				if(_TmpUV.x > 1)
					_TmpColor.a = (1 - _TmpUV.x) * _EdgeDamping;
				col += 0.14 * _TmpColor;
				**/
				
			}
			else
			{
				col = tex2D(_MainTex,i.uv);
			}
			
			return col;
		}

		fixed4 fragBlurVertical(v2f i) : SV_Target
		{
			fixed4 col;
			if(inRect(i.uv))
			{
				fixed _EdgeDamping = 50;
				col = 0.28 * tex2D(_MainTex,i.uv);

				_TmpUV = i.uv + half2(0, -0.01) * _BlurSize;
				_TmpColor = tex2D(_MainTex, _TmpUV);
				if(_TmpUV.y < 0)
					_TmpColor.a = _TmpUV.y * _EdgeDamping;
				col += 0.22 * _TmpColor;


				_TmpUV = i.uv + half2(0,  0.01) * _BlurSize;
				_TmpColor = tex2D(_MainTex, _TmpUV);
				if(_TmpUV.y > 1)
					_TmpColor.a = (1 - _TmpUV.y) * _EdgeDamping;
				col += 0.22 * _TmpColor;


				_TmpUV = i.uv + half2(0, -0.01) * _BlurSize * 2;
				_TmpColor = tex2D(_MainTex, _TmpUV);
				if(_TmpUV.y < 0)
					_TmpColor.a = _TmpUV.y * _EdgeDamping;
				col += 0.14 * _TmpColor;


				_TmpUV = i.uv + half2(0,  0.01) * _BlurSize * 2;
				_TmpColor = tex2D(_MainTex, _TmpUV);
				if(_TmpUV.y > 1)
					_TmpColor.a = (1 - _TmpUV.y) * _EdgeDamping;
				col += 0.14 * _TmpColor;
			}
			else
			{
				col = tex2D(_MainTex,i.uv);
			}
			return col;
		}

		fixed4 gray(v2f i) : SV_Target
		{
			fixed4 col = tex2D(_MainTex,i.uv);
			fixed3 grayCol = dot(col.rgb, fixed3(0.3, 0.59, 0.11));
			col.rgb = lerp(col.rgb, grayCol, _GrayStrength);
			return col;
		}

		ENDCG

		ZTest Always 
		Cull Off 
		Zwrite Off

		Pass 
		{
			NAME "blur_vertical"
			CGPROGRAM
#pragma vertex vertBlurSimple  
#pragma fragment fragBlurVertical
			ENDCG
		}

		Pass 
		{
			NAME "blur_horizontal "
			CGPROGRAM
#pragma vertex vertBlurSimple  
#pragma fragment fragBlurHorizontal
			ENDCG
		}

		Pass 
		{
			NAME "gray "
			CGPROGRAM
#pragma vertex vertBlurSimple  
#pragma fragment gray
			ENDCG
		}

	}
	Fallback Off
}