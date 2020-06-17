Shader "Custom/jinshulasi/金属拉丝" {
	Properties{
		_MainTex("Base (RGB)", 2D) = "white" {}
	_MainTint("Diffuse Tint", Color) = (1,1,1,1)
		_SpecularColor("Specular Color", Color) = (1,1,1,1)//高光颜色
		_SpecPower("Specular Power", Range(0,30)) = 2//高光强度
		_Specular("Specular Amount", Range(0, 1)) = 0.5
		_AnisoDir("Anisotropic Direction", 2D) = ""{}//各向异性方向法线贴图
	_AnisoOffset("Anisotropic Offset", Range(-1,1)) = 1//_AnisoOffset的作用偏移
	}
		SubShader{
		Tags{ "RenderType" = "Opaque" }
		LOD 200

		CGPROGRAM
#pragma surface surf Anisotropic
#pragma target 3.0

		sampler2D _MainTex;
	sampler2D _AnisoDir;//各向异性的
	float4 _MainTint;
	float4 _SpecularColor;
	float _AnisoOffset;
	float _Specular;
	float _SpecPower;
	struct SurfaceAnisoOutput
	{
		fixed3 Albedo;//对光源的反射率
		fixed3 Normal;//法线方向
		fixed3 Emission;//自发光
		fixed3 AnisoDirection;//各向异性方向
		half Specular;//高光反射中的指数部分的系数
		fixed Gloss;//高光反射中的强度系数
		fixed Alpha;//透明度
	};


	inline fixed4 LightingAnisotropic(SurfaceAnisoOutput s, fixed3 lightDir, half3 viewDir, fixed atten)
	{
		//半角矢量运算
		//半角矢量：入射光线【LightDir】和视线[ViewDir]的中间平均值，即半角向量
		//半角和法线计算出一个和视角相关的高光
		fixed3 halfVector = normalize(normalize(lightDir) + normalize(viewDir));//normalize()函数把向量转化成单位向量

		//对镜面高光进行修改计算，将顶点法线和各向异性法线贴图上每个像素进行求和，再与halfVector进行点乘运算，
		//该值为1，表面物体表面法线和halfVector平行，该值为0，他们是垂直的
		//saturate(x)把X截取在【0-1】范围内，如果X是一个矢量，那么会对它的每一个分量进行这样的操作
		float NdotL = saturate(dot(s.Normal, lightDir));

		fixed HdotA = dot(normalize(s.Normal + s.AnisoDirection), halfVector);
		//最终的sin函数计算后，我们就得到了中间有亮点且基于halfVector的环形效果。
		float aniso = max(0, sin(radians(HdotA + _AnisoOffset) * 180));//radians()函数将角度值转换为弧度值 

		float spec = saturate(pow(aniso, s.Gloss * 128) * s.Specular);//saturate(x）函数	如果x小于0返回 0;如果x大于1返回1;否则返回x;把x限制在0-1


		fixed4 c;
		c.rgb = ((s.Albedo * _LightColor0.rgb * NdotL) + (_LightColor0.rgb * _SpecularColor.rgb * spec)) * (atten * 2);
		c.a = 1.0;
		return c;

	}

	struct Input {
		float2 uv_MainTex;
		float2 uv_AnisoDir;
	};

	void surf(Input IN, inout SurfaceAnisoOutput o) {
		half4 c = tex2D(_MainTex, IN.uv_MainTex) * _MainTint;
		//拿到法线方向
		float3 anisoTex = UnpackNormal(tex2D(_AnisoDir, IN.uv_AnisoDir));

		o.AnisoDirection = anisoTex;
		o.Specular = _Specular;
		o.Gloss = _SpecPower;
		o.Albedo = c.rgb;
		o.Alpha = c.a;

	}
	ENDCG
	}
	FallBack "Diffuse"
}
