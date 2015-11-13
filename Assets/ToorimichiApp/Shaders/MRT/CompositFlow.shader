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
			
			uniform sampler2D _VisTex,_KageTex,_CameraKage,_CurlWebCam;
			half4 _KageTex_TexelSize;

			fixed4 frag (v2f i) : SV_Target
			{
//				return tex2D(_KageTex, i.uv);
				half2 d = _KageTex_TexelSize.xy;
				half
					col00 = (tex2D(_KageTex, i.uv + float2(-d.x,-d.y)).rgb),
					col01 = (tex2D(_KageTex, i.uv + float2(-d.x, d.y)).rgb),
					col10 = (tex2D(_KageTex, i.uv + float2( d.x,-d.y)).rgb),
					col11 = (tex2D(_KageTex, i.uv + float2( d.x, d.y)).rgb);
				half4 flow = half4((col10+col11 -col00-col01).r, (col01+col11 -col00-col10).r,0,0);
				half4 cc = tex2D(_CurlWebCam, i.uv);
				return -flow + cc*0.01;
			}
			ENDCG
		}
	}
}
