Shader "MRT/PostBlend"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_CamRect ("camera rect(minX,minY,maxX,maxY)", Vector) = (0,0,1,1)
	}
	CGINCLUDE
		#include "UnityCG.cginc"
		
		uniform sampler2D
			_PostBlendBG,_PostBlendMull,_PostBlendColor,_PostBlendAdd,_PostBlendAlpha;
		float4 _CamRect;

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
		
		sampler2D _MainTex;

		fixed4 frag (v2f i) : SV_Target
		{
			half4 bg = tex2D(_PostBlendBG, lerp(_CamRect.xy, _CamRect.zw, i.uv));
			
			half4 mull = tex2D(_PostBlendMull, i.uv);
			half4 color = tex2D(_PostBlendColor, i.uv);
			half4 add = tex2D(_PostBlendAdd, i.uv);
			half4 alpha = tex2D(_PostBlendAlpha, i.uv);
			half
				colDepth = alpha.g,
				mulDepth = mull.a,
				addDepth = add.a;

			half4 c = bg;
			half4 ab = half4(color.rgb/clamp(alpha.r,1e-12,5e12),color.a);
			
			half4 m = c * saturate(mull);
			half4 mb = (1.0-ab.a) * lerp(ab*mull,ab,saturate((colDepth-mulDepth)*0.2)) + ab.a * m;
			
			half4 mba = mb;
			if(addDepth > max(mulDepth,colDepth) )
				mba += add;
			else if(mulDepth > colDepth)
				mba += (1-saturate((mulDepth - addDepth)*0.2)) * add;
			else
				mba = lerp(mba+(1-saturate((colDepth - addDepth)*0.2)) * add,mba,ab.a);
			
			return mba;
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
			
			ENDCG
		}
	}
}
