Shader "Custom/ControlTextureTwoChannelRG" {
	Properties {
		_ControlTexture ("Control Splat", 2D) = "white" {}

		_TextureForGreenChannel ("Green Channel Texture", 2D) = "white" {}
		_NormalMapForGreen ("Green Normal Map", 2D) = "bump"
		_NormalGreenIntensity ("Green Normal Map Intensity", Float) = 1

		_TextureForRedChannel ("Red Channel Texture", 2D) = "white" {}
		_NormalMapForRed ("Red Normal Map", 2D) = "bump"
		_NormalRedIntensity ("Red Normal Map Intensity", Float) = 1
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _ControlTexture;
		sampler2D _TextureForGreenChannel;
		sampler2D _TextureForRedChannel;
		sampler2D _NormalMapForGreen;
		sampler2D _NormalMapForRed;

		struct Input 
		{
			float2 uv_ControlTexture;
			float2 uv_TextureForGreenChannel;
			float2 uv_TextureForRedChannel;
		};

		half _NormalRedIntensity;
		half _NormalGreenIntensity;

		void surf (Input IN, inout SurfaceOutputStandard o) 
		{
			fixed4 controlTex = tex2D(_ControlTexture, IN.uv_ControlTexture);

			o.Albedo = lerp(0, tex2D(_TextureForRedChannel, IN.uv_TextureForRedChannel), controlTex.r);
			o.Albedo += lerp(0, tex2D(_TextureForGreenChannel, IN.uv_TextureForGreenChannel), controlTex.g);

			float3 normalGreen = UnpackNormal(tex2D(_NormalMapForGreen, IN.uv_TextureForGreenChannel));
			float3 normalRed = UnpackNormal(tex2D(_NormalMapForRed, IN.uv_TextureForRedChannel));

			normalGreen = float3(normalGreen.x * _NormalGreenIntensity, normalGreen.y * _NormalGreenIntensity, normalGreen.z);
			normalRed = float3(normalRed.x * _NormalRedIntensity, normalRed.y * _NormalRedIntensity, normalRed.z);

			normalGreen = lerp(0, normalGreen, controlTex.g);
			normalRed = lerp(0, normalRed, controlTex.r);

			o.Normal = normalize(normalGreen + normalRed);
			//o.Normal = normalize(lerp(normalGreen, normalRed, controlTex.r));
			//o.Normal = lerp(0, UnpackNormal(tex2D(_NormalMapForGreen, IN.uv_TextureForGreenChannel)), controlTex.g);
		}
		ENDCG
	}
	FallBack "Diffuse"
}
