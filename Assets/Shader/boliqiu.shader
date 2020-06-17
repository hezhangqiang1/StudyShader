Shader "Custom/boliqiu/玻璃球" {
	Properties
	{
		_Cube("Skybox",Cube) = ""{}
	//折射角度
	_EtaRatio("EtaRatio", Range(0, 1)) = 0
		//菲涅尔系数
		_FresnelBias("FresnelBias",float) = 0.5
		_FresnelScale("FresnelScale",float) = 0.5
		_FresnelPower("FresnelPower",float) = 0.5
	}
		SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		LOD 100

		Pass
	{
		CGPROGRAM
#pragma vertex vert
#pragma fragment frag


#include "UnityCG.cginc"

		struct appdata
	{
		float4 vertex : POSITION;
		float3 normal:NORMAL;
	};

	struct v2f
	{
		float3 normalDir:TEXCOORD0;
		float4 vertex : SV_POSITION;
		float3 viewDir:TEXCOORD1;
	};

	samplerCUBE _Cube;
	float _EtaRatio;
	float _FresnelBias;
	float _FresnelScale;
	float _FresnelPower;

	//计算视线反射方向（入射角，法线）
	float3 caculateReflectDir(float3 I, float3 N) {
		float3 R = I - 2.0f*N*dot(I,N);
		return R;
	}

	//计算视线折射方向
	float3 caculateRefractDir(float3 I, float3 N, float etaRatio) {
		float cosTheta = dot(-I, N);
		float cosTheta2 = sqrt(1.f - pow(etaRatio, 2) * (1 - pow(cosTheta, 2)));
		float3 T = etaRatio * (I + N * cosTheta) - N * cosTheta2;
		return T;
	}

	//计算菲涅尔效应
	float caculateFresnel(float3 I, float3 N) {
		float fresnel = max(0, min(1, _FresnelBias + _FresnelScale * pow(min(0.0, 1.0 - dot(I, N)), _FresnelPower)));
		return fresnel;
	}

	v2f vert(appdata v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		//视线方向
		o.viewDir = normalize(mul(unity_ObjectToWorld, v.vertex).xyz - _WorldSpaceCameraPos);
		//法线方向
		o.normalDir = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));
		return o;
	}

	fixed4 frag(v2f i) : SV_Target
	{
		//采样反射折射后的天空盒颜色
		float3 reflectDir = caculateReflectDir(i.viewDir,i.normalDir);
		float4 reflectCol = texCUBE(_Cube, reflectDir);
		float3 refractDir = caculateRefractDir(i.viewDir, i.normalDir, _EtaRatio);
		float4 refractCol = texCUBE(_Cube, refractDir);
		//视线越垂直折射越小
		float fresnel = caculateFresnel(i.viewDir, i.normalDir);
		float4 col = lerp(refractCol, reflectCol, fresnel);
		return col;
	}
		ENDCG
	}
	}
	
}
