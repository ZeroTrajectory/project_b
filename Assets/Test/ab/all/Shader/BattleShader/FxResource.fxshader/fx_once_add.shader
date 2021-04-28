// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "fx_shader/fx_once_add"
{
	Properties
	{
		_Maintexture("Maintexture", 2D) = "white" {}
		[HDR]_Color0("Color 0", Color) = (1,1,1,1)
		_Mask("Mask", 2D) = "white" {}
	}
	
	SubShader
	{		
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
		
		Blend One One
		Cull Off
		ColorMask RGBA
		ZWrite Off
		ZTest LEqual	
		
		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#define ASE_NEEDS_FRAG_COLOR

			struct appdata
			{
				fixed4 vertex : POSITION;
				fixed4 color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				fixed4 ase_texcoord : TEXCOORD0;
				fixed4 ase_texcoord1 : TEXCOORD1;
			};
			
			struct v2f
			{
				fixed4 vertex : SV_POSITION;
#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				fixed3 worldPos : TEXCOORD0;
#endif
				UNITY_VERTEX_INPUT_INSTANCE_ID
				fixed4 ase_color : COLOR;
				fixed4 ase_texcoord1 : TEXCOORD1;
				fixed4 ase_texcoord2 : TEXCOORD2;
			};

			uniform sampler2D _Maintexture;
			uniform fixed4 _Maintexture_ST;
			uniform fixed4 _Color0;
			uniform sampler2D _Mask;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.ase_color = v.color;
				o.ase_texcoord1 = v.ase_texcoord;
				o.ase_texcoord2 = v.ase_texcoord1;
				fixed3 vertexValue = fixed3(0, 0, 0);
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

#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				fixed4 finalColor;
#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				fixed3 WorldPosition = i.worldPos;
#endif
				fixed4 uv0_Maintexture = i.ase_texcoord1;
				uv0_Maintexture.xy = i.ase_texcoord1.xy * _Maintexture_ST.xy + _Maintexture_ST.zw;
				fixed4 uv1_Maintexture = i.ase_texcoord2;
				uv1_Maintexture.xy = i.ase_texcoord2.xy * _Maintexture_ST.xy + _Maintexture_ST.zw;
				fixed2 appendResult13 = (fixed2(( uv0_Maintexture.x + uv1_Maintexture.x ) , ( uv0_Maintexture.y + uv1_Maintexture.y )));
				fixed4 tex2DNode1 = tex2D( _Maintexture, appendResult13 );
				fixed2 appendResult23 = (fixed2(( uv0_Maintexture.z + uv1_Maintexture.z ) , ( uv0_Maintexture.w + uv1_Maintexture.w )));
				fixed4 tex2DNode14 = tex2D( _Mask, appendResult23 );				
				
				finalColor = ( i.ase_color * i.ase_color.a * tex2DNode1 * tex2DNode1.a * _Color0 * tex2DNode14.r * tex2DNode14.a );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"	
}

/*ASEBEGIN
Version=18100
2032;96;1801;808;2416.064;667.0284;2.371421;True;False
Node;AmplifyShaderEditor.TextureCoordinatesNode;16;-1273.107,174.3862;Inherit;False;1;1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;9;-1260.591,-197.0728;Inherit;False;0;1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;22;-727.4788,531.3303;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;21;-721.6602,352.6531;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;17;-758.1389,-5.663691;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;18;-737.9893,145.4543;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;23;-515.2874,445.1656;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;13;-553.7661,49.84884;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;2;-182.0422,193.8037;Inherit;False;Property;_Color0;Color 0;1;1;[HDR];Create;True;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;4;-173.6774,-240.015;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;14;-212.3603,419.6708;Inherit;True;Property;_Mask;Mask;2;0;Create;True;0;0;False;0;False;-1;None;614c29a6b71c4ae48a37cfc0a9c95990;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-253.3964,-33.7224;Inherit;True;Property;_Maintexture;Maintexture;0;0;Create;True;0;0;False;0;False;-1;None;df0ad26f172bc8946a8e6c289c6606af;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;211.4821,22.71393;Inherit;False;7;7;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;4;COLOR;0,0,0,0;False;5;FLOAT;0;False;6;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;672.5165,21.33865;Half;False;True;-1;2;ASEMaterialInspector;100;1;fx_shader/fx_once_add;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;4;1;False;-1;1;False;-1;0;5;False;-1;10;False;-1;True;0;False;-1;0;False;-1;True;False;True;2;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;False;0;False;-1;0;False;-1;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;0;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;0
WireConnection;22;0;9;4
WireConnection;22;1;16;4
WireConnection;21;0;9;3
WireConnection;21;1;16;3
WireConnection;17;0;9;1
WireConnection;17;1;16;1
WireConnection;18;0;9;2
WireConnection;18;1;16;2
WireConnection;23;0;21;0
WireConnection;23;1;22;0
WireConnection;13;0;17;0
WireConnection;13;1;18;0
WireConnection;14;1;23;0
WireConnection;1;1;13;0
WireConnection;3;0;4;0
WireConnection;3;1;4;4
WireConnection;3;2;1;0
WireConnection;3;3;1;4
WireConnection;3;4;2;0
WireConnection;3;5;14;1
WireConnection;3;6;14;4
WireConnection;0;0;3;0
ASEEND*/
//CHKSM=2BD2330D88F384B4B0E4C91BCF26B2AD4DAAEE90