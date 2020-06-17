// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "WorldMatFree"
{
	Properties
	{
		_ColorTint("Color Tint", Color) = (1,1,1,0)
		_Albedo("Albedo", 2D) = "white" {}
		_Normal("Normal", 2D) = "bump" {}
		_NormalScale("Normal Scale", Range( 0.1 , 3)) = 1
		_Metallic("Metallic", 2D) = "white" {}
		_MetallicStrength("Metallic Strength", Range( 0 , 1)) = 0
		_Smoothness("Smoothness", 2D) = "white" {}
		_SmoothnessStrength("Smoothness Strength", Range( 1 , 2)) = 1
		_Height("Height", 2D) = "white" {}
		_HeightDisplacement("Height Displacement", Range( 0 , 1)) = 0
		_AO("AO", 2D) = "white" {}
		_EdgeLength ( "Edge length", Range( 2, 50 ) ) = 15
		_Tile("Tile", Range( 1 , 10)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityStandardUtils.cginc"
		#include "Tessellation.cginc"
		#pragma target 4.6
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc tessellate:tessFunction 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _Height;
		uniform float _Tile;
		uniform float _HeightDisplacement;
		uniform float _NormalScale;
		uniform sampler2D _Normal;
		uniform sampler2D _Albedo;
		uniform float4 _ColorTint;
		uniform sampler2D _Metallic;
		uniform float _MetallicStrength;
		uniform sampler2D _Smoothness;
		uniform float _SmoothnessStrength;
		uniform sampler2D _AO;
		uniform float _EdgeLength;

		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			return UnityEdgeLengthBasedTess (v0.vertex, v1.vertex, v2.vertex, _EdgeLength);
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float2 temp_cast_0 = (_Tile).xx;
			float2 uv_TexCoord24 = v.texcoord.xy * temp_cast_0;
			float3 ase_vertexNormal = v.normal.xyz;
			v.vertex.xyz += ( ( tex2Dlod( _Height, float4( uv_TexCoord24, 0, 1.0) ) * float4( ase_vertexNormal , 0.0 ) ) * _HeightDisplacement ).rgb;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 temp_cast_0 = (_Tile).xx;
			float2 uv_TexCoord24 = i.uv_texcoord * temp_cast_0;
			o.Normal = UnpackScaleNormal( tex2D( _Normal, uv_TexCoord24 ), _NormalScale );
			o.Albedo = ( tex2D( _Albedo, uv_TexCoord24 ) * _ColorTint ).rgb;
			o.Metallic = ( tex2D( _Metallic, uv_TexCoord24 ) * _MetallicStrength ).r;
			o.Smoothness = ( tex2D( _Smoothness, uv_TexCoord24 ) * _SmoothnessStrength ).r;
			o.Occlusion = tex2D( _AO, uv_TexCoord24 ).r;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
