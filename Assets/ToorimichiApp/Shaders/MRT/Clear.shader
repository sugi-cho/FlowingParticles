Shader "Unlit/Clear"
{
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
			float4 vis : SV_Target0;
			float4 kage : SV_Target1;
		};
		
		uniform sampler2D _CameraKage,_KageTex,_Canvas;
		
		v2f vert (appdata v)
		{
			v2f o;
			o.vertex = v.vertex;
			o.uv = (v.vertex.xy/v.vertex.w+1.0)*0.5;
			return o;
		}
		
		pOut frag (v2f i)
		{
			pOut o;
			o.vis = 0;
			o.kage = -tex2D(_CameraKage, i.uv)*3.0;
			return o;
		}
	ENDCG
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

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
