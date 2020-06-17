Shader "Custom/yanjiang/岩浆效果" {
	Properties{
		_MainTex("Base (RGB)", 2D) = "white" {}
	//默认值就是白色

	_MainTint("Diffuse Tint", Color) = (1, 1, 1, 1)
		_ScrollXSpeed("XSpeed", Range(0, 100)) = 2
		_ScrollYSpeed("XSpeed", Range(0, 100)) = 2
	}
		SubShader{
		Tags{ "RenderType" = "Opaque" }
		LOD 200

		CGPROGRAM
#pragma surface surf Lambert

		sampler2D _MainTex;
	float _ScrollXSpeed;
	float _ScrollYSpeed;
	fixed4 _MainTint;

	struct Input {
		float2 uv_MainTex;
	};

	void surf(Input IN, inout SurfaceOutput o)
	{
		//根据时间增加，修改 uv_MainTex ，例如从 (0,0) 到 (1,1) ，这样就类似于贴图在反方向运动。
		fixed2 scrolledUV = IN.uv_MainTex;

		fixed xScrollOffset = _ScrollXSpeed * _Time;
		//注意_Time这个内置变量是float4 值为 Time (t/20, t, t*2, t*3), 
		//就是说Unity给我们几个内定的时间速度来使用，默认是取X值。
		fixed yScrollOffset = _ScrollYSpeed * _Time;

		scrolledUV += fixed2(xScrollOffset,yScrollOffset);

		half4 c = tex2D(_MainTex, scrolledUV);
		o.Albedo = c.rgb * _MainTint;
		o.Alpha = c.a;
	}
	ENDCG
	}
	FallBack "Diffuse"
}
