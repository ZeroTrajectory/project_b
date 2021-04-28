// Upgrade NOTE: upgraded instancing buffer 'Props' to new syntax.

// Toony Colors Pro+Mobile 2
// (c) 2014-2017 Jean Moreno

Shader "Toony Colors Pro 2/Examples/Water/Reflection_fsh"
{
	Properties
	{
		[TCP2HelpBox(Warning,Make sure that the Camera renders the depth texture for this material to work properly.You can use the script __TCP2_CameraDepth__ for this.)]
	[TCP2HeaderHelp(BASE, Base Properties)]
	//TOONY COLORS
	_HColor("Highlight Color", Color) = (0.6,0.6,0.6,1.0)
		_SColor("Shadow Color", Color) = (0.3,0.3,0.3,1.0)

		//DIFFUSE
		//_MainTex("Main Texture (RGB)", 2D) = "white" {}
		[TCP2Separator]

	//TOONY COLORS RAMP
	_RampThreshold("Ramp Threshold", Range(0,1)) = 0.5
		_RampSmooth("Ramp Smoothing", Range(0.001,1)) = 0.1
		[TCP2Separator]
	[TCP2HeaderHelp(WATER)]
	_Color("Water Color", Color) = (0.5,0.5,0.5,1.0)


		[Header(Waves Normal Map)]
	[TCP2HelpBox(Info,There are two normal maps blended.The tiling offsets affect each map uniformly.)]
	_BumpMap("Normal Map", 2D) = "bump" {}
	[PowerSlider(2.0)] _BumpScale("Normal Scale", Range(0.01,2)) = 1.0
		_BumpSpeed("Normal Speed", Vector) = (0.2,0.2,0.3,0.3)
		//_NormalDepthInfluence("Depth/Reflection Influence", Range(0,1)) = 0.5
		[TCP2Separator]
	[TCP2HeaderHelp(SPECULAR, Specular)]
	//SPECULAR
	_SpecColor("Specular Color", Color) = (0.5, 0.5, 0.5, 1)
		_Shininess("Roughness", Range(0.0,10)) = 0.1
		[TCP2Separator]
	[TCP2HeaderHelp(REFLECTION, Reflection)]
	//REFLECTION
	_ReflStrength("Reflection Strength", Range(0,1)) = 1
		[HideInInspector] _ReflectionTex("Planar Reflection RenderTexture", 2D) = "white" {}
	[TCP2Separator]
	[TCP2HeaderHelp(RIM, Rim)]
	//RIM LIGHT
	_RimColor("Rim Color", Color) = (0.8,0.8,0.8,0.6)
		_RimMin("Rim Min", Range(0,1)) = 0.5
		_RimMax("Rim Max", Range(0,1)) = 1.0
		[TCP2Separator]
	//Avoid compile error if the properties are ending with a drawer
	[HideInInspector] __dummy__("unused", Float) = 0
		_TimeFactor_1("TimeFactor 1",Float) = 0
		_TimeFactor_2("TimeFactor 2",Float) = 0
	}

		SubShader
	{
		Tags{ "Queue" = "Geometry" "RenderType" = "Opaque" }


		CGPROGRAM

#pragma surface surf ToonyColorsWater keepalpha vertex:vert nolightmap
#pragma target 3.0

		//================================================================
		// VARIABLES

		float _TimeFactor_1;
	float _TimeFactor_2;
	float4 _Color;
	/*sampler2D _MainTex;
	float4 _MainTex_ST;*/
	sampler2D _BumpMap;
	float4 _BumpMap_ST;
	float _BumpScale;
	float4 _BumpSpeed;
	//float _NormalDepthInfluence;


	float4 _RimColor;
	float _RimMin;
	float _RimMax;

	float _ReflStrength;
	sampler2D _ReflectionTex;

	struct Input
	{
		float2 texcoord;
		float2 bump_texcoord;
		float3 viewDir;
	};

	//================================================================
	// CUSTOM LIGHTING

	//Lighting-related variables
	float4 _HColor;
	float4 _SColor;
	float _RampThreshold;
	float _RampSmooth;
	float _Shininess;

	// Instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
	// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
	// #pragma instancing_options assumeuniformscaling
	UNITY_INSTANCING_BUFFER_START(Props)
		// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		//Custom SurfaceOutput
		struct SurfaceOutputWater
	{
		//float atten;
		float3 Albedo;
		float3 Normal;
		float3 Emission;
		float Specular;
		float Gloss;
		float Alpha;
	};

	inline float4 LightingToonyColorsWater(inout SurfaceOutputWater s, float3 viewDir, UnityGI gi)
	{
		float3 lightDir = gi.light.dir;
#if defined(UNITY_PASS_FORWARDBASE)
		float3 lightColor = _LightColor0.rgb;
		//float atten = s.atten;
#else
		float3 lightColor = gi.light.color.rgb;
		//float atten = 1;
#endif

		float4 c;
		c.a = s.Alpha;
		float3 h = normalize(lightDir + viewDir);
		float ndh = max(0, dot(s.Normal, h));
		float spec = pow(ndh, s.Specular*128.0) * s.Gloss * 2.0;
		//spec *= atten;
		c.rgb = lightColor.rgb * _SpecColor.rgb * spec;
#ifdef UNITY_LIGHT_FUNCTION_APPLY_INDIRECT
		c.rgb += s.Albedo * gi.indirect.diffuse;
#endif
		return c;
	}

	void LightingToonyColorsWater_GI(inout SurfaceOutputWater s, UnityGIInput data, inout UnityGI gi)
	{
		gi = UnityGlobalIllumination(data, 1.0, s.Normal);

		//gi.light.color = _LightColor0.rgb;	//remove attenuation
		//s.atten = data.atten;	//transfer attenuation to lighting function
	}

	//================================================================
	// VERTEX FUNCTION


	struct appdata_tcp2
	{
		float4 vertex : POSITION;
		float3 normal : NORMAL;
		//float4 texcoord : TEXCOORD0;
		//float4 texcoord1 : TEXCOORD1;
		//float4 texcoord2 : TEXCOORD2;
		float4 tangent : TANGENT;
#if UNITY_VERSION >= 550
		UNITY_VERTEX_INPUT_INSTANCE_ID
#endif
	};

#define TIME ( _Time.y * _TimeFactor_1 + _TimeFactor_2)

	void vert(inout appdata_tcp2 v, out Input o)
	{
		UNITY_INITIALIZE_OUTPUT(Input, o);
		//Main texture UVs
		float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
		o.bump_texcoord = (worldPos.xz + TIME.xx * _BumpSpeed.xy) * 0.1;
	}

	//================================================================
	// SURFACE FUNCTION

	void surf(Input IN, inout SurfaceOutputWater o)
	{
		float3 normal = UnpackScaleNormal(tex2D(_BumpMap, IN.bump_texcoord.xy * _BumpMap_ST.xx), _BumpScale).rgb;
		float3 normal2 = UnpackScaleNormal(tex2D(_BumpMap, IN.bump_texcoord.xy * _BumpMap_ST.yy + TIME.xx * _BumpSpeed.zw  * 0.1), _BumpScale).rgb;
		normal = (normal + normal2) / 2;
		o.Normal = normal;
		float ndv = dot(IN.viewDir, normal);
		float sceneZ = 0;
		o.Albedo = _Color.rgb;
		o.Gloss = 1;
		o.Specular = _Shininess;
		float smoothRim = smoothstep(_RimMax, _RimMin, 1 - Pow4(1 - ndv));
		float3 rim = _RimColor.rgb * _RimColor.a * smoothRim;
		o.Emission += rim.rgb;
	}

	ENDCG
	}

		Fallback "Diffuse"
		CustomEditor "TCP2_MaterialInspector_SG"
}
