Shader "Custom/StandardHaloShaderWithAlphaAsSpecular" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_BumpMap ("Bumpmap", 2D) = "bump" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _BumpMap;

		struct Input {
			float2 uv_MainTex;
			float2 uv_BumpMap;
		};

		fixed4 _Color;

		void surf (Input IN, inout SurfaceOutputStandard o) 
		{
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;

			o.Albedo = c.rgb;

			fixed4 normalTexMap = tex2D(_BumpMap, IN.uv_BumpMap);
			o.Normal = UnpackNormal(normalTexMap);

			//invert normals
			o.Normal = float3(o.Normal.x * -1, o.Normal.y * -1, o.Normal.z);

			//This is the best looking smoothness I could come up with from the alpha channel of the albedos from Halo3
			//It turns the roughness into smoothness and then reduces it a bit while adding in a constant 0.1f
			//The constant is nice because it adds nicely to the SSRR/Reflections of the scene
			//Clamp to avoid specular artifacts
			o.Smoothness = clamp((1 - c.a) * 0.6f + 0.1f, 0, 0.9f); //(1 - c.a);
		}
		ENDCG
	}
	FallBack "Diffuse"
}
