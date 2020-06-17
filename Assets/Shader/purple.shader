Shader "Custom/purple/透明球" {
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
	}
		SubShader
	{
		Tags{ "Queue" = "Transparent" "RenderType" = "Opaque" }
		LOD 100
		GrabPass{ "_ScreenTex" }
		Pass
	{
		CGPROGRAM
#pragma vertex vert
#pragma fragment frag
		// make fog work
#pragma multi_compile_fog

#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"
		struct appdata
	{
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
	};

	struct v2f
	{
		float4 uv : TEXCOORD0;
		float2 uv2 : TEXCOORD1;
		float4 vertex : SV_POSITION;
	};

	sampler2D _MainTex;
	float4 _MainTex_ST;
	sampler2D _ScreenTex;
	v2f vert(appdata v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv2 = TRANSFORM_TEX(v.uv, _MainTex);
		o.uv = ComputeGrabScreenPos(o.vertex);
		//o.uv.x = 1 - o.uv.x;
		return o;
	}

	fixed4 frag(v2f i) : SV_Target
	{
		// sample the texture
		i.uv.xy += float2(0.1,0.1);
	fixed4 fra = tex2D(_ScreenTex, i.uv.xy / i.uv.w);
	fixed4 fle = tex2D(_MainTex, i.uv2);
	// apply fog
	return lerp(fra, fle, 0.2);
	}
		ENDCG
	}
	}
		FallBack "Diffuse"
}
