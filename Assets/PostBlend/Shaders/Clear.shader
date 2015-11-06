Shader "Unlit/Clear"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
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
			float4 vertex : SV_POSITION;
		};
		
		struct pOut
		{
			half4 blendColor : SV_Target0;
			half4 blendAlpha : SV_Target1;
			half4 mull : SV_Target2;
			half4 add : SV_Target3;
		};

		sampler2D _MainTex,_GrabTexture;
		float4 _MainTex_ST;
		
		v2f vert (appdata v)
		{
			v2f o;
			o.vertex = v.vertex;
			return o;
		}
		
		pOut frag (v2f i)
		{
			pOut o;
			o.blendColor = half4(0,0,0,1);
			o.blendAlpha = half4(0,0,0,1);
			o.mull = half4(1,1,1,0);
			o.add = half4(0,0,0,0);
			return o;
		}
	ENDCG
	
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		ZTest Always
		LOD 100
		
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			ENDCG
		}
	}
}
