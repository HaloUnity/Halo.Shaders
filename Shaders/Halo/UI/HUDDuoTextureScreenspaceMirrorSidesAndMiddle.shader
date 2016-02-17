Shader "Custom/UI/HUDDuoTextureScreenspaceMirrorSidesAndMiddle"
{
	//This shader selects between 2 textures and draws them with the y UV
	//in screenspace. It will also duplicate/mirror the otherside too
	//this prevents seams from appearing what should be a multi-texture
	//construct such as the Halo HUD

	Properties
	{
		_Color ("HUD Color", Color) = (1,1,1,1)

		_SideTex ("Side Texture", 2D) = "white" {}
		_SideTexScreenSpaceXCutoff ("Side Tex Screenspace X Cutoff", Float) = 0.5

		_MiddleTex ("Middle Texture", 2D) = "white" {}

	}
	SubShader
	{
		Tags { "RenderType"="Transparent" }
		LOD 100

		Pass
		{
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

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
				float2 screenPos : TEXCOORD0;
				float2 vertUV : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};
			
			fixed4 ComputeHUDColorValue(fixed4 c, fixed4 texColor)
			{
				//HUD textures define green as the intensity controller and alpha as the alpha value
				c = c * texColor.g + c * texColor.b;
				c.a = texColor.a;
				return c;
			}
			
			sampler2D _SideTex;
			float4 _SideTex_ST;

			sampler2D _MiddleTex;
			float4 _MiddleTex_ST;

			fixed4 _Color;
			float _SideTexScreenSpaceXCutoff;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.screenPos = ComputeScreenPos(o.vertex);
				o.vertUV = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//Do UV computations that are based around screenspace position.
				//Use vertex y positions and y offets though, not screenPosition y's, and sample the textures at that point
				fixed4 leftCol = tex2D(_SideTex, float2((i.screenPos.x / _SideTexScreenSpaceXCutoff + _SideTex_ST.z) * _SideTex_ST.x, (i.vertUV.y + _SideTex_ST.w) * _SideTex_ST.y));

				fixed4 leftMidCol = tex2D(_MiddleTex, float2(((i.screenPos.x - _SideTexScreenSpaceXCutoff) / (1 - 2 * _SideTexScreenSpaceXCutoff) * 2 + _MiddleTex_ST.z) * _MiddleTex_ST.x, (i.vertUV.y + _MiddleTex_ST.w) * _MiddleTex_ST.y));

				//Similar to the rightSide UVs. We need to look backwards through the texture
				fixed4 rightMidCol = tex2D(_MiddleTex, float2(((1.0f - i.screenPos.x - _SideTexScreenSpaceXCutoff) / (1 - 2 * _SideTexScreenSpaceXCutoff) * 2 + _MiddleTex_ST.z) * _MiddleTex_ST.x, (i.vertUV.y + _MiddleTex_ST.w) * _MiddleTex_ST.y));

				//Do not try to use boolean logic to select UV coords. I tried that and there seems to be a discontinutiy which causes a seam.
				//Just do a texture lookup even though it's not the cheapest. It's already on the GPU at least though
				//We basically do a backwards look through the texture through screenspace
				fixed4 rightCol = tex2D(_SideTex, float2(((1.0f - i.screenPos.x) / _SideTexScreenSpaceXCutoff + _SideTex_ST.z) * _SideTex_ST.x, (i.vertUV.y + _SideTex_ST.w) * _SideTex_ST.y));

				//Boolean logic hack to select texture colors without branching coniditonals
				fixed texSelector1 = clamp(sign(_SideTexScreenSpaceXCutoff - i.screenPos.x), 0, 1);
				fixed texSelector2 = clamp(sign(i.screenPos.x - _SideTexScreenSpaceXCutoff), 0, 1);

				//We select tex3 by finding the distance in the middle, dividing it by 2 and moving the screenPos to the side by the offet
				//so that it draws all the way to the middle
				fixed texSelector3 = clamp(sign((i.screenPos.x - _SideTexScreenSpaceXCutoff) - (1 - 2 * _SideTexScreenSpaceXCutoff) / 2), 0, 1);

				fixed texSelector4 = clamp(sign(i.screenPos.x - (1 -_SideTexScreenSpaceXCutoff)), 0, 1);

				//We need to do this because both 2 and 3 could be active with this setup
				texSelector2 *= abs(1 - texSelector4); //Don't draw Tex2 when Tex4 is drawing
				texSelector2 *= abs(1 - texSelector3); //Don't draw Tex2 when Tex3 is drawing
				texSelector3 *= abs(1 - texSelector4); //Don't draw Tex3 when Tex4 is drawing

				return ComputeHUDColorValue(_Color, leftCol) * texSelector1
				+ ComputeHUDColorValue(_Color, leftMidCol) * texSelector2 + ComputeHUDColorValue(_Color, rightMidCol) * texSelector3
				+ ComputeHUDColorValue(_Color, rightCol) * texSelector4;
			}
			ENDCG
		}
	}
}
