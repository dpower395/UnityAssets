Shader "Unlit/HueShift"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _HueShiftTex ("Hue Shift Texture", 2D) = "white" {}
        _HueShift ("Hue Shift", Range(0,10)) = 0
        _Saturation ("Saturation", Range(0,5)) = 0
        _Brightness ("Brightness", Range(-1,1)) = 0
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
            };

            sampler2D _MainTex, _HueShiftTex;
            float4 _MainTex_ST, _HueShiftTex_ST;
            float _HueShift, _Saturation, _Brightness;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float3 HueShift(float3 color, float hueShift)
            {
                // Matrix to take RGB to YIQ
                float3x3 RGB_YIQ =
                    float3x3 (0.299, 0.587, 0.114,
                              0.5959, -0.275, -0.3213,
                              0.2115, -0.5227, 0.3112);
                // Matrix to take YIQ to RGB
                float3x3 YIQ_RGB =
                    float3x3 (1, 0.956, 0.619,
                              1, -0.272, -0.647,
                              1, -1.106, 1.702);

                // Grab YIQ values
                float Y, I, Q;
                float3(Y, I, Q) = mul(RGB_YIQ, color);

                // Find hue and saturation from YIQ, add shifts
                float hue = atan2(Q, I) + hueShift; // Find the angle of the hue on the YIQ graph, add shift
                float chroma = length(float2(I, Q)) + _Saturation; // Find radius of hue on YIQ graph (saturation), add shift

                // Get the new YIQ values, convert back to RGB
                Y = Y + _Brightness;
                I = chroma * cos(hue);
                Q = chroma * sin(hue);
                float3 newRGB = mul(YIQ_RGB, float3(Y,I,Q));
                
                return newRGB;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 hue = tex2D(_HueShiftTex, i.uv);
                col.rgb = HueShift(col.rgb, _HueShift + hue.r);
                return col;
            }
            ENDCG
        }
    }
}
