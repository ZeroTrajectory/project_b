
Shader "DarkBoom/SpriteLineTiling"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" { }
        _Color ("Tint", Color) = (1, 1, 1, 1)
        _RepeatX ("RepeatX", float) = 1
        _RepeatY ("RepeatY", float) = 1
        
        [MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
        [HideInInspector] _RendererColor ("RendererColor", Color) = (1, 1, 1, 1)
        [HideInInspector] _Flip ("Flip", Vector) = (1, 1, 1, 1)
        [PerRendererData] _AlphaTex ("External Alpha", 2D) = "white" { }
        [PerRendererData] _EnableExternalAlpha ("Enable External Alpha", Float) = 0
    }
    
    SubShader
    {
        Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "PreviewType" = "Plane" "CanUseSpriteAtlas" = "True" }
        
        Cull Off
        Lighting Off
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
        
        Pass
        {
            CGPROGRAM
            
            #pragma vertex SpriteVert
            #pragma fragment frag
            #pragma target 2.0
            #pragma multi_compile_instancing
            #pragma multi_compile _ PIXELSNAP_ON
            #pragma multi_compile _ ETC1_EXTERNAL_ALPHA
            #include "UnitySprites.cginc"
            
            half _RepeatX;
            half _RepeatY;
            
            fixed4 TileSpriteTexture(float2 uv)
            {
                uv.x = (uv.x - floor(uv.x / (1 / _RepeatX)) * (1 / _RepeatX)) * _RepeatX;
				uv.y = (uv.y - floor(uv.y / (1 / _RepeatY)) * (1 / _RepeatY)) * _RepeatY;
                fixed4 color = tex2D(_MainTex, uv);
                return color;
            }

            fixed4 frag(v2f IN): SV_Target
            {
                fixed4 color = TileSpriteTexture(IN.texcoord);
                IN.color.a = color.r;
                return IN.color;
            }
            ENDCG
            
        }
    }
}
