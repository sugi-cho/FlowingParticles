Shader "Unlit/ParticleUpdater"
{
	Properties
	{
		_Scale ("curl scale", Float) = 0.1
		_Speed ("curl speed", Float) = 1
		_Life ("life time", Float) = 30
		
		_Emit ("emit tex", 2D) = "black"{}
		_EmitRate ("particles per sec", Float) = 0.1
	}
	CGINCLUDE
		#include "UnityCG.cginc"
		#include "Assets/CGINC/Random.cginc"

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
			float4 pos : SV_Target1;// (pos.xyz, life)
			float4 col : SV_Target2;
		};

		uniform sampler2D
			_NoiseTex,
			_Vel,
			_Pos,
			_Col,
			_Emit,
			_Kage;
		uniform float4x4 _MATRIX_VP;
		uniform float _MRT_TexSize;
		float _Scale,_Speed,_Life,_EmitRate;
		
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
		
		float colorRate(float t){
			return saturate(t)*saturate(_Life-t);
		}
		float2 fullPos(float2 uv, float rad, float t)
		{
			float x = uv.x + frac(t/_MRT_TexSize);
			float y = uv.y + t/_MRT_TexSize/_MRT_TexSize;
			uv = frac(float2(x,y));
			return normalize(uv-0.5) * max(abs(uv.x-0.5),abs(uv.y-0.5)) * rad;
		}
		pOut fragInit (v2f i)
		{
			pOut o;
			o.vel = 0;
			o.pos = float4(fullPos(i.uv,20,0),0,-rand(i.uv)*_Life);
			o.col = 0;
			return o;
		}
		pOut fragEmit(v2f i)
		{
			float4
				vel = tex2D(_Vel, i.uv),
				pos = tex2D(_Pos, i.uv),
				col = tex2D(_Col, i.uv);
			float life = pos.w;
			
			float2 emitPos = fullPos(i.uv,20,_Time.y*_MRT_TexSize*_MRT_TexSize*_EmitRate);
			float2 uv = sUV(float3(emitPos,0));
			float4 emi = tex2D(_Emit, uv);
			
			if(life < 0)
			if(0.9<frac(life))
			if(0<min(uv.x,uv.y))
			if(max(uv.x,uv.y)<1)
			if(0.5 < emi.r){
				pos = float4(emitPos,0,_Life);
				col = emi;
			}
			
			
			pOut o;
			o.vel = vel;
			o.pos = pos;
			o.col = col;
			return o;
		}
		pOut fragUpdate (v2f i)
		{
			float4
				vel = tex2D(_Vel, i.uv),
				pos = tex2D(_Pos, i.uv),
				col = tex2D(_Col, i.uv),
				noise = tex2D(_NoiseTex, frac(pos.xy*_Scale));
				
//			vel.y += rand(i.uv)*0.1;
			pos.xy += vel.xy*unity_DeltaTime.x*saturate(pos.w);
			pos.w -= unity_DeltaTime.x;
			col = lerp(float4(0,0,0,1),float4(1,1,1,1),colorRate(pos.w));
			
			pOut o;
			o.vel = vel;
			o.pos = pos;
			o.col = col;
			return o;
		}
		pOut fragCurl (v2f i)
		{
			float4
				vel = tex2D(_Vel, i.uv),
				pos = tex2D(_Pos, i.uv),
				col = tex2D(_Col, i.uv),
				noise = tex2D(_NoiseTex, frac(pos.xy*_Scale));
			
			float2 curl = noise.xy*(i.uv*0.75+0.25);
			curl *= _Speed;
			pos.xy += curl*unity_DeltaTime.x*saturate(pos.w);
			
			pOut o;
			o.vel = vel;
			o.pos = pos;
			o.col = col;
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
			#pragma fragment fragEmit
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
