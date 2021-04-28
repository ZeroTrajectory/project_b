// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "fx_shader/fire"
{
	Properties
	{
		[HDR]_Color("Color", Color) = (1,1,1,1)
		_Noise("Noise", 2D) = "white" {}
		_Uspeed("Uspeed", Float) = 0
		_Vspeed("Vspeed", Float) = 0
		[Toggle]_ParticleSwitch("ParticleSwitch", Float) = 1
		_Slider("Slider", Range( 0 , 1)) = 0
		_MaskScale("MaskScale", Float) = 0.5
		_MaskPower("MaskPower", Float) = 1
	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" "Queue"="Transparent"  }
		LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off
		ColorMask RGBA
		ZWrite Off
		ZTest LEqual
		
		
		
		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				float4 ase_texcoord : TEXCOORD0;
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
			};

			uniform half4 _Color;
			uniform sampler2D _Noise;
			uniform half _Uspeed;
			uniform half _Vspeed;
			uniform float4 _Noise_ST;
			uniform half _MaskScale;
			uniform half _MaskPower;
			uniform half _ParticleSwitch;
			uniform half _Slider;
			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.ase_texcoord.xy = v.ase_texcoord.xy;
				o.ase_color = v.color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				float2 appendResult48 = (float2(_Uspeed , _Vspeed));
				float2 uv0_Noise = i.ase_texcoord.xy * _Noise_ST.xy + _Noise_ST.zw;
				float2 panner41 = ( 1.0 * _Time.y * appendResult48 + uv0_Noise);
				float temp_output_23_0 = ( ( ( 1.0 - uv0_Noise.y ) * _MaskScale ) * pow( _MaskPower , 1.0 ) );
				float ifLocalVar18 = 0;
				if( ( tex2D( _Noise, panner41 ).r * temp_output_23_0 ) <= lerp(i.ase_color.a,_Slider,_ParticleSwitch) )
				ifLocalVar18 = 0.0;
				else
				ifLocalVar18 = 1.0;
				
				
				finalColor = ( _Color * ( ifLocalVar18 * temp_output_23_0 ) * i.ase_color );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=17000
0;0;1920;1019;1655.263;779.9131;1.6;True;False
Node;AmplifyShaderEditor.RangedFloatNode;12;-1230,-149.3086;Half;False;Property;_Uspeed;Uspeed;2;0;Create;True;0;0;False;0;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;3;-1165.42,-431.7862;Float;False;0;1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;14;-1167,22;Half;False;Property;_Vspeed;Vspeed;3;0;Create;True;0;0;False;0;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-244.4128,438.3296;Half;False;Property;_MaskPower;MaskPower;7;0;Create;True;0;0;False;0;1;0.48;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;48;-982.5031,-117.544;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;28;-301.733,221.9094;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-280.8638,318.9172;Half;False;Property;_MaskScale;MaskScale;6;0;Create;True;0;0;False;0;0.5;3.81;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;-69.99999,149.3715;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;22;-52.41284,434.3296;Float;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;41;-781.802,-359.8452;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;168.5348,142.897;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-419.1168,-400.031;Float;True;Property;_Noise;Noise;1;0;Create;True;0;0;False;0;None;cd460ee4ac5c1e746b7a734cc7cc64dd;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;27;-435.3376,-74.80688;Half;False;Property;_Slider;Slider;5;0;Create;True;0;0;False;0;0;0.527;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;38;-85.23009,-529.089;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ToggleSwitchNode;40;-121.4218,-112.8698;Half;False;Property;_ParticleSwitch;ParticleSwitch;4;0;Create;True;0;0;False;0;1;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;117.3225,-255.2079;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-156.6,-10.8;Half;False;Constant;_ifab;ifa>b;3;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-210,82.20003;Float;False;Constant;_ab;a<b;3;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ConditionalIfNode;18;272.6124,-103.0997;Float;False;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;606.5676,-69.01804;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;35;339.3206,-417.4541;Half;False;Property;_Color;Color;0;1;[HDR];Create;True;0;0;False;0;1,1,1,1;1.56179,0.5904196,0.2873104,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;631.9395,-366.711;Float;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;860.0237,-191.2138;Half;False;True;2;Half;ASEMaterialInspector;0;1;fx_shader/fire;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;True;False;True;2;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;False;0;False;-1;0;False;-1;True;3;RenderType=Opaque=RenderType;Queue=Transparent=Queue=0;Transparentt=;True;2;0;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;0
WireConnection;48;0;12;0
WireConnection;48;1;14;0
WireConnection;28;0;3;2
WireConnection;4;0;28;0
WireConnection;4;1;6;0
WireConnection;22;0;24;0
WireConnection;41;0;3;0
WireConnection;41;2;48;0
WireConnection;23;0;4;0
WireConnection;23;1;22;0
WireConnection;1;1;41;0
WireConnection;40;0;38;4
WireConnection;40;1;27;0
WireConnection;25;0;1;1
WireConnection;25;1;23;0
WireConnection;18;0;25;0
WireConnection;18;1;40;0
WireConnection;18;2;19;0
WireConnection;18;3;20;0
WireConnection;18;4;20;0
WireConnection;37;0;18;0
WireConnection;37;1;23;0
WireConnection;36;0;35;0
WireConnection;36;1;37;0
WireConnection;36;2;38;0
WireConnection;0;0;36;0
ASEEND*/
//CHKSM=90FD61D893F502EA7B30D70FA0F1CB28969758A0