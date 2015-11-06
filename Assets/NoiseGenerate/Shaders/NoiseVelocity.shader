Shader "Unlit/NoiseVelocity"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Scale ("noise scale", Float) = 0.1
	}
	CGINCLUDE
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
		
		struct pOut
		{
			half4 vel : SV_Target0;
			half4 pos : SV_Target1;
		};

		uniform sampler2D
			_NoiseTex,
			_Vel,
			_Pos;
		sampler2D _MainTex;
		float4 _MainTex_ST;
		float _Scale;
		
		v2f vert (appdata v)
		{
			v2f o;
			o.vertex = v.vertex;
			o.uv = (v.vertex.xy/v.vertex.w+1.0)*0.5;
			return o;
		}
		
		pOut fragInit (v2f i)
		{
			pOut o;
			o.vel = 0;
			o.pos = half4(i.uv,0,1);
			o.pos.xy = normalize(o.pos.xy-0.5) * max(abs(o.pos.x-0.5),abs(o.pos.y-0.5))*5;
			return o;
		}
		pOut fragUpdate (v2f i)
		{
			half4
				vel = tex2D(_Vel, i.uv),
				pos = tex2D(_Pos, i.uv),
				noise = tex2D(_NoiseTex, frac(pos.xy*_Scale));
			vel.xy = noise.xy*(i.uv*0.5+0.5);
			pos += vel*unity_DeltaTime.x;
			pos *= 0.999;
			
			pOut o;
			o.vel = half4(vel.rgb,1);
			o.pos = half4(pos.rgb,1);
			return o;
		}
	ENDCG
	SubShader
	{
		ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment fragInit
			#pragma target 3.0
			
			ENDCG
		}
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment fragUpdate
			#pragma target 3.0
			
			ENDCG
		}
	}
}
