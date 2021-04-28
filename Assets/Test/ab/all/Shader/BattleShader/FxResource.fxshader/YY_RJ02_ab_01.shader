// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:2,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:True,fgod:False,fgor:False,fgmd:0,fgcr:0,fgcg:0,fgcb:0,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:True,fnfb:True,fsmp:False;n:type:ShaderForge.SFN_Final,id:4795,x:32724,y:32693,varname:node_4795,prsc:2|emission-2393-OUT,alpha-5013-OUT;n:type:ShaderForge.SFN_Tex2d,id:6074,x:32183,y:32517,ptovrint:False,ptlb:tex,ptin:_tex,varname:_MainTex,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-5115-OUT;n:type:ShaderForge.SFN_Multiply,id:2393,x:32495,y:32793,varname:node_2393,prsc:2|A-6074-RGB,B-2053-RGB,C-797-RGB;n:type:ShaderForge.SFN_VertexColor,id:2053,x:32235,y:32772,varname:node_2053,prsc:2;n:type:ShaderForge.SFN_Color,id:797,x:32235,y:32930,ptovrint:True,ptlb:Color,ptin:_TintColor,varname:_TintColor,prsc:2,glob:False,taghide:False,taghdr:True,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;n:type:ShaderForge.SFN_Multiply,id:5013,x:32499,y:33024,varname:node_5013,prsc:2|A-6074-A,B-2053-A,C-8176-OUT,D-1961-OUT;n:type:ShaderForge.SFN_TexCoord,id:8172,x:31441,y:32263,varname:node_8172,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Time,id:6497,x:31022,y:32721,varname:node_6497,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:7581,x:31033,y:32637,ptovrint:False,ptlb:u,ptin:_u,varname:node_7581,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_ValueProperty,id:4490,x:31022,y:32946,ptovrint:False,ptlb:v,ptin:_v,varname:node_4490,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:3398,x:31333,y:32606,varname:node_3398,prsc:2|A-7581-OUT,B-6497-T;n:type:ShaderForge.SFN_Multiply,id:3634,x:31349,y:32892,varname:node_3634,prsc:2|A-6497-T,B-4490-OUT;n:type:ShaderForge.SFN_Append,id:9729,x:31616,y:32737,varname:node_9729,prsc:2|A-3398-OUT,B-3634-OUT;n:type:ShaderForge.SFN_Add,id:5115,x:31891,y:32554,varname:node_5115,prsc:2|A-8172-UVOUT,B-9729-OUT;n:type:ShaderForge.SFN_SwitchProperty,id:8176,x:32197,y:33255,ptovrint:False,ptlb:DBkg,ptin:_DBkg,varname:node_8176,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-4040-OUT,B-4400-OUT;n:type:ShaderForge.SFN_DepthBlend,id:4400,x:31989,y:33304,varname:node_4400,prsc:2|DIST-4619-OUT;n:type:ShaderForge.SFN_ValueProperty,id:4619,x:31788,y:33304,ptovrint:False,ptlb:DB,ptin:_DB,varname:node_4619,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Vector1,id:4040,x:32005,y:33193,varname:node_4040,prsc:2,v1:1;n:type:ShaderForge.SFN_Tex2d,id:2493,x:31441,y:33724,ptovrint:False,ptlb:rj_tex,ptin:_rj_tex,varname:node_2493,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Step,id:1113,x:31766,y:33597,varname:node_1113,prsc:2|A-741-U,B-2493-R;n:type:ShaderForge.SFN_TexCoord,id:741,x:31446,y:33415,varname:node_741,prsc:2,uv:1,uaff:True;n:type:ShaderForge.SFN_SwitchProperty,id:1961,x:32069,y:33606,ptovrint:False,ptlb:rjkg,ptin:_rjkg,varname:node_1961,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-2595-OUT,B-1113-OUT;n:type:ShaderForge.SFN_Vector1,id:2595,x:31788,y:33490,varname:node_2595,prsc:2,v1:1;proporder:797-6074-7581-4490-8176-4619-1961-2493;pass:END;sub:END;*/

Shader "fx_shader/YY_RJ02_ab_01" {
    Properties {
        [HDR]_TintColor ("Color", Color) = (0.5,0.5,0.5,1)
        _tex ("tex", 2D) = "white" {}
        _u ("u", Float ) = 0
        _v ("v", Float ) = 0
        [MaterialToggle] _DBkg ("DBkg", Float ) = 1
        _DB ("DB", Float ) = 0
        [MaterialToggle] _rjkg ("rjkg", Float ) = 1
        _rj_tex ("rj_tex", 2D) = "white" {}
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            uniform sampler2D _CameraDepthTexture;
            uniform sampler2D _tex; uniform float4 _tex_ST;
            uniform float4 _TintColor;
            uniform float _u;
            uniform float _v;
            uniform fixed _DBkg;
            uniform float _DB;
            uniform sampler2D _rj_tex; uniform float4 _rj_tex_ST;
            uniform fixed _rjkg;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 texcoord1 : TEXCOORD1;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 uv1 : TEXCOORD1;
                float4 vertexColor : COLOR;
                float4 projPos : TEXCOORD2;

            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.uv1 = v.texcoord1;
                o.vertexColor = v.vertexColor;
                o.pos = UnityObjectToClipPos( v.vertex );
                o.projPos = ComputeScreenPos (o.pos);
                COMPUTE_EYEDEPTH(o.projPos.z);
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                float sceneZ = max(0,LinearEyeDepth (UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)))) - _ProjectionParams.g);
                float partZ = max(0,i.projPos.z - _ProjectionParams.g);
////// Lighting:
////// Emissive:
                float4 node_6497 = _Time;
                float2 node_5115 = (i.uv0+float2((_u*node_6497.g),(node_6497.g*_v)));
                float4 _tex_var = tex2D(_tex,TRANSFORM_TEX(node_5115, _tex));
                float3 emissive = (_tex_var.rgb*i.vertexColor.rgb*_TintColor.rgb);
                float3 finalColor = emissive;
                float4 _rj_tex_var = tex2D(_rj_tex,TRANSFORM_TEX(i.uv0, _rj_tex));
                fixed4 finalRGBA = fixed4(finalColor,(_tex_var.a*i.vertexColor.a*lerp( 1.0, saturate((sceneZ-partZ)/_DB), _DBkg )*lerp( 1.0, step(i.uv1.r,_rj_tex_var.r), _rjkg )));
                return finalRGBA;
            }
            ENDCG
        }
    }
    CustomEditor "ShaderForgeMaterialInspector"
}
