Shader "Custom/jinshu/金属" {
	Properties{
		_MainTint("Diffuse Tint", Color) = (1,1,1,1)
		_MainTex("Base (RGB)", 2D) = "white" {}
	_RoughnessTex("Roughness texture", 2D) = "" {}
	_Roughness("Roughness", Range(0,1)) = 0.5//表面粗糙度 贴图
		_SpecularColor("Specular Color", Color) = (1,1,1,1)//高光颜色
		_SpecPower("Specular Power", Range(0,30)) = 2//高光强度
		_Fresnel("Fresnel Value", Range(0,1.0)) = 0.05
	}
		SubShader{
		Tags{ "RenderType" = "Opaque" }
		LOD 200

		CGPROGRAM
#pragma surface surf MetallicSoft
#pragma target 3.0
		//软金属
		sampler2D _MainTex;
	sampler2D _RoughnessTex;//表面粗糙度 贴图
	float _Roughness;//表面粗糙度 值
	float _Fresnel;
	float _SpecPower;
	float4 _MainTint;
	float4 _SpecularColor;
	//viewDir 意为World Space View Direction。就是当前坐标的视角方向
	//N normal      
	//V view     
	//L light       
	//H  半角向量用来计算镜面反射（specular reflection）的中间方向矢量（halfway vector）
	inline fixed4 LightingMetallicSoft(SurfaceOutput s, fixed3 lightDir,half3 viewDir, fixed atten)
	{
		float3 halfVector = normalize(lightDir + viewDir);//normalize转化成单位向量
		float NdotL = saturate(dot(s.Normal, normalize(lightDir)));//入射光与表面法线向量的点积当作漫反射光照强度因子
		float NdotH_raw = dot(s.Normal, halfVector);//两个单位向量的点积得到两个向量的夹角的cos值
		float NdotH = saturate(/*NdotH_raw*/dot(s.Normal, halfVector));//如果x小于0返回 0;如果x大于1返回1;否则返回x;把x限制在0-1
		float NdotV = saturate(dot(s.Normal, normalize(viewDir)));
		float VdotH = saturate(dot(halfVector, normalize(viewDir)));

		float geoEnum = 2.0 * NdotH;
		float3 G1 = (geoEnum * NdotV) / NdotH;
		float3 G2 = (geoEnum * NdotL) / NdotH;
		float3 G = min(1.0f, min(G1, G2));//取小的

		float roughness = tex2D(_RoughnessTex, float2(NdotH_raw * 0.5 + 0.5, _Roughness)/*uv*/).r;

		float fresnel = pow(1.0 - VdotH, 5.0);//pow()函数:求x的y次方(次幂)
		fresnel *= (1.0 - _Fresnel);
		fresnel += _Fresnel;

		float3 spec = float3(fresnel * G * roughness * roughness) * _SpecPower;

		float4 c;
		c.rgb = (s.Albedo * _LightColor0.rgb * NdotL) + (spec * _SpecularColor.rgb) * (atten * 2.0f);//_LightColor0场景中平行光的颜色
		c.a = s.Alpha;
		return c;
	}
	struct Input
	{
		float2 uv_MainTex;
	};

	void surf(Input IN, inout SurfaceOutput o)
	{
		half4 c = tex2D(_MainTex, IN.uv_MainTex) * _MainTint;
		o.Albedo = c.rgb;
		o.Alpha = c.a;
	}
	ENDCG
	}
	FallBack "Diffuse"
}
