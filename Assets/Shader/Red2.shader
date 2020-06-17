Shader "Custom/Red2/半兰伯特模型，逐顶点" {
	Properties
	{

		_Diffuse("Diffuse",Color) = (1,1,1,1)
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8.0,256)) = 20

	}
		SubShader
	{
		Pass
	{
		Tags{ "LightMode" = "ForwardBase" }


		CGPROGRAM
#pragma vertex vert
#pragma fragment frag

#include "Lighting.cginc"

		fixed4 _Diffuse;
	fixed4 _Specular;
	float _Gloss;

	struct a2v {

		float4 vertex : POSITION;
		float3 normal : NORMAL;

	};

	struct v2f {

		float4 pos : SV_POSITION;
		fixed3 color : COLOR;

	};

	v2f vert(a2v v)
	{
		v2f o;
		//顶点信息转换至世界空间
		o.pos = UnityObjectToClipPos(v.vertex);
		//得到环境光部分
		fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
		//顶点法线转换至世界空间
		fixed3 worldnormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
		//光源方向
		fixed3 worldlight = normalize(_WorldSpaceLightPos0.xyz);
		//漫反射部分
		fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldnormal,worldlight));
		//计算反射方向
		fixed3 reflectDir = normalize(reflect(-worldlight,worldnormal));
		//计算视角方向
		fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld,v.vertex).xyz);
		//得到高光发射部分
		fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir,viewDir)),_Gloss);

		o.color = ambient + diffuse + specular;
		return o;
	}

	fixed4 frag(v2f i) : SV_Target
	{
		return fixed4(i.color,1.0);
	}
		ENDCG

	}

	}

		FallBack "Specular"
}
