
Shader "fx_shader/Kn" {
    Properties {
        _TextureN ("TextureN", 2D) = "white" {}
        _LerpSlider ("LerpSlider", Range(0, 1)) = 0
        _Pos ("强度", Range(0, 1)) = 0.5
        _TextureMask ("Mask", 2D) = "gray" {}
        [MaterialToggle] _AorNOA ("是否使用A通道", Float ) = 0

    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
			"PreviewType"="Plane"
        }
        GrabPass{ }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Cull Off
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase 
            #pragma target 3.0
            uniform sampler2D _GrabTexture;
            uniform sampler2D _TextureN; uniform float4 _TextureN_ST;
            uniform float _LerpSlider;
            uniform float _Pos;
            uniform sampler2D _TextureMask; uniform float4 _TextureMask_ST;
            uniform fixed _AorNOA;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float3 tangentDir : TEXCOORD3;
                float3 bitangentDir : TEXCOORD4;
                float4 vertexColor : COLOR;
                float4 projPos : TEXCOORD5;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.tangentDir = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos( v.vertex );
                o.projPos = ComputeGrabScreenPos(o.pos);
                COMPUTE_EYEDEPTH(o.projPos.z);
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                i.normalDir = normalize(i.normalDir);
                i.normalDir *= faceSign;
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
                float2 sceneUVs = (i.projPos.xy / i.projPos.w);
                float4 sceneColor = tex2D(_GrabTexture, sceneUVs);
                float4 _TextureN_var = tex2D(_TextureN,TRANSFORM_TEX(i.uv0, _TextureN));
                float4 _TextureMask_var = tex2D(_TextureMask,TRANSFORM_TEX(i.uv0, _TextureMask));
                float  NQ = (_TextureMask_var.r-0.0);
                float3 emissive = tex2D( _GrabTexture, lerp((0.05*(_Pos - 0.5)*mul(tangentTransform, viewDirection).xy + sceneUVs.rg).rg,float2(_TextureN_var.r,_TextureN_var.g),(lerp(NQ, _TextureMask_var.a, _AorNOA )*_LerpSlider*i.vertexColor.a))).rgb;
                float3 finalColor = emissive;
                return fixed4(finalColor,NQ);
            }
            ENDCG
        }
    }
}
