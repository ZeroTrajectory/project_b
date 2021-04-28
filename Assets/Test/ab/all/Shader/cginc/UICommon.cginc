#ifndef UI_COMMON_INCLUDE
#define UI_COMMON_INCLUDE

struct appdata_t
{
    float4 vertex   : POSITION;
    float4 color    : COLOR;
    float2 texcoord : TEXCOORD0;
};

struct v2f
{
    float4 vertex   : SV_POSITION;
    half4 color    : COLOR;
    half2 texcoord  : TEXCOORD0;
    float4 worldPosition : TEXCOORD1;
};

half4 _Color;
half4 _TextureSampleAdd;
float4 _ClipRect;
sampler2D _MainTex;
float4 _MainTex_ST;

#endif