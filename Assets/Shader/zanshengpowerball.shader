Shader "Custom/zanshengpowerball/噪声能量法球" {
	Properties {
        _MainTex ("主纹理", 2D) = "bump" {}
        _NoiseMap ("噪声图", 2D) = "bump" {}
		_SpeedX("x方向速度",float)=0.02
		_SpeedY("y方向速度",float)=0.02
		_NoiseStrength ("噪波强度",float)=0.1
    }
    SubShader {
	Blend One One
	//Blend SrcAlpha  OneMinusSrcAlpha
	Cull Off
        Tags {
            "Queue"="Transparent"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            uniform float4 _LightColor0;
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform sampler2D _NoiseMap; uniform float4 _NoiseMap_ST;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;

            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos( v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }

uniform float _SpeedX;
uniform float _SpeedY;
uniform float _NoiseStrength;
float4 frag(VertexOutput i) : COLOR {

	//光照函数
    i.normalDir = normalize(i.normalDir);
    float3 normalDirection = i.normalDir;
    float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
    float3 lightColor = _LightColor0.rgb;

    float attenuation = LIGHT_ATTENUATION(i);
    float3 attenColor = attenuation * _LightColor0.xyz;

    float NdotL = max(0.0,dot( normalDirection, lightDirection ));	
    float3 directDiffuse = max( 0.0, NdotL) * attenColor;
    float3 indirectDiffuse = float3(0,0,0);
    indirectDiffuse += UNITY_LIGHTMODEL_AMBIENT.rgb; 
    
	//x,y方向流动
    float2 FlowUV = (i.uv0+float2((_SpeedX*_Time.g),(_Time.g*_SpeedY)));		
    float4 _NoiseMap_var = tex2D(_NoiseMap,TRANSFORM_TEX(FlowUV, _NoiseMap));
	//噪波强度
    float2 NoiseUV = (i.uv0+(float2(_NoiseMap_var.r,_NoiseMap_var.g)*_NoiseStrength));		
    float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(NoiseUV, _MainTex));
    float3 diffuseColor = _MainTex_var.rgb;
    float3 diffuse = (directDiffuse + indirectDiffuse) * diffuseColor;

    float3 finalColor = diffuse;
    fixed4 finalRGBA = fixed4(finalColor,1);
    UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
    return finalRGBA;
            }
            ENDCG
        }
       
    }
    FallBack "Diffuse"
}
