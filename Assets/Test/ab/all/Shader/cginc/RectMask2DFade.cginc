#ifndef RECT_MASK_FADE_INCLUDE
#define RECT_MASK_FADE_INCLUDE

#include "UICommon.cginc"

half _LeftFade;
half _RightFade;
half _TopFade;
half _BottomFade;

float _IsUseClipRectFade;
float4 _ClipRectFade;

v2f vert(appdata_t IN)
{
    v2f OUT;
    OUT.worldPosition = IN.vertex;
    OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);

    OUT.texcoord = IN.texcoord;
    
    #ifdef UNITY_HALF_TEXEL_OFFSET
    OUT.vertex.xy += (_ScreenParams.zw-1.0)*float2(-1,1);
    #endif
    
    OUT.color = IN.color * _Color;
    return OUT;
}

half4 calculateFadeRectMask(v2f IN, half4 color)
{
    #ifdef UNITY_UI_CLIP_RECT

    if (_IsUseClipRectFade == 0)
    {

        half w = (_ClipRect.z - _ClipRect.x) * 0.5;
        half h = (_ClipRect.w - _ClipRect.y) * 0.5;

        half left = (IN.worldPosition.x - _ClipRect.x) / w;
        half right = (_ClipRect.z - IN.worldPosition.x) / w;

        half bottom = (IN.worldPosition.y - _ClipRect.y) / h;
        half top = (_ClipRect.w - IN.worldPosition.y) / h;

        color.a *= min(
            min(clamp(left / _LeftFade, 0, 1), clamp(right / _RightFade, 0, 1)),
            min(clamp(top / _TopFade, 0, 1), clamp(bottom / _BottomFade, 0, 1)));

    }
    else
    {
        half w = (_ClipRectFade.z - _ClipRectFade.x) * 0.5;
        half h = (_ClipRectFade.w - _ClipRectFade.y) * 0.5;

        half left = (IN.worldPosition.x - _ClipRectFade.x) / w;
        half right = (_ClipRectFade.z - IN.worldPosition.x) / w;

        half bottom = (IN.worldPosition.y - _ClipRectFade.y) / h;
        half top = (_ClipRectFade.w - IN.worldPosition.y) / h;

        color.a *= min(
            min(clamp(left / _LeftFade, 0, 1), clamp(right / _RightFade, 0, 1)),
            min(clamp(top / _TopFade, 0, 1), clamp(bottom / _BottomFade, 0, 1)));

    }
    #endif
    return color;
}

#endif