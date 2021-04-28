Shader "TestShader/UIFlowLight" {  
    Properties {  
        _FlowTex("Light Texture(A)",2D)="black"{}  
        _MaskTex("Mask Texture(A)",2D)="white"{}  
        _uvAddSpeed("",float)=2  
    }  
    SubShader {  
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }  
        LOD 200  
        Blend SrcAlpha OneMinusSrcAlpha  
        CGPROGRAM  
        #pragma surface surf Lambert  
  
        sampler2D _FlowTex;  
        sampler2D _MaskTex;  
        float _uvAddSpeed;  
  
        struct Input {  
            float2 uv_MaskTex;  
        };  
  
        void surf (Input IN, inout SurfaceOutput o) {  
            float2 uv=IN.uv_MaskTex;  
            uv.x /= 2;  
            uv.x -= _Time.y * _uvAddSpeed;  
            float flow = tex2D(_FlowTex, uv).a;  
            float mask = tex2D(_MaskTex, IN.uv_MaskTex).a;  
  
            o.Emission= float3(flow,flow,flow)*mask;  
            o.Alpha = flow * mask;  
        }  
        ENDCG  
    }   
} 
