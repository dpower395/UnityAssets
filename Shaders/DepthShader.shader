Shader "Unlit/DepthShader"
{
    Properties
    {
        _FresnelTex ("Fresnel Texture", 2D) = "white" {}
        _FresnelTint ("Fresnel Tint", color) = (1,1,1,1)
        _ColorOne ("Color One", color) = (1,1,1,1)
        _ColorTwo ("Color Two", color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            // This program does not require a post effects script attached to the camera to work
            // May need to adjust clipping planes of the main camera
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float2 screenSpace : TEXCOORD1;
                float3 normal : TEXCOORD2;
                float3 viewDir : TEXCOORD3;
            };

            sampler2D _FresnelTex;
            sampler2D _CameraDepthTexture;
            float4 _FresnelTex_ST;
            float4 _ColorOne;
            float4 _ColorTwo;
            float4 _FresnelTint;

            v2f vert (appdata v)
            {
                // Normal stuff
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _FresnelTex);
                o.uv.x += _Time.y;

                // Calculate where the object is on screen, so we can pass that into depth function
                // could also use o.screenSpace = ComputeScreenPos(o.vertex);
                    // would need this line in frag though: float2 screenSpaceUV = i.screenSpace.xy / i.screenSpace.w;
                o.screenSpace.xy = ((o.vertex.xy / o.vertex.w) + 1) * 0.5;
                o.screenSpace.y = 1 - o.screenSpace.y;

                // These two are for the fresnel effect
                    // used to use this, don't see a difference: o.normal = UnityObjectToWorldNormal(v.normal);
                o.normal = v.normal;
                o.viewDir = normalize(WorldSpaceViewDir(v.vertex)); // normal vector corresponding to camera direction
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Get the depth values of objects at the screen space coordinates
                float depth = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.screenSpace.xy));
                // Interpolate between two colors based on the value of depth
                float3 mixedColor = lerp(_ColorOne, _ColorTwo, depth);
                
                // High(Low) values of fresnel = object's normal pointing away(towards) from camera
                float fresnel = 1 - dot(i.viewDir, i.normal);

                // Interpolate between the depth color and the fresnel texture based on the value of fresnel
                fixed4 col = tex2D(_FresnelTex, i.uv);
                float3 finalColor = lerp(mixedColor, col + _FresnelTint, fresnel * fresnel * 1.2); // squaring makes it look better
                return fixed4(finalColor,1);
            }
            ENDCG
        }
    }
}
