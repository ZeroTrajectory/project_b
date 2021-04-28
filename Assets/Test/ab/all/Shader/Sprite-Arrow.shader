// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "DarkBoom/SpriteArrow"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)

        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255

        _ColorMask ("Color Mask", Float) = 15

        //_Ratio ("Ratio", Float) = 2
        _TargetWidth("Target Width", Float) = 200
        _Width("Width", Float) = 200
        _Height("Height", Float) = 100
        _CircleOffset1("Circle Offset 1", Float) = 100
        _BeginOffset ("Begin Offset", Float) = 20
        _EndOffset("End Offset", Float) = 40
        _CircleOffset2("Circle Offset 2", Float) = 100
        _Edge("Edge", Float) = 6
        //_OffsetX ("OffsetX", Float) = 0.1
        //_OffsetY ("OffsetY", Float) = 0.1

        _ArrowMinX("Arrow MinX", Float) = 3
        _ArrowMaxX("Arrow MaxX", Float) = 15
        _ArrowMinY("Arrow MinY", Float) = 5

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

        Cull Off
        Lighting Off
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            #pragma multi_compile __ UNITY_UI_CLIP_RECT
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
                //float scale : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            fixed4 _Color;
            fixed4 _TextureSampleAdd;
            float4 _ClipRect;
            float4 _MainTex_ST;
            float4 _MainTex_TexelSize;

            //float _Ratio;
            float _TargetWidth;
            float _Width;
            float _Height;
            float _CircleOffset1;
            float _BeginOffset;
            float _EndOffset;
            float _CircleOffset2;
            float _Edge;
            float _OffsetX;
            float _OffsetY;
            float _ArrowMinX;
            float _ArrowMaxX;
            float _ArrowMinY;

            v2f vert(appdata_t v)
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                OUT.worldPosition = v.vertex;
                OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);
                OUT.texcoord = v.texcoord;
                OUT.color = _Color;
                //OUT.scale = length(float3(unity_ObjectToWorld[0].y, unity_ObjectToWorld[1].y, unity_ObjectToWorld[2].y));
                return OUT;
            }

            fixed4 frag(v2f IN) : SV_Target
            {
                half4 color = IN.color;
                // ratio
                float ratio = _Height / _Width;

                // center1 & radius1
                float2 center1 = float2((_Width - _EndOffset + _BeginOffset) / _Width / 2.0f, -_CircleOffset1 / _TargetWidth);
                float2 beginPosBottom = float2(_BeginOffset / _Width, 0.0f);
                float radius1 = length(center1 - beginPosBottom);

                // center2 & radius2
                float2 beginPos = float2(0.0f, _BeginOffset / _Width * _Height / _Width);
                float2 endPos = float2(1.0f, _EndOffset / _Width * _Height / _Width);
                float2 midPos = (beginPos + endPos) / 2.0f;
                float2 outerDir = endPos - beginPos;
                float2 center2 = midPos + normalize(float2(outerDir.y, -outerDir.x)) * _CircleOffset2 / _TargetWidth;
                float radius2 = length(center2 - beginPos);

                // draw
                float edge = _Edge / _Width;
                float2 pos = float2(IN.texcoord.x, IN.texcoord.y * ratio);
                float a = smoothstep(radius1, radius1 + edge, distance(center1, pos)) * smoothstep(-radius2 - edge, -radius2, -distance(center2, pos)) 
                    * step(_ArrowMinX / _Width, IN.texcoord.x);
                if (IN.texcoord.x < _ArrowMaxX / _Width && IN.texcoord.y < _ArrowMinY / _Height)
                {
                    a = 0;
                }
                color.a *= (1.0f - IN.texcoord.x) * a;
                #ifdef UNITY_UI_ALPHACLIP
                clip (color.a - 0.001);                
                #endif
                return color;
            }
        ENDCG
        }
    }
}
