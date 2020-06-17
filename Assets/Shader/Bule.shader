Shader "Custom/Bule/遮罩纹理" {
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Main Tex", 2D) = "white" {}
	_BumpMap("Normal Map", 2D) = "white" {}
	_BumpScale("Bump Scale", Float) = 1.0
		_SpecularMask("Specular Mask", 2D) = "white" {}
	_SpecularScale("Specular Scale", Float) = 1.0
		_Specular("Specular", Color) = (1,1,1,1)
		_Gloss("Gloss", Range(8.0, 256)) = 20
	}

		SubShader
	{
		Pass
	{
		Tags{ "LightMode" = "ForwardBase" }

		CGPROGRAM

#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"
#include "Lighting.cginc"

		fixed4 _Color;
	sampler2D _MainTex;
	float4 _MainTex_ST;      //纹理变量名+_ST为unity内置宏，存储了该纹理的缩放大小和偏移量，分别对应.xy和.zw属性
	sampler2D _BumpMap;
	float _BumpScale;        //控制凹凸程度的变量
	sampler2D _SpecularMask; //遮罩纹理
	float _SpecularScale;    //控制遮罩纹理的可见度
	fixed4 _Specular;
	float _Gloss;

	struct a2v {
		float4 vertex : POSITION;
		float3 normal : NORMAL;
		float4 tangent : TANGENT;
		float4 texcoord : TEXCOORD0;
	};

	struct v2f {
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
		float3 lightDir : TEXCOORD1;
		float3 viewDir : TEXCOORD2;
	};

	v2f vert(a2v v)
	{
		v2f o;

		o.pos = UnityObjectToClipPos(v.vertex);
		//将_MainTex纹理信息(缩放大小和偏移量以及坐标信息)存储到o.uv.xy中
		o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

		//unity内置宏，计算并得到从模型空间到切线空间的变换矩阵rotation
		TANGENT_SPACE_ROTATION;
		//获取切线空间下的光照方向
		o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
		//获取切线空间下的视角方向
		o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;;

		return o;
	}

	fixed4 frag(v2f i) : SV_Target
	{
		//将切线空间下的光照方向和视角方向单位化
		fixed3 tangentLightDir = normalize(i.lightDir);
	fixed3 tangentViewDir = normalize(i.viewDir);

	//获取切线空间下的法向量
	fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uv));
	tangentNormal.xy *= _BumpScale;
	tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

	//获取片元上的主纹理，并和变量_Color相乘得到其混合结果
	fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
	//获取环境光
	fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
	//漫反射计算
	fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));

	//高光反射计算，其计算方式跟前文的计算一样，这里只能另外跟specularMask的遮罩纹理相乘得到其与遮罩纹理的混合结果
	fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
	fixed specularMask = tex2D(_SpecularMask, i.uv).r * _SpecularScale;
	fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss) * specularMask;

	return fixed4(ambient + diffuse + specular, 1.0);
	}

		ENDCG
	}
	}

}