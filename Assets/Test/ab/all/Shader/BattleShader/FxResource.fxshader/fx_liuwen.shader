
Shader "fx_shader/LiuWenAdd" {
    Properties {
        _Mask ("Mask", 2D) = "white" {}
        _Texture ("Texture", 2D) = "white" {}
        [HDR]_HDRColor ("HDR Color", Color) = (0.5,0.5,0.5,1)
        _X ("X", Range(-5, 5)) = 0
        _Y ("Y", Range(-5, 5)) = 0
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
			"Queue" = "Transparent"
            "RenderType"="Opaque"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha One
            Cull Off
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            uniform sampler2D _Mask; uniform float4 _Mask_ST;
            uniform sampler2D _Texture; uniform float4 _Texture_ST;
            uniform float4 _HDRColor;
            uniform float _X;
            uniform float _Y;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.pos = UnityObjectToClipPos( v.vertex );
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
////// Lighting:
                float4 _Mask_var = tex2D(_Mask,TRANSFORM_TEX(i.uv0, _Mask));
                float4 node_5159 = _Time;
                float node_8757 = 0.5;
                float2 node_865 = float2((i.uv0.r+(node_5159.g*_Y*node_8757)),(i.uv0.g+(node_5159.g*_X*node_8757)));
                float4 _Texture_var = tex2D(_Texture,TRANSFORM_TEX(node_865, _Texture));
                float3 finalColor = (_Mask_var.rgb*(_HDRColor.rgb*_Texture_var.rgb*i.vertexColor.rgb)*3.0);
                return fixed4(finalColor,(_Mask_var.a*i.vertexColor.a*_HDRColor.a));
            }
            ENDCG
        }
    }
}
