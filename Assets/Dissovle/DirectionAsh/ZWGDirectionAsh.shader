Shader "WG/Dissolve/ZWGDirectionAsh"
{
	Properties
	{
		[NoScaleOffset]_MainTex ("Texture", 2D) = "white" {}
		[NoScaleOffset] _WhiteNoiseTex("White Noise", 2D) = "white" {}
		_MaxY ("Max Y" , Float) = 0
		_MinY ("Min Y" , Float) = 0
		[NoScaleOffset]_NoiseTex("Noise", 2D) = "white" {}
		_DistanceEffect("Distance Effect", Range(0.0, 1.0)) = 0.5
		[NoScaleOffset]_RampTex("Border Ramp", 2D) = "white" {}
		_EdgeWidth("Edge Width", Range(0.001, 0.2)) = 0.1
		_AshColor("Ash Color", Color) = (1,1,1,1)
		_AshWidth("Ash Width",Range(0,0.5)) = 0
		_AshDensity("Ash Density", Range(0, 1)) = 1
		_Threshold("Threshold",Range(0,1)) = 0.1
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
				float4 objPosY : TEXCOORD1;
				float2 noiseTexuv : TEXCOORD2;
				float2 whiteNoiseTexuv : TEXCOORD3;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _MinY;
			float _MaxY;
			float _AshWidth;
			float _Threshold;
			sampler2D _RampTex;
			float _RampTex_ST;
			float _EdgeWidth;
			sampler2D _NoiseTex;
			float4 _NoiseTex_ST;
			float _DistanceEffect;
			sampler2D _WhiteNoiseTex;
			float4 _WhiteNoiseTex_ST;
			float _AshDensity;
			float4 _AshColor;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.objPosY = v.vertex.y;

				float degree = saturate(_Threshold - (_MaxY-o.objPosY)/(_MaxY-_MinY));
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex) + float4(degree*2,0,0,0);

				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.noiseTexuv = TRANSFORM_TEX(v.uv, _NoiseTex);
				o.whiteNoiseTexuv = TRANSFORM_TEX(v.uv, _WhiteNoiseTex);
				o.objPosY = v.vertex.y;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{ 
				
				float degree = saturate((_MaxY-i.objPosY)/(_MaxY-_MinY));

				degree = tex2D(_NoiseTex,i.noiseTexuv).r*(1-_DistanceEffect) + _DistanceEffect*degree;

				clip(degree - _Threshold + _AshWidth);

				fixed4 col = tex2D(_MainTex, i.uv);

				float edgeEegree = 1 - saturate((degree-_Threshold)/_EdgeWidth);
				// 边缘颜色
				col = lerp(tex2D(_RampTex, float2(edgeEegree,edgeEegree)),col,step(_EdgeWidth,degree - _Threshold));

				if ((1-edgeEegree) < 0.001){
					clip(tex2D(_WhiteNoiseTex, i.uv).r * _AshDensity - _Threshold*0.7); //灰烬处用白噪声来进行碎片化
					col = _AshColor;
				}

				return col;
			}
			ENDCG
		}
	}
}
