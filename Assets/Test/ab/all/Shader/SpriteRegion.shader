Shader "DarkBoom/SpriteRegion"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" { }
        _Color ("Tint", Color) = (1, 1, 1, 1)
        _Brightness ("亮度", range(-50, 50)) = 1
        _Saturation ("饱和度", range(-50, 50)) = 1
        _Contrast ("对比度", range(-50, 50)) = 1
        
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
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            #pragma multi_compile_instancing
            #pragma multi_compile _ PIXELSNAP_ON
            #pragma multi_compile _ ETC1_EXTERNAL_ALPHA
            #include "UnitySprites.cginc"
            
            half _Brightness;
            half _Saturation;
            half _Contrast;
            
            v2f vert(appdata_t IN)
            {
                v2f OUT;
                
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                
                OUT.vertex = UnityFlipSprite(IN.vertex, _Flip);
                OUT.vertex = UnityObjectToClipPos(OUT.vertex);
                OUT.texcoord = IN.texcoord;
                OUT.color = IN.color * _Color;
                
                #ifdef PIXELSNAP_ON
                    OUT.vertex = UnityPixelSnap(OUT.vertex);
                #endif
                
                return OUT;
            }
            
            fixed3 getluminanceColor(fixed3 basecolor)
            {
                float luminance = 0.2125 * basecolor.r + 0.7154 * basecolor.g + 0.0721 * basecolor.b;
                fixed3 luminanceColor = fixed3(luminance, luminance, luminance);
                return luminanceColor;
            }
            
            fixed4 frag(v2f IN): SV_Target
            {
                fixed4 color = SampleSpriteTexture(IN.texcoord);
                color.a = IN.color.a * color.g;     
               // clip(color.g - 0.1);
               // clip(color.g - 0.1);
                // c.rgb *= c.a;
                fixed4 basecolor = color;
                basecolor.rgb *= _Brightness;
                // float luminance = 0.2125 * basecolor.r + 0.7154 * basecolor.g + 0.0721 * basecolor.b;
                fixed3 luminanceColor = getluminanceColor(basecolor);
                basecolor.rgb = lerp(luminanceColor, basecolor, _Saturation);
                fixed3 avgColor = fixed3(0.5, 0.5, 0.5);
                basecolor.rgb = lerp(avgColor, basecolor, _Contrast);
                //return fixed4(IN.color.rgb,color.a*IN.color.a);
                //return fixed4(IN.color.rgb, IN.color.a);
                return basecolor;
            }
            ENDCG
            
        }
    }
}
