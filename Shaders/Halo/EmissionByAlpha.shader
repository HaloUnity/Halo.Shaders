Shader "Custom/EmissionByAlpha" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_EmissionTex ("Emission Texture", 2D) = "white" {}

		_EmissionLM ("Emission (Lightmapper)", Float) = 0
		[Toggle] _DynamicEmissionLM ("Dynamic Emission (Lightmapper)", Int) = 0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		//Blend SrcAlpha OneMinusSrcAlpha
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _EmissionTex;

		struct Input {
			float2 uv_EmissionTex;
		};

		half _EmissionLM;
		fixed4 _Color;

		void surf (Input IN, inout SurfaceOutputStandard o) 
		{
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_EmissionTex, IN.uv_EmissionTex);

			o.Albedo = c;

			o.Emission = lerp(_Color * _EmissionLM, 0, c.a);
		}
		ENDCG
	} 
	Fallback "Diffuse"
}
