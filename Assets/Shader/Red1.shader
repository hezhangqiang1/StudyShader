
Shader "Custom/Red1/漫反射逐像素" {
	Properties{
		_Diffuse("Diffuse", Color) = (1, 1, 1, 1)        // 控制材质的漫反射颜色 
	}
		SubShader{
		Pass{
		// LightMode 标签是Pass 标签中的一种，它用于定义该Pass 在Unity 的光照流水线中的角色
		//只有定义了正确的LightMode,我们才能得到一些Unity 的内置光照变量，例如下面的_LightColor0
		Tags{ "LightMode" = "ForwardBase" }

		CGPROGRAM

#pragma vertex vert
#pragma fragment frag

		//为了使用Unity 内置的一些变量，如后面要讲到的_LightColor0，还需要包含进Unity 的内置文件Lighting.cginc
#include "Lighting.cginc"

		fixed4 _Diffuse;

	struct a2v {
		float4 vertex : POSITION;
		float3 normal : NORMAL;
	};

	struct v2f {
		float4 pos : SV_POSITION;
		float3 worldNormal : TEXCOORD0;
	};

	v2f vert(a2v v) {
		v2f o;
	
		o.pos = UnityObjectToClipPos(v.vertex);
		o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);

		return o;
	}

	fixed4 frag(v2f i) : SV_Target{
	
		fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

	
	fixed3 worldNormal = normalize(i.worldNormal);
	
	fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

	fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));

	fixed3 color = ambient + diffuse;

	return fixed4(color, 1.0);
	}

		ENDCG
	}
	}
		FallBack "Diffuse"
}
