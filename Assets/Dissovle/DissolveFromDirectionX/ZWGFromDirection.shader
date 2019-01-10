Shader "WG/Dissolve/ZWGFromDirection"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Direction("Direction", Int) = 1 //1表示从X正方向开始，其他值则从负方向
		_MinBorderX("Min Border X", Float) = -0.5 //从程序传入
		_MaxBorderX("Max Border X", Float) = 0.5  //从程序传入
		_Threshold("Threshold", Range(0.0, 1.0)) = 0
		_NoiseTex("Noise", 2D) = "white" {}
		_DistanceEffect("Distance Effect", Range(0.0, 1.0)) = 0.5
		_EdgeWidth("Edge Width",Float) = 0.2
		_EdgeRampTex("Edge Ramp Tex",2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

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
				float objPosX : TEXCOORD1; 
				float2 uvNoiseTex : TEXCOORD2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Direction;
			float _MinBorderX;
			float _MaxBorderX;
			float _Threshold;
			sampler2D _NoiseTex;
			float4 _NoiseTex_ST; 
			float _DistanceEffect;
			float _EdgeWidth;
			sampler2D _EdgeRampTex;
			sampler2D _EdgeRampTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uvNoiseTex = TRANSFORM_TEX(v.uv, _NoiseTex);
				o.objPosX = v.vertex.x;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{

				float startPointX = lerp(_MinBorderX,_MaxBorderX,step(1,_Direction));
				float range = _MaxBorderX - _MinBorderX;
				float degree = saturate(abs((i.objPosX - startPointX)/range));
				degree = tex2D(_NoiseTex, i.uvNoiseTex).r*(1-_DistanceEffect) + degree*_DistanceEffect;
				clip(degree - _Threshold);

				float edgeDegree = saturate((degree - _Threshold)/_EdgeWidth);
				fixed4 col = lerp(tex2D(_EdgeRampTex, float2(edgeDegree,edgeDegree)),tex2D(_MainTex, i.uv),step(_EdgeWidth,degree-_Threshold));
				return col;
			}
			ENDCG
		}
	}
}
