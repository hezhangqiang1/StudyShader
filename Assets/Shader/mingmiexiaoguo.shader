Shader "Custom/mingmiexiaoguo/明灭效果" {
	Properties{
		_MainTex("Base (RGB)", 2D) = "white" {}
	_MainTex2("Another Texture", 2D) = "white" {}
	_MainTex3("Third Texture", 2D) = "white" {}

	_Speed("Speed",Range(0,100)) = 2
		_ScrollXSpeed("ScrollXSpeed",Range(0,100)) = 10
		_ScrollYSpeed("ScrollYSpeed",Range(0,100)) = 10
	}
		SubShader{
		Tags{ "RenderType" = "Opaque" }
		LOD 200

		CGPROGRAM
#pragma surface surf Lambert

		sampler2D _MainTex;
	sampler2D _MainTex2;
	sampler2D _MainTex3;

	fixed _Speed;
	fixed _ScrollXSpeed;
	fixed _ScrollYSpeed;

	struct Input {
		float2 uv_MainTex;
	};

	void surf(Input IN, inout SurfaceOutput o) {
		half4 c = tex2D(_MainTex, IN.uv_MainTex);
		half4 c2 = tex2D(_MainTex2, IN.uv_MainTex);

		float  sintime = sin(_Time * _Speed);
		fixed xScrollValue = _ScrollXSpeed * _Time;
		fixed yScrollValue = _ScrollYSpeed * _Time;
		fixed2 scrolledUV = IN.uv_MainTex;

		scrolledUV += fixed2(xScrollValue,yScrollValue);
		half4 c3 = tex2D(_MainTex3, scrolledUV);

		float  highcolor_r = (c2.r * sintime + 1.0) * 0.5;
		float3 highcolor = float3(0, 0, 0);
		float3 texcolor3 = float3(0, 0, 0);
		if (c2.r > 0.3)
		{
			highcolor = float3(highcolor_r, highcolor_r, highcolor_r);
			texcolor3 = float3(c3.r, c3.g, c3.b);
		}
		o.Albedo = c.rgb + texcolor3 + highcolor *0.5;
		o.Alpha = c.a;
	}
	ENDCG
	}
		FallBack "Diffuse"
	FallBack "Diffuse"
}
