
Shader "Custom/Yellow/法线贴图，凸凹效果" {
	Properties{
		_MainTex("Base (RGB)", 2D) = "white" {}
	_Bump("Bump", 2D) = "bump" {}
	_Specular("Specular", Range(1.0, 500.0)) = 250.0
		_Gloss("Gloss", Range(0, 256)) = 10
		_Light("Light",Range(0, 1)) = 0.1
		//岩浆流动
		_MainTex2("Another Texture", 2D) = "white" {}
	_MainTex3("Third Texture", 2D) = "white" {}

	_Speed("Speed",Range(0,100)) = 2
		_ScrollXSpeed("ScrollXSpeed",Range(0,100)) = 10
		_ScrollYSpeed("ScrollYSpeed",Range(0,100)) = 10

		//反射
		_CubeTex("Cube Tex", Cube) = ""{}
	}
		SubShader{
		Tags{ "RenderType" = "Opaque" }
		LOD 200

		Pass{
		Tags{ "LightMode" = "ForwardBase" }


		CGPROGRAM

#pragma vertex vert
#pragma fragment frag
#pragma multi_compile_fwdbase

#include "UnityCG.cginc"
#include "Lighting.cginc"      //unity内置变量 如_lightColor0是内置变量
#include "AutoLight.cginc"

		uniform float4x4 unity_WorldToLight; // 引入光矩阵
	sampler2D _MainTex;
	sampler2D _Bump;
	float _Specular;
	float _Gloss;
	float _Light;
	float4 _MainTex_ST;
	

	//岩浆流动
	sampler2D _MainTex2;
	sampler2D _MainTex3;

	fixed _Speed;
	fixed _ScrollXSpeed;
	fixed _ScrollYSpeed;

	//a2v a表示应用 v表示顶点着色器，A2V就是把数据从应用阶段传递到顶点着色器中
	struct a2v {
		//这些语义中的数据是使用该材质的MeshRender组件提供的，在每帧调用DrawCall的时候，MeshRender组件把他负责渲染
		//的模型数据发送给unity Shader
		float4 vertex : POSITION;  // 输入的模型顶点信息
		fixed3 normal : NORMAL;   // 输入的法线信息
		fixed4 texcoord : TEXCOORD0; // 输入的坐标纹理集
		fixed4 tangent : TANGENT;  // 切线信息
	};

	struct v2f {
		//精度 fixed<half<float  尽可能的使用精度较低的类型

		float4 pos : POSITION; // 输出的顶点信息
		fixed2 uv : TEXCOORD0; // 输出的UV信息
		fixed3 lightDir : TEXCOORD1; // 输出的光照方向
		fixed3 viewDir : TEXCOORD2; // 输出的摄像机方向
									//LIGHTING_COORDS(3,4) // 封装了下面的写法
		float3 _LightCoord : TEXCOORD3;  // 光照坐标
		float4 _ShadowCoord : TEXCOORD4; // 阴影坐标

		//反射
		float3 reflectionDir : TEXCOORD5;

		//片元着色器中的输入实际上是把顶点着色器的输出进行插值后得到的结果

	};

	//uniform 是CG中修饰变量和参数的一种修饰词，仅仅用于提供一些关于该变量的初始值是如何指定和存储的相关信息，可省略
	uniform samplerCUBE _CubeTex;

	v2f vert(a2v v) {
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

		// 创建一个正切空间的旋转矩阵,TANGENT_SPACE_ROTATION由下面两行组成
		//TANGENT_SPACE_ROTATION;
		float3 binormal = cross(v.normal, v.tangent.xyz) * v.tangent.w;
		float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);

		// 将顶点的光方向，转到切线空间
		// 该顶点在对象坐标中的光方向向量,乘以切线空间旋转矩阵
		o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex));
		// 该顶点在摄像机坐标中的方向向量,乘以切线空间旋转矩阵
		o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex));

		// 将照明信息给像素着色器，应该是用于下面片段中光衰弱atten的计算
		// TRANSFER_VERTEX_TO_FRAGMENT(o); // 由下面两行组成
		// 顶点转到世界坐标,再转到光坐标
		o._LightCoord = mul(unity_WorldToLight, mul(unity_ObjectToWorld, v.vertex)).xyz;
		// 顶点转到世界坐标，再从世界坐标转到阴影坐标
		o._ShadowCoord = mul(unity_WorldToShadow[0], mul(unity_ObjectToWorld, v.vertex));
		// 注：把上面两行代码注释掉，也看不出上面效果，或许我使用的是平行光

		//反射
		float3 worldNormal = UnityObjectToWorldNormal(v.normal);
		float3 worldViewDir = WorldSpaceViewDir(v.vertex);
		o.reflectionDir = reflect(-worldViewDir, worldNormal);
		
		return o;
	}

	fixed4 frag(v2f i) : COLOR{
		// 对主纹理进行采样
		fixed4 texColor = tex2D(_MainTex, i.uv);
	// 对法线图进行采样
	fixed3 norm = UnpackNormal(tex2D(_Bump, i.uv));
	// 光衰弱，卧槽，里面封装了比较深，暂时看不进去，就不拆开了
	fixed atten = LIGHT_ATTENUATION(i);
	// 环境光，Unity内置
	fixed3 ambi = UNITY_LIGHTMODEL_AMBIENT.xyz;
	// 求漫反射
	// 公式：漫反射色 = 光颜色*N,L的余弦值(取大于0的)，所以夹角越小亮度越小
	fixed3 diff = _LightColor0.rgb * saturate(dot(normalize(norm),  normalize(i.lightDir))) * 2;

	// 计算反射光线向量
	// 公式：reflect(入射光方向,法线向量)
	fixed3 refl = reflect(-i.lightDir, norm);
	// 计算反射高光
	// 公式：反射高光 = 光颜色 * 【(反射光向量，摄像机方向向量)的余弦值】的【高光指数_Specular】次方 * 光泽度
	fixed3 spec = _LightColor0.rgb * pow(saturate(dot(normalize(refl), normalize(i.viewDir))), _Specular) * _Gloss;
	// 最终颜色
	// 公式：(环境光 + (漫反射 + 反射高光) * 光衰弱 ) * 材质主色
	fixed4 fragColor;
	fragColor.rgb = float3((ambi + (diff + spec) * atten) * texColor);
	fragColor.a = 1.0f;

	half4 c = tex2D(_MainTex, i.uv);
	half4 c2 = tex2D(_MainTex2, i.uv);

	float  sintime = sin(_Time * _Speed);
	fixed xScrollValue = _ScrollXSpeed * _Time;
	fixed yScrollValue = _ScrollYSpeed * _Time;
	fixed2 scrolledUV = i.uv;

	scrolledUV += fixed2(xScrollValue, yScrollValue);
	half4 c3 = tex2D(_MainTex3, scrolledUV);

	float  highcolor_r = (c2.r * sintime + 1.0) * 0.5;
	float3 highcolor = float3(0, 0, 0);
	float3 texcolor3 = float3(0, 0, 0);
	if (c2.r > 0.3)
	{
		highcolor = float3(highcolor_r, highcolor_r, highcolor_r);
		texcolor3 = float3(c3.r, c3.g, c3.b);
		fragColor.rgb = c.rgb + texcolor3 + highcolor *0.5;
		fragColor.a = c.a;
		return fragColor;
	}
	else 
	{
		
		fixed4 fragColor1 = texCUBE(_CubeTex, i.reflectionDir)*_Light + fragColor;
		return fragColor1;
	}
	
	return fragColor;
	
	}
		ENDCG
	}
	}
		FallBack "Diffuse"
}
