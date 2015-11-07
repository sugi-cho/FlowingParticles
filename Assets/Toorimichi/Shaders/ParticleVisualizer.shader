Shader "Unlit/ParticleVisualizer"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Size ("size", Float) = 0.1
	}
	CGINCLUDE
		#include "UnityCG.cginc"
		#include "Assets/CGINC/Random.cginc"
		#include "Assets/CGINC/BillBoardCommon.cginc"

		struct appdata
		{
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
			float2 uv2 : TEXCOORD1;
			half4 color : COLOR;
		};

		struct v2f
		{
			float4 vertex : SV_POSITION;
			float2 uv : TEXCOORD0;
			half4 color : TEXCOORD1;
		};
		
		struct pOut
		{
			float4 vis : SV_Target0;
			float4 kage : SV_Target1;
		};
		
		uniform sampler2D _Pos,_Vel,_Col;
		uniform int _MRT_TexSize, _Offset;
		sampler2D _MainTex;
		float4 _MainTex_ST;
		float _Size;
		
		v2f vert (appdata v)
		{
			float id = floor(v.uv2.x) + _Offset;
			float2 uv = float2(frac(id/_MRT_TexSize),id/_MRT_TexSize/_MRT_TexSize);
			half4 pos = tex2D(_Pos, uv);
			half4 vel = tex2D(_Vel, uv);
			half4 col = tex2D(_Col, uv);
			
			v.vertex.xyz += pos.xyz;
			v.color = col;
			
			float4 vPos = vPosBillboard(v.vertex, v.uv, _Size);
			
			v2f o;
			o.vertex = mul(UNITY_MATRIX_P, vPos);
			o.uv = TRANSFORM_TEX(v.uv, _MainTex);
			o.color = v.color;
			return o;
		}
		
		pOut frag (v2f i)
		{
			pOut o;
			o.vis = tex2D(_MainTex, i.uv)*i.color;
			o.kage = 0.5-distance(float2(0.5,0.5),i.uv);
			return o;
		}
	ENDCG
	SubShader
	{
		ZTest Always ZWrite Off
		Blend One One
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			
			ENDCG
		}
	}
}
