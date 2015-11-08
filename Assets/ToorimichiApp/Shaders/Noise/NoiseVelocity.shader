Shader "Unlit/NoiseVelocity"
{
	Properties
	{
		_Scale ("noise scale", Float) = 0.1
		_Speed ("speed", Float) = 1
		_Tex ("texture", 2D) = "white"{}
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
			float4 vel : SV_Target0;
			float4 pos : SV_Target1;
		};

		uniform sampler2D
			_NoiseTex,
			_Vel,
			_Pos,
			_Tex;
		uniform float4x4 _MATRIX_VP;
		float _Scale,_Speed;
		
		v2f vert (appdata v)
		{
			v2f o;
			o.vertex = v.vertex;
			o.uv = (v.vertex.xy/v.vertex.w+1.0)*0.5;
			return o;
		}
		
		float2 sUV(float3 wPos){
			float4 sPos = mul(_MATRIX_VP, float4(wPos,1));
			sPos = ComputeScreenPos(sPos);
			return sPos.xy/sPos.w;
		}
		pOut fragInit (v2f i)
		{
			pOut o;
			o.vel = 0;
			o.pos = float4(i.uv,0,1);
			o.pos.xy = normalize(o.pos.xy-0.5) * max(abs(o.pos.x-0.5),abs(o.pos.y-0.5))*20;
			return o;
		}
		pOut fragUpdate (v2f i)
		{
			float4
				vel = tex2D(_Vel, i.uv),
				pos = tex2D(_Pos, i.uv),
				noise = tex2D(_NoiseTex, frac(pos.xy*_Scale));
			vel -= pos;
			vel *= saturate(2-length(tex2D(_Tex,saturate(sUV(pos.xyz))).rgb))*0.5;
			pos += vel*unity_DeltaTime.x;
			
			pOut o;
			o.vel = half4(vel.rgb,1);
			o.pos = half4(pos.rgb,1);
			return o;
		}
		pOut fragCurl (v2f i)
		{
			float4
				vel = tex2D(_Vel, i.uv),
				pos = tex2D(_Pos, i.uv),
				noise = tex2D(_NoiseTex, frac(pos.xy*_Scale));
			
			float2 curl = noise.xy*(i.uv*0.75+0.25);
			curl *= _Speed * saturate(1.5-length(tex2D(_Tex,saturate(sUV(pos.xyz))).rgb));
			pos.xy += curl*unity_DeltaTime.x;
			
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
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment fragCurl
			#pragma target 3.0
			
			ENDCG
		}
	}
}
