Shader "WG/Dissolve/ZWGTrifox"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_NoiseTex("Noise", 2D) = "gray" {}		
		_PlayerPos("Player Pos", Vector) = (0,0,0,0)
		_CutOutWidth("Cut Out Width",Range(0,2)) = 0.2

		_Effect("Effect",Range(0,1)) = 0.5
		_NotiseEffect("NotiseEffect",Range(0,1)) = 0.5
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
				float3 worldPos : TEXCOORD1;
			};

			sampler2D _MainTex;
			sampler2D _NoiseTex;
			float4 _PlayerPos;
			float _CutOutWidth;
			float _Effect;
			float _NotiseEffect;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP,v.vertex);//UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.worldPos = mul(_Object2World, v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float toCamera = distance(i.worldPos, _WorldSpaceCameraPos.xyz);
				float playerToCamera = distance(_PlayerPos.xyz, _WorldSpaceCameraPos.xyz);
				float gradient = tex2D(_NoiseTex, i.uv).r;
				float degree = saturate(toCamera*_CutOutWidth/playerToCamera);
				degree = (gradient-_NotiseEffect)*(1-_Effect) + (degree - 1)*_Effect;
				clip(degree);

				return tex2D(_MainTex, i.uv);
			}
			ENDCG
		}
	}
}
