Shader "Hidden/KageProcesser"
{
	Properties
	{
		_MainTex("static kage", 2D) = "black"{}
		_Amp ("kage amp", Float) = 1.0
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

		v2f vert (appdata v)
		{
			v2f o;
			o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
			o.uv = v.uv;
			return o;
		}
		
		uniform sampler2D _EmitTex;
		sampler2D _MainTex;
		float _Amp;

		half4 frag (v2f i) : SV_Target
		{
			half k0 = tex2D(_MainTex, i.uv).r;
			half k1 = tex2D(_EmitTex, i.uv).r;
			half col = max(k0,k1);
			return col;
		}
	ENDCG
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

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
