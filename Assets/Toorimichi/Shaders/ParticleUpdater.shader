Shader "Unlit/ParticleUpdater"
{
	Properties
	{
		_Scale ("curl scale", Float) = 0.1
		_Speed ("curl speed", Float) = 1
		_EmitPos ("emit pos(minX,minY,maxX,maxY)", Vector) = (-10,-10,10,10)
		_Life ("life time", Float) = 30
		
		_Emit ("emit tex", 2D) = "black"{}
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
			_Emit,
			_Kage;
		uniform float4x4 _MATRIX_VP;
		float _Scale,_Speed,_Life;
		float4 _EmitPos;
		
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
			o.pos = float4(i.uv,0,_Life);
			o.pos.xy = normalize(o.pos.xy-0.5) * max(abs(o.pos.x-0.5),abs(o.pos.y-0.5)) * 20;
			return o;
		}
		pOut fragEmit(v2f i)
		{
			float4
				vel = tex2D(_Vel, i.uv),
				pos = tex2D(_Pos, i.uv);
			float life = pos.w;
			
			float2 emitPos = float2(rand(i.uv.xy+_Time.x),rand(i.uv.yx+_Time.x));
			emitPos = emitPos * _EmitPos.xy - _EmitPos.xy*0.5;
//			float4 emi = tex2D(_Emit, sUV(float3(emitPos,0)));
			float4 emi = tex2D(_Emit, emitPos.xy*0.05);
			
//			if(life < 0){
				pos.xy = emitPos;
//				if(0.5 < emi.r)
					pos.w = float4(emitPos,0,_Life);
//			}	
			
			pOut o;
			o.vel = vel;
			o.pos = pos;
			o.col = emi;
			return o;
		}
		pOut fragUpdate (v2f i)
		{
			float4
				vel = tex2D(_Vel, i.uv),
				pos = tex2D(_Pos, i.uv),
				noise = tex2D(_NoiseTex, frac(pos.xy*_Scale));
				
//			vel.y += rand(i.uv)*0.1;
			pos.xy += vel.xy*unity_DeltaTime.x*saturate(pos.w);
			pos.w -= unity_DeltaTime.x;
			
			pOut o;
			o.vel = vel;
			o.pos = pos;
			o.col = 1;
			return o;
		}
		pOut fragCurl (v2f i)
		{
			float4
				vel = tex2D(_Vel, i.uv),
				pos = tex2D(_Pos, i.uv),
				noise = tex2D(_NoiseTex, frac(pos.xy*_Scale));
			
			float2 curl = noise.xy*(i.uv*0.75+0.25);
			curl *= _Speed;
			pos.xy += curl*unity_DeltaTime.x*saturate(pos.w);
			
			pOut o;
			o.vel = vel;
			o.pos = pos;
			o.col = 1;
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
