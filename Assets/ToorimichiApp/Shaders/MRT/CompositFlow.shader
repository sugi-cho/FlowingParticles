Shader "Hidden/CompositFlow"
{
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
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
			
			uniform sampler2D _VisTex,_KageTex,_CameraKage;
			half4 _KageTex_TexelSize;

			fixed4 frag (v2f i) : SV_Target
			{
//				return tex2D(_KageTex, i.uv);
				half2 d = _KageTex_TexelSize.xy;
				half4
					col00 = tex2D(_KageTex, i.uv + float2(-d.x,-d.y)),
					col01 = tex2D(_KageTex, i.uv + float2(-d.x, d.y)),
					col10 = tex2D(_KageTex, i.uv + float2( d.x,-d.y)),
					col11 = tex2D(_KageTex, i.uv + float2( d.x, d.y));
				half4 col = half4(col00.x-col11.x, col10.y-col01.y,1,1);
				return col;
				return dot(normalize(col.xyz), normalize(float3(1,0.5,0.5)))*0.5+0.5;
			}
			ENDCG
		}
	}
}
