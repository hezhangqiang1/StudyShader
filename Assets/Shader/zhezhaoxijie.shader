Shader "Custom/zhezhaoxijie/遮罩细节" {
	
	Properties
	{
		_MainTex("基础纹理(RGB)", 2D) = "white" {}
	_BlendTex("混合纹理(RGBA) ", 2D) = "white" {}
	_MainColor("Color",Color) = (1,1,1,1)
	}

		
		SubShader
	{
		
		Pass
	{
		CGPROGRAM
#pragma vertex vert
#pragma fragment frag

#include "UnityCG.cginc"

		struct appdata
	{
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
	};

	struct v2f
	{
		float2 uv : TEXCOORD0;
		float4 vertex : SV_POSITION;
	};

	sampler2D _MainTex;
	float4 _MainTex_ST;
	fixed4 _MainColor;
	v2f vert(appdata v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv = TRANSFORM_TEX(v.uv, _MainTex);
		
		return o;
	}

	fixed4 frag(v2f i) : SV_Target
	{
		fixed4 b_color = _MainColor*((cos(_Time.y * 4) + 3) / 8.0);//通过COs（）实现周期变化
																   // sample the texture
	fixed4 col = tex2D(_MainTex, i.uv)*b_color;
	return col;
	}
		ENDCG
	}

		Pass
	{
		
		// 应用主纹理
		SetTexture[_MainTex]{ combine texture }
		// 使用相加操作来进行Alpha纹理混合
		SetTexture[_BlendTex]{ combine texture + previous }
	}
		
	}
	FallBack "Diffuse"
}
