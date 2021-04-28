// Upgrade NOTE: replaced 'defined FOG_COMBINED_WITH_WORLD_POS' with 'defined (FOG_COMBINED_WITH_WORLD_POS)'

// Upgrade NOTE: upgraded instancing buffer 'Props' to new syntax.

// Toony Colors Pro+Mobile 2
// (c) 2014-2017 Jean Moreno

Shader "Toony Colors Pro 2/Examples/Water/Reflection_TA"
{
	Properties
	{
		[TCP2HelpBox(Warning,Make sure that the Camera renders the depth texture for this material to work properly.    You can use the script __TCP2_CameraDepth__ for this.)]
	[TCP2HeaderHelp(BASE, Base Properties)]
		//TOONY COLORS
		_HColor ("Highlight Color", Color) = (0.6,0.6,0.6,1.0)
		_SColor ("Shadow Color", Color) = (0.3,0.3,0.3,1.0)

		//DIFFUSE
		_MainTex ("Main Texture (RGB)", 2D) = "white" {}
	[TCP2Separator]

		//TOONY COLORS RAMP
		_RampThreshold ("Ramp Threshold", Range(0,1)) = 0.5
		_RampSmooth ("Ramp Smoothing", Range(0.001,1)) = 0.1
	[TCP2Separator]
	[TCP2HeaderHelp(WATER)]
		_Color ("Water Color", Color) = (0.5,0.5,0.5,1.0)

		[Header(Foam)]
		_FoamSpread ("Foam Spread", Range(0.01,5)) = 2
		_FoamStrength ("Foam Strength", Range(0.01,1)) = 0.8
		_FoamColor ("Foam Color (RGB) Opacity (A)", Color) = (0.9,0.9,0.9,1.0)
		[NoScaleOffset]
		_FoamTex ("Foam (RGB)", 2D) = "white" {}
		_FoamSmooth ("Foam Smoothness", Range(0,0.5)) = 0.02
		_FoamSpeed ("Foam Speed", Vector) = (2,2,2,2)

		[Header(Waves Normal Map)]
		[TCP2HelpBox(Info,There are two normal maps blended. The tiling offsets affect each map uniformly.)]
		_BumpMap ("Normal Map", 2D) = "bump" {}
		[PowerSlider(2.0)] _BumpScale ("Normal Scale", Range(0.01,2)) = 1.0
		_BumpSpeed ("Normal Speed", Vector) = (0.2,0.2,0.3,0.3)
		_NormalDepthInfluence ("Depth/Reflection Influence", Range(0,1)) = 0.5
	[TCP2Separator]
	[TCP2HeaderHelp(SPECULAR, Specular)]
		//SPECULAR
		_SpecColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 1)
		_Shininess ("Roughness", Range(0.0,10)) = 0.1
	[TCP2Separator]
	[TCP2HeaderHelp(REFLECTION, Reflection)]
		//REFLECTION
		_ReflStrength ("Reflection Strength", Range(0,1)) = 1
		[HideInInspector] _ReflectionTex ("Planar Reflection RenderTexture", 2D) = "white" {}
	[TCP2Separator]
	[TCP2HeaderHelp(RIM, Rim)]
		//RIM LIGHT
		_RimColor ("Rim Color", Color) = (0.8,0.8,0.8,0.6)
		_RimMin ("Rim Min", Range(0,1)) = 0.5
		_RimMax ("Rim Max", Range(0,1)) = 1.0
	[TCP2Separator]
		//Avoid compile error if the properties are ending with a drawer
		[HideInInspector] __dummy__ ("unused", Float) = 0

        _LightDir ("LightDir", Vector) = (0.2,0.2,0.3,0.3)
        _LightColor("LightColor", Color) = (0.8,0.8,0.8,0.6)
	}

	SubShader
	{
		Tags {"Queue"="Geometry" "RenderType"="Opaque"}
	// ------------------------------------------------------------
	// Surface shader code generated out of a CGPROGRAM block:
	

	// ---- forward rendering base pass:
	Pass {
		Name "FORWARD"
		Tags { "LightMode" = "ForwardBase" }

CGPROGRAM
// compile directives
#pragma vertex vert_surf
#pragma fragment frag_surf
#pragma target 3.0
#pragma multi_compile_instancing
#pragma multi_compile_fog
#pragma multi_compile_fwdbase noshadowmask nodynlightmap nolightmap
#include "HLSLSupport.cginc"
#define UNITY_INSTANCED_LOD_FADE
#define UNITY_INSTANCED_SH
#define UNITY_INSTANCED_LIGHTMAPSTS
#include "UnityShaderVariables.cginc"
#include "UnityShaderUtilities.cginc"
#if !defined(INSTANCING_ON)
#include "UnityCG.cginc"
//Shader does not support lightmap thus we always want to fallback to SH.
#undef UNITY_SHOULD_SAMPLE_SH
#define UNITY_SHOULD_SAMPLE_SH (!defined(UNITY_PASS_FORWARDADD) && !defined(UNITY_PASS_PREPASSBASE) && !defined(UNITY_PASS_SHADOWCASTER) && !defined(UNITY_PASS_META))
#include "Lighting.cginc"
#include "AutoLight.cginc"

#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
#define WorldNormalVector(data,normal) fixed3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))

// Original surface shader snippet:
#line 66 ""
#ifdef DUMMY_PREPROCESSOR_TO_WORK_AROUND_HLSL_COMPILER_LINE_HANDLING
#endif
/* UNITY: Original start of shader */

		//#pragma surface surf ToonyColorsWater keepalpha vertex:vert nolightmap
		//#pragma target 3.0

		//================================================================
		// VARIABLES

		fixed4 _Color;
		sampler2D _MainTex;
		float4 _MainTex_ST;
		sampler2D _BumpMap;
		float4 _BumpMap_ST;
		half _BumpScale;
		half4 _BumpSpeed;
		half _NormalDepthInfluence;
		sampler2D_float _CameraDepthTexture;
		half4 _FoamSpeed;
		half _FoamSpread;
		half _FoamStrength;
		sampler2D _FoamTex;
		fixed4 _FoamColor;
		half _FoamSmooth;

		fixed4 _RimColor;
		fixed _RimMin;
		fixed _RimMax;

		half _ReflStrength;
		sampler2D _ReflectionTex;

        float4 _LightDir;
        fixed4 _LightColor;

		struct Input
		{
			half2 texcoord;
			half2 bump_texcoord;
			half3 viewDir;
			float4 sPos;
		};

		//================================================================
		// CUSTOM LIGHTING

		//Lighting-related variables
		half4 _HColor;
		half4 _SColor;
		half _RampThreshold;
		half _RampSmooth;
		fixed _Shininess;

		// Instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// //#pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		//Custom SurfaceOutput
		struct SurfaceOutputWater
		{
			half atten;
			fixed3 Albedo;
			fixed3 Normal;
			fixed3 Emission;
			half Specular;
			fixed Gloss;
			fixed Alpha;
		};

		// inline half4 LightingToonyColorsWater (inout SurfaceOutputWater s, half3 viewDir, UnityGI gi)
        inline half4 LightingToonyColorsWater (inout SurfaceOutputWater s, half3 viewDir)
		{
            //--渲染组最光阴：替换传统全局光计算，光的方向和颜色改为面板输入
			// half3 lightDir = gi.light.dir;
            // #if defined(UNITY_PASS_FORWARDBASE)
            // 	half3 lightColor = _LightColor0.rgb;
            // 	half atten = s.atten;
            // #else
            // 	half3 lightColor = gi.light.color.rgb;
            // 	half atten = 1;
            // #endif

            half3 lightDir = normalize(_LightDir.xyz);
            half3 lightColor = _LightColor;
            half atten =1;

			s.Normal = normalize(s.Normal);			
			fixed ndl = max(0, dot(s.Normal, lightDir));
			#define NDL ndl
			#define		RAMP_THRESHOLD	_RampThreshold
			#define		RAMP_SMOOTH		_RampSmooth

			fixed3 ramp = smoothstep(RAMP_THRESHOLD - RAMP_SMOOTH*0.5, RAMP_THRESHOLD + RAMP_SMOOTH*0.5, NDL);
		#if !(POINT) && !(SPOT)
			ramp *= atten;
		#endif
		#if !defined(UNITY_PASS_FORWARDBASE)
			_SColor = fixed4(0,0,0,1);
		#endif
			_SColor = lerp(_HColor, _SColor, _SColor.a);	//Shadows intensity through alpha
			ramp = lerp(_SColor.rgb, _HColor.rgb, ramp);
			fixed4 c;
			c.rgb = s.Albedo * lightColor.rgb * ramp;
			c.a = s.Alpha;
			//Specular
			half3 h = normalize(lightDir + viewDir);
			float ndh = max(0, dot (s.Normal, h));
			float spec = pow(ndh, s.Specular*128.0) * s.Gloss * 2.0;
			spec *= atten;
			c.rgb += lightColor.rgb * _SpecColor.rgb * spec;

		#ifdef UNITY_LIGHT_FUNCTION_APPLY_INDIRECT
			c.rgb += s.Albedo ;
		#endif
			return c;
		}

		// void LightingToonyColorsWater_GI(inout SurfaceOutputWater s, UnityGIInput data, inout UnityGI gi)
		// {
		// 	gi = UnityGlobalIllumination(data, 1.0, s.Normal);
		// 	gi.light.color = _LightColor0.rgb;	//remove attenuation
		// 	s.atten = data.atten;	//transfer attenuation to lighting function
		// }

		//================================================================
		// VERTEX FUNCTION

		struct appdata_tcp2
		{
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			float4 texcoord : TEXCOORD0;
			float4 texcoord1 : TEXCOORD1;
			float4 texcoord2 : TEXCOORD2;
			float4 tangent : TANGENT;
	#if UNITY_VERSION >= 550
			UNITY_VERTEX_INPUT_INSTANCE_ID
	#endif
		};

        #define TIME (_Time.y)

		void vert(inout appdata_tcp2 v, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input, o);

			//Main texture UVs
			float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
			half2 mainTexcoords = worldPos.xz * 0.1;
			o.texcoord.xy = TRANSFORM_TEX(mainTexcoords.xy, _MainTex);
			o.bump_texcoord = mainTexcoords.xy + TIME.xx * _BumpSpeed.xy * 0.1;
			float4 pos = UnityObjectToClipPos(v.vertex);
			o.sPos = ComputeScreenPos(pos);
			COMPUTE_EYEDEPTH(o.sPos.z);
		}

		//================================================================
		// SURFACE FUNCTION

		void surf(Input IN, inout SurfaceOutputWater o)
		{
			//法线
			half3 normal = UnpackScaleNormal(tex2D(_BumpMap, IN.bump_texcoord.xy * _BumpMap_ST.xx), _BumpScale).rgb;
			//法线流动
			half3 normal2 = UnpackScaleNormal(tex2D(_BumpMap, IN.bump_texcoord.xy * _BumpMap_ST.yy + TIME.xx * _BumpSpeed.zw  * 0.1), _BumpScale).rgb;
			normal = (normal+normal2) * 0.5;
			o.Normal = normal;
			IN.sPos.xy += normal.rg * _NormalDepthInfluence;
			half ndv = dot(IN.viewDir, normal);
			fixed4 mainTex = tex2D(_MainTex, IN.texcoord.xy);

            //--渲染组最光阴：去掉泡沫的depth计算
			// float sceneZ = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(IN.sPos));
			// if(unity_OrthoParams.w > 0)
			// {
			// 	//orthographic camera
			// #if defined(UNITY_REVERSED_Z)
			// 	sceneZ = 1.0f - sceneZ;
			// #endif
			// 	sceneZ = (sceneZ * _ProjectionParams.z) + _ProjectionParams.y;
			// }
			// else
			// 	//perspective camera
			// 	sceneZ = LinearEyeDepth(sceneZ);
			// float partZ = IN.sPos.z;
			// float depthDiff = 1;


			//Depth-based foam
			half2 foamUV = IN.texcoord.xy;
			foamUV.xy += TIME.xx*_FoamSpeed.xy*0.05;
			fixed4 foam = tex2D(_FoamTex, foamUV);
			foamUV.xy += TIME.xx*_FoamSpeed.zw*0.05;
			fixed4 foam2 = tex2D(_FoamTex, foamUV);
			foam = (foam + foam2) * 0.5 ;

            //--渲染组最光阴：去掉泡沫的泡沫depth计算
			// float foamDepth = saturate(_FoamSpread * depthDiff);
			// half foamTerm = (smoothstep(foam.r - _FoamSmooth, foam.r + _FoamSmooth, saturate(_FoamStrength - foamDepth)) * saturate(1 - foamDepth)) * _FoamColor.a;

            half foamTerm = (smoothstep(foam.r - _FoamSmooth, foam.r + _FoamSmooth, 0) * 0) * _FoamColor.a;
			o.Albedo = lerp(mainTex.rgb * _Color.rgb, _FoamColor.rgb, foamTerm);
			o.Alpha = mainTex.a * _Color.a;
			o.Alpha = lerp(o.Alpha, _FoamColor.a, foamTerm);
			//Specular
			o.Gloss = 1;
			o.Specular = _Shininess;
			//Rim
			half3 rim = smoothstep(_RimMax, _RimMin, 1-Pow4(1-ndv)) * _RimColor.rgb * _RimColor.a;
			o.Emission += rim.rgb;

            //--渲染组最光阴：去掉反射计算
			// fixed4 reflColor = tex2Dproj(_ReflectionTex, UNITY_PROJ_COORD(IN.sPos));
			// o.Emission += reflColor.rgb * _ReflStrength;
		}

        // vertex-to-fragment interpolation data
        // no lightmaps:
        #ifndef LIGHTMAP_ON
        // half-precision fragment shader registers:
        #ifdef UNITY_HALF_PRECISION_FRAGMENT_SHADER_REGISTERS
        #define FOG_COMBINED_WITH_TSPACE
        struct v2f_surf {
        UNITY_POSITION(pos);
        float4 tSpace0 : TEXCOORD0;
        float4 tSpace1 : TEXCOORD1;
        float4 tSpace2 : TEXCOORD2;
        half4 custompack0 : TEXCOORD3; // texcoord bump_texcoord
        float4 custompack1 : TEXCOORD4; // sPos
        #if UNITY_SHOULD_SAMPLE_SH
        half3 sh : TEXCOORD5; // SH
        #endif
        UNITY_LIGHTING_COORDS(6,7)
        UNITY_VERTEX_INPUT_INSTANCE_ID
        UNITY_VERTEX_OUTPUT_STEREO
        };
        #endif
        // high-precision fragment shader registers:
        #ifndef UNITY_HALF_PRECISION_FRAGMENT_SHADER_REGISTERS
        struct v2f_surf 
        {
            UNITY_POSITION(pos);
            float4 tSpace0 : TEXCOORD0;
            float4 tSpace1 : TEXCOORD1;
            float4 tSpace2 : TEXCOORD2;
            half4 custompack0 : TEXCOORD3; // texcoord bump_texcoord
            float4 custompack1 : TEXCOORD4; // sPos
            #if UNITY_SHOULD_SAMPLE_SH
            half3 sh : TEXCOORD5; // SH
            #endif
            UNITY_FOG_COORDS(6)
            UNITY_SHADOW_COORDS(7)
            UNITY_VERTEX_INPUT_INSTANCE_ID
            UNITY_VERTEX_OUTPUT_STEREO
        };
        #endif
        #endif

        // with lightmaps:
        #ifdef LIGHTMAP_ON
        // half-precision fragment shader registers:
        #ifdef UNITY_HALF_PRECISION_FRAGMENT_SHADER_REGISTERS
        #define FOG_COMBINED_WITH_TSPACE
        struct v2f_surf 
        {
            UNITY_POSITION(pos);
            float4 tSpace0 : TEXCOORD0;
            float4 tSpace1 : TEXCOORD1;
            float4 tSpace2 : TEXCOORD2;
            half4 custompack0 : TEXCOORD3; // texcoord bump_texcoord
            float4 custompack1 : TEXCOORD4; // sPos
            float4 lmap : TEXCOORD5;
            UNITY_LIGHTING_COORDS(6,7)
            UNITY_VERTEX_INPUT_INSTANCE_ID
            UNITY_VERTEX_OUTPUT_STEREO
            };
            #endif
            // high-precision fragment shader registers:
            #ifndef UNITY_HALF_PRECISION_FRAGMENT_SHADER_REGISTERS
            struct v2f_surf {
            UNITY_POSITION(pos);
            float4 tSpace0 : TEXCOORD0;
            float4 tSpace1 : TEXCOORD1;
            float4 tSpace2 : TEXCOORD2;
            half4 custompack0 : TEXCOORD3; // texcoord bump_texcoord
            float4 custompack1 : TEXCOORD4; // sPos
            float4 lmap : TEXCOORD5;
            UNITY_FOG_COORDS(6)
            UNITY_SHADOW_COORDS(7)
            UNITY_VERTEX_INPUT_INSTANCE_ID
            UNITY_VERTEX_OUTPUT_STEREO
        };
        #endif
        #endif

        // vertex shader
        v2f_surf vert_surf (appdata_tcp2 v) 
        {
            UNITY_SETUP_INSTANCE_ID(v);
            v2f_surf o;
            UNITY_INITIALIZE_OUTPUT(v2f_surf,o);
            UNITY_TRANSFER_INSTANCE_ID(v,o);
            UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
            Input customInputData;
            vert (v, customInputData);
            o.custompack0.xy = customInputData.texcoord;
            o.custompack0.zw = customInputData.bump_texcoord;
            o.custompack1.xyzw = customInputData.sPos;
            o.pos = UnityObjectToClipPos(v.vertex);
            float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
            float3 worldNormal = UnityObjectToWorldNormal(v.normal);
            fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
            fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
            fixed3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;
            o.tSpace0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
            o.tSpace1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
            o.tSpace2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

            UNITY_TRANSFER_LIGHTING(o,v.texcoord1.xy); // pass shadow and, possibly, light cookie coordinates to pixel shader
            #ifdef FOG_COMBINED_WITH_TSPACE
                UNITY_TRANSFER_FOG_COMBINED_WITH_TSPACE(o,o.pos); // pass fog coordinates to pixel shader
            #elif defined (FOG_COMBINED_WITH_WORLD_POS)
                UNITY_TRANSFER_FOG_COMBINED_WITH_WORLD_POS(o,o.pos); // pass fog coordinates to pixel shader
            #else
                UNITY_TRANSFER_FOG(o,o.pos); // pass fog coordinates to pixel shader
            #endif
            return o;
        }

        // fragment shader
        fixed4 frag_surf (v2f_surf IN) : SV_Target 
        {
            UNITY_SETUP_INSTANCE_ID(IN);
            // prepare and unpack data
            Input surfIN;
            #ifdef FOG_COMBINED_WITH_TSPACE
                UNITY_EXTRACT_FOG_FROM_TSPACE(IN);
            #elif defined (FOG_COMBINED_WITH_WORLD_POS)
                UNITY_EXTRACT_FOG_FROM_WORLD_POS(IN);
            #else
                UNITY_EXTRACT_FOG(IN);
            #endif
            #ifdef FOG_COMBINED_WITH_TSPACE
                UNITY_RECONSTRUCT_TBN(IN);
            #else
                UNITY_EXTRACT_TBN(IN);
            #endif
            UNITY_INITIALIZE_OUTPUT(Input,surfIN);
            surfIN.texcoord.x = 1.0;
            surfIN.bump_texcoord.x = 1.0;
            surfIN.viewDir.x = 1.0;
            surfIN.sPos.x = 1.0;
            surfIN.texcoord = IN.custompack0.xy;
            surfIN.bump_texcoord = IN.custompack0.zw;
            surfIN.sPos = IN.custompack1.xyzw;
            float3 worldPos = float3(IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w);
            #ifndef USING_DIRECTIONAL_LIGHT
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
            #else
                fixed3 lightDir = _WorldSpaceLightPos0.xyz;
            #endif
            float3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
            float3 viewDir = _unity_tbn_0 * worldViewDir.x + _unity_tbn_1 * worldViewDir.y  + _unity_tbn_2 * worldViewDir.z;
            surfIN.viewDir = viewDir;
            #ifdef UNITY_COMPILER_HLSL
            SurfaceOutputWater o = (SurfaceOutputWater)0;
            #else
            SurfaceOutputWater o;
            #endif
            o.Albedo = 0.0;
            o.Emission = 0.0;
            o.Specular = 0.0;
            o.Alpha = 0.0;
            
            fixed3 normalWorldVertex = fixed3(0,0,1);
            o.Normal = fixed3(0,0,1);

            // call surface function
            surf (surfIN, o);

            // compute lighting & shadowing factor
            // UNITY_LIGHT_ATTENUATION(atten, IN, worldPos)
            
            fixed4 c = 0;
            float3 worldN;
            worldN.x = dot(_unity_tbn_0, o.Normal);
            worldN.y = dot(_unity_tbn_1, o.Normal);
            worldN.z = dot(_unity_tbn_2, o.Normal);
            worldN = normalize(worldN);
            o.Normal = worldN;

            //--渲染组最光阴：替换传统全局光计算
            // Setup lighting environment
            // UnityGI gi;
            // UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
            // gi.indirect.diffuse = 0;
            // gi.indirect.specular = 0;
            // gi.light.color = _LightColor0.rgb;
            // gi.light.dir = lightDir;
            // Call GI (lightmaps/SH/reflections) lighting function
            // UnityGIInput giInput;
            // UNITY_INITIALIZE_OUTPUT(UnityGIInput, giInput);
            // giInput.light = gi.light;
            // giInput.worldPos = worldPos;
            // giInput.worldViewDir = worldViewDir;
            // giInput.atten = atten;
            // #if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
            //     giInput.lightmapUV = IN.lmap;
            // #else
            //     giInput.lightmapUV = 0.0;
            // #endif
            // #if UNITY_SHOULD_SAMPLE_SH && !UNITY_SAMPLE_FULL_SH_PER_PIXEL
            //     giInput.ambient = IN.sh;
            // #else
            //     giInput.ambient.rgb = 0.0;
            // #endif
            // giInput.probeHDR[0] = unity_SpecCube0_HDR;
            // giInput.probeHDR[1] = unity_SpecCube1_HDR;
            // #if defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION)
            //     giInput.boxMin[0] = unity_SpecCube0_BoxMin; // .w holds lerp value for blending
            // #endif
            // #ifdef UNITY_SPECCUBE_BOX_PROJECTION
            //     giInput.boxMax[0] = unity_SpecCube0_BoxMax;
            //     giInput.probePosition[0] = unity_SpecCube0_ProbePosition;
            //     giInput.boxMax[1] = unity_SpecCube1_BoxMax;
            //     giInput.boxMin[1] = unity_SpecCube1_BoxMin;
            //     giInput.probePosition[1] = unity_SpecCube1_ProbePosition;
            // #endif
            //   LightingToonyColorsWater_GI(o, giInput, gi);
            // realtime lighting: call lighting function
            // c += LightingToonyColorsWater (o, worldViewDir, gi);

            c += LightingToonyColorsWater (o, worldViewDir);
            c.rgb += o.Emission;
            UNITY_APPLY_FOG(_unity_fogCoord, c); // apply fog
            return c;
        }

#endif
ENDCG
}
	}

	//Fallback "Diffuse"
	CustomEditor "TCP2_MaterialInspector_SG"
}
