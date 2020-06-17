Shader "Custom/xijiegaoliang/遮罩突出细节" {
	Properties{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
	_MaskTex("Mask", 2D) = "white" {}
	_MainColor("Color",Color) = (1,1,1,1)
	}
		SubShader{
		Tags{ "RenderType" = "Opaque" "Queue" = "Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha

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
		fixed4 b_color = _MainColor*((cos(_Time.y * 4) ) / 8.0);//通过COs（）实现周期变化
																  
	fixed4 col = tex2D(_MainTex, i.uv)*b_color;
	return col;
	}
		ENDCG
	}

		CGPROGRAM
#pragma surface surf Standard keepalpha
#pragma target 3.0

		sampler2D _MainTex;
	sampler2D _MaskTex;
	fixed4 _MainColor;
	struct Input {
		float2 uv_MainTex;
	};

	void surf(Input IN, inout SurfaceOutputStandard o) {
		fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
		fixed4 m = tex2D(_MaskTex, IN.uv_MainTex);
		c = c * m.r; //modified
		o.Albedo = c.rgb;
		o.Alpha = c.a;
	}


	ENDCG

	
	}
	FallBack "Diffuse"
}
