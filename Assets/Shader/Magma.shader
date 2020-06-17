//岩浆shader
Shader "MySharder/Magma"
{
	Properties
	{
		_Color("Color Tint",Color) = (1,1,1,1)
		_MainTex("Main Tex",2D) = "white"{}   //white是内置的默认贴图
		_BumpMap("Normal Map",2D) = "bump"{}  //bump是内置的法线纹理
		_BumpScale("Bump Scale",Float) = 1.0  //凸起的大小
			_Specular("Specular",Color) = (1,1,1,1) //高光的颜色
			_Gloss("Gloss",Range(8.0,256)) = 20  //高光的强度
	
			_MaskTex("MaskTex",2D) = "white"{}
		_Speed("Speed",Range(1,100)) =2
			  _Light("Light",Range(0,1)) = 0.5   //熔浆的亮度
		
			_FlowTex("FlowTex",2D) = "white"{}
		  _ScrollXSpeed("ScrollXSpeed",Range(0,100)) = 10
		  _ScrollYSpeed("ScrollYSpeed",Range(0,100)) = 10

				_ReflectColor("Reflection Color", Color) = (1, 1, 1, 1)
		_ReflectAmount("Reflect Amount", Range(0, 1)) = 1
		_Cubemap("Reflection Cubemap", Cube) = "_Skybox" {}
	}

		SubShader
		{
			Pass
		{
			Tags{"LightMode" = "ForwardBase"}  //设置标签LightMode定义了这个Pass在Unity光照流水线的角色

			CGPROGRAM  //开始写CG代码

#pragma vertex vert   //#pragma指令告诉Unity我们定义的顶点着色器和片元着色器的名字
#pragma fragment frag
#include "Lighting.cginc"  //导入Unity的内置文件，可以直接调用定义好的API
	#include "AutoLight.cginc"
			//声明和上述属性类型匹配的变量
			fixed4 _Color;
		sampler2D _MainTex;
		float4 _MainTex_ST;
		sampler2D _BumpMap;
		float4 _BumpMap_ST;
		Float _BumpScale;
		fixed4 _Specular;
		float _Gloss;

		sampler2D _MaskTex;
		float _Speed;
		float _Light;  //亮度

		sampler2D _FlowTex;
		fixed _ScrollXSpeed;
		fixed _ScrollYSpeed;

		fixed4 _ReflectColor;
		fixed _ReflectAmount;
		samplerCUBE _Cubemap;

		//输入输出结构体
		struct a2v
		{
			float4 vertex:POSITION;   //模型空间的顶点坐标    //应用阶段到顶点着色器的常用语义
			float3 normal:NORMAL;    //模型空间的法线方向
			float4 tangent:Tangent;  //模型空间顶点切线方向
			float4 texcoord:TEXCOORD0;  //模型空间的顶点纹理坐标
		};

		struct v2f
		{
			float4 pos:SV_POSITION;  //裁剪空间的顶点坐标   顶点着色器传递给片元着色器的常用语义      //SV_Target 输出值存储到渲染目标  片元着色器输出数据到unity阶段的语义
			float4 uv:TEXCOORD0;
			float3 lightDir:TEXCOORD1;
			float3 viewDir:TEXCOORD2;

			float3 worldPos : TEXCOORD3;
			fixed3 worldNormal : TEXCOORD4;
			fixed3 worldViewDir : TEXCOORD5;
			fixed3 worldRefl : TEXCOORD6;
			SHADOW_COORDS(4)

		};

		v2f vert(a2v v)
		{
			v2f o;
			//把模型空间的顶点坐标v.vertex 转化为裁剪空间内的顶点坐标
			o.pos = UnityObjectToClipPos(v.vertex);
			//设置纹理坐标的缩放
			o.uv.xy = v.texcoord.xy*_MainTex_ST.xy + _MainTex_ST.zw;
			//设置纹理坐标的平移
			o.uv.zw = v.texcoord.xy*_BumpMap_ST.xy + _BumpMap_ST.zw;

			TANGENT_SPACE_ROTATION;
			o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
			o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;
		
			
			o.worldNormal = UnityObjectToWorldNormal(v.normal);

			o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

			o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);

			// Compute the reflect dir in world space
			o.worldRefl = reflect(-o.worldViewDir, o.worldNormal);

			TRANSFER_SHADOW(o);
			return o;
		}

		fixed4 frag(v2f i) :SV_Target
		{

				fixed3 worldNormal = normalize(i.worldNormal);
					fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
					fixed3 worldViewDir = normalize(i.worldViewDir);


			//光源方向归一化
		fixed3 tangentLightDir = normalize(i.lightDir);
		//视角方向归一化
		fixed3 tangentViewDir = normalize(i.viewDir);

		//对法线纹理取样
		fixed4 packedNormal = tex2D(_BumpMap,i.uv.zw);
		//切线空间下的法线
		fixed3 tangentNormal;

		//手动反映射
		//tangentNormal.xy = (packedNormal.xy * 2 - 1) * _BumpScale;
		tangentNormal = UnpackNormal(packedNormal);
		tangentNormal.xy *= _BumpScale;
		tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy,tangentNormal.xy)));
		
		half4 c2 = tex2D(_MaskTex, i.uv);
		float sintime = sin(_Time*_Speed);
		float highcolor_r = (c2.r*sintime + 1.0)*0.5;
		float3 highcolor = float3(0,0,0);
	
		//流动效果
		fixed xScrollValue = _ScrollXSpeed * _Time;
		fixed yScrollValue = _ScrollYSpeed * _Time;
		fixed2 scrolledUV = i.uv;
		scrolledUV += fixed2(xScrollValue, yScrollValue);
		half4 c3 = tex2D(_FlowTex, scrolledUV);
		float3 texcolor3 = float3(0, 0, 0);

		// Use the reflect dir in world space to access the cubemap
		fixed3 reflection = float3(0, 0, 0);
		UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

		if (c2.r > 0.3) //代表勾缝区域
		{
			highcolor = float3(highcolor_r, highcolor_r, highcolor_r);
			texcolor3 = float3(c3.r,c3.g,c3.b);
		}
		else
		{
			reflection = texCUBE(_Cubemap, i.worldRefl).rgb * _ReflectColor.rgb*_ReflectAmount;
		}
		fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb +/* highcolor * _Light+*/texcolor3+reflection;

		//环境光
		fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

		//漫反射
		fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(tangentNormal,tangentLightDir));

		//高光反射
		fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
		fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(tangentNormal,halfDir)),_Gloss);


		//fixed3 color = ambient + lerp(diffuse, reflection, _ReflectAmount) * atten;

		return fixed4(ambient + diffuse + specular,1.0);

		}
			ENDCG
		}
		}
			FallBack "Specular"
}
