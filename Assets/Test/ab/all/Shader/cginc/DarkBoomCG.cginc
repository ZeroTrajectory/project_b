#ifndef DARKBOOM_CG_INCLUDE
#define DARKBOOM_CG_INCLUDE

#include "UnityCG.cginc"
#include "UnityUI.cginc"



#if defined(ENALE_UI_CORNER_CLIP)
    float _clipX;
    float _clipY;
    float _startX;
    float _startY;
#endif

#if defined(ENALE_UI_FADE_ALPHA)
   float _LeftFade;
   float _RightFade;
   float _TopFade;
   float _BottomFade;
#endif



inline float4 UnityHalfTexelOffsetVertex(float4 vertex)
{
    #ifdef UNITY_HALF_TEXEL_OFFSET
    vertex.xy += (_ScreenParams.zw-1.0)*float2(-1,1);
    #endif
    return vertex;
}



inline half4 UIFadeAlpha(in float2 worldPosition, in half4 color, in float4 _ClipRect)
{
    #if defined(ENALE_UI_FADE_ALPHA)
    #ifdef UNITY_UI_CLIP_RECT
	half w = (_ClipRect.z - _ClipRect.x) * 0.5;
	half h = (_ClipRect.w - _ClipRect.y) * 0.5;
	half left = (worldPosition.x - _ClipRect.x) / w;
	half right = (_ClipRect.z - worldPosition.x) / w;
	half bottom = (worldPosition.y - _ClipRect.y) / h;
	half top = (_ClipRect.w - worldPosition.y) / h;
	color.a *= min(
		min(clamp(left / _LeftFade, 0, 1), clamp(right / _RightFade, 0, 1)), 
		min(clamp(top / _TopFade, 0, 1), clamp(bottom / _BottomFade, 0, 1)));
    #endif
    #endif
    
    return color;
}

inline half4 UnityUIClipRectFrag(in float2 worldPosition,in  half4 color, in float4 _ClipRect)
{
   
    #ifdef UNITY_UI_CLIP_RECT
    color.a *= UnityGet2DClipping(worldPosition.xy, _ClipRect);
    #endif
    #ifdef UNITY_UI_ALPHACLIP
    clip (color.a - 0.001);
    #endif
    return UIFadeAlpha(worldPosition,color,_ClipRect);
}

inline half4 UICornerClipFrag(half2 texcoord,half4 color)
{
    #if defined(ENALE_UI_CORNER_CLIP)
    float alpha = 1;
	float value = (1-_clipX)*(texcoord.y-1)-(_clipY-1)*(texcoord.x-_clipX);
    if(value>=0)
        alpha = 0;
    else if(texcoord.x<_startX||texcoord.y < _startY || texcoord.x > (1-_startX) || texcoord.y > (1-_startY))
        alpha = 0;
	color.a *= alpha;
	
	#endif
	
	return color;
}

#endif