Shader "Custom/HaloEmissionLightFlowGlow" {
	Properties {
		_MainTex ("Albedo Texture", 2D) = "white" {}
		_EmissionMask ("Emission Mask", 2D) = "white" {}
		_EmissionScrollTexture ("Emission Scroll", 2D) = "white" {}
		_ScrollSpeed ("Scrolling Speed", Float) = 1.0

		_EmissionColor ("Emission Color on No Alpha", Color) = (1,1,1,1)
		_EmissionColorTwo ("Emission Color on Alpha", Color) = (1,1,1,1)
		_EmissionLM ("Emission (Lightmapper)", Float) = 0
		[Toggle] _DynamicEmissionLM ("Dynamic Emission (Lightmapper)", Int) = 0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _EmissionScrollTexture;
		sampler2D _MainTex;
		sampler2D _EmissionMask;

		struct Input {
			float2 uv_MainTex;
			float2 uv_EmissionScrollTexture;
		};

		half _EmissionLM;
		half _ScrollSpeed;
		fixed4 _EmissionColor;
		fixed4 _EmissionColorTwo;

		void surf (Input IN, inout SurfaceOutputStandard o) 
		{
			fixed4 emissionScrollTexture = tex2D (_EmissionScrollTexture, IN.uv_EmissionScrollTexture + float2(0, _Time.x * _ScrollSpeed));
			fixed4 emissionMask = tex2D(_EmissionMask, IN.uv_MainTex);

			o.Albedo = tex2D (_MainTex, IN.uv_MainTex).rgb;

			o.Emission = lerp(0, lerp(_EmissionColor, _EmissionColorTwo, emissionScrollTexture.a) * _EmissionLM, emissionMask.a);
		}
		ENDCG
	}
	FallBack "Diffuse"
}
