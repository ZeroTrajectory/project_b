#ifndef DEEP_SEA_MASK_INCLUDE
#define DEEP_SEA_MASK_INCLUDE

#include "UICommon.cginc"

sampler2D _MaskTex1;
sampler2D _MaskTex2;
float _MainAlpha;
float _MaskType;
float _MaskChannel;
bool _AddColorMode;

sampler2D _BG_Tex1;
float4 _BG_Tex1_Offset;
sampler2D _BG_Tex2;
float4 _BG_Tex2_Offset;
sampler2D _FG_Tex1;
float4 _FG_Tex1_Offset;
sampler2D _FG_Tex2;
float4 _FG_Tex2_Offset;
float4 _MainTex_Offset;
float4 _Mask_Offset;

half4 blend_color(half4 c1, half4 c2)
{
    half4 result = half4(0, 0, 0, max(c1.a, c2.a));
    half totalAlpha = clamp(c1.a + c2.a,0.0001,1);
    result.rgb = lerp(c1.rgb,c2.rgb,c2.a/totalAlpha);
    return result;
}

half4 blend_color2(half4 c1, half4 c2)
{
    half4 result = half4(0, 0, 0, max(c1.a, c2.a));
    result.rgb = c1.rgb * (1 - c2.a) + c2.rgb * c2.a;
    return result;
}

float clipOutAlpha(float2 uv)
{
    float alpha = 1;
    alpha *= step(0, uv.x);
    alpha *= step(uv.x, 1);
    alpha *= step(0, uv.y);
    alpha *= step(uv.y, 1);
    return alpha;
}

float2 calUVOffset(float2 uv, float4 offset)
{
    return float2((uv.x - offset.x) / (offset.z - offset.x),(uv.y - offset.y) /(offset.w - offset.y));
}

half4 calOffsetTex(sampler2D addTex, float2 uv, float4 offset)
{
    uv = calUVOffset(uv, offset);
    half4 color = tex2D(addTex, uv);
    color *= clipOutAlpha(uv);
    return color;
}

v2f vert_deepSea(appdata_t v)
{
    v2f OUT;
    OUT.worldPosition = v.vertex;
    OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);

    OUT.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
    OUT.color = v.color * _Color;
    return OUT;
}

half4 calculateDeepSeaMaskColor(v2f IN)
{
    half4 color = (calOffsetTex(_MainTex, IN.texcoord, _MainTex_Offset) + _TextureSampleAdd);
    color.a = clamp(color.a * _MainAlpha , 0, 1);
    float4 maskColor;
    float2 maskTexcoord = calUVOffset(IN.texcoord, _Mask_Offset);
    float maskAlpha = 1; 
    if(_MaskType == 1)
    {
        maskColor = tex2D(_MaskTex1, maskTexcoord);
    }else{	
        maskColor = tex2D(_MaskTex2, maskTexcoord);
    }		
    maskAlpha = lerp(maskAlpha, maskColor.r, _MaskChannel == 1);
    maskAlpha = lerp(maskAlpha, maskColor.g, _MaskChannel == 2);
    maskAlpha = lerp(maskAlpha, maskColor.b, _MaskChannel == 3);
    maskAlpha = lerp(maskAlpha, maskColor.a, _MaskChannel == 4);

    #ifdef _ENABLE_OUTCLIP
        maskAlpha *= clipOutAlpha(maskTexcoord);
    #endif

    #ifdef _ADDCOLORMODE_ON
        color.rgb += IN.color.rgb * IN.color.a;
    #endif

    half4 addColor = calOffsetTex(_BG_Tex1, IN.texcoord, _BG_Tex1_Offset);
    addColor = blend_color(addColor,calOffsetTex(_BG_Tex2, IN.texcoord, _BG_Tex2_Offset));
    addColor = blend_color(addColor,color);
    addColor = blend_color(addColor,calOffsetTex(_FG_Tex1, IN.texcoord, _FG_Tex1_Offset));
    addColor = blend_color(addColor,calOffsetTex(_FG_Tex2, IN.texcoord, _FG_Tex2_Offset));
    color = addColor;

    color.a *= maskAlpha;
    
    #ifndef _ADDCOLORMODE_ON
        color *= IN.color;
    #endif
    return color;
}

#endif

