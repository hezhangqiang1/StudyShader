Shader "Custom/bianyuanyanse/边缘颜色" {
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
	_BumpMap("Bumpmap", 2D) = "bump" {}
	_MaskTex("MaskTex",2D) = "white" {}
	_RimColor("Rim Color", Color) = (0.17,0.36,0.81,0.0)
		_RimPower("Rim Power", Range(0.6,9.0)) = 1.0
	}
		SubShader
	{
		
		Tags{ "RenderType" = "Opaque" }
	
		CGPROGRAM

		//使用兰伯特光照模式
#pragma surface surf Lambert

		//输入结构
		struct Input
	{
		float2 uv_MainTex;//纹理贴图
		float2 uv_BumpMap;//法线贴图
		float3 viewDir;//观察方向
	};

	//变量声明
	sampler2D _MainTex;//主纹理
	sampler2D _MaskTex;//遮罩纹理

	sampler2D _BumpMap;//凹凸纹理
	float4 _RimColor;//边缘颜色
	float _RimPower;//边缘颜色强度

					//表面着色函数的编写
	void surf(Input IN, inout SurfaceOutput o)
	{
		half mask = tex2D(_MaskTex, IN.uv_MainTex);
			if (mask > 0.3) 
			{
				//表面反射颜色为纹理颜色
				o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
				//表面法线为凹凸纹理的颜色
				o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
				//边缘颜色
				half rim = 1.0 - saturate(dot(normalize(IN.viewDir), o.Normal));
				//边缘颜色强度
				o.Emission = _RimColor.rgb * pow(rim, _RimPower);
			}
			else 
			{
				o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
				//表面法线为凹凸纹理的颜色
				o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
			}
		
	}
	ENDCG
	}
		Fallback "Diffuse"
}
