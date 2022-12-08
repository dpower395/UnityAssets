Shader "Unlit/Lava"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _DistortionTex ("Distortion Texture", 2D) = "white" {}
        _HeatTex ("Heat Texture", 2D) = "white" {}
        _DistStrength ("Distortion Strength", Range(0.0, 0.05)) = 0.0
        _Animation ("Animation", Range(0.0, 1.0)) = 0.0
        _HeatStrength ("Heat Strength", Range(1.0, 2.0)) = 1.0
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
                float4 uv : TEXCOORD0;
                float2 heatUV : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex, _DistortionTex, _HeatTex;
            float4 _MainTex_ST, _DistortionTex_ST, _HeatTex_ST;
            float _DistStrength, _Animation, _HeatStrength;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.uv, _DistortionTex);
                o.heatUV = TRANSFORM_TEX(v.uv, _HeatTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 dist = tex2D(_DistortionTex, i.uv.zw + _Animation);
                // The [* 2 - 1] stops dist from moving to corner as strength increases
                // _MainTex UVs can be pushed in any direction, not just up-right
                dist = (dist * 2 - 1);

                // Sample the cloudy texture to get heat brightness effect
                float heat = tex2D(_HeatTex, i.heatUV) * 2 - 1;
                heat = sin(heat + _Animation * 10) + 2;

                fixed4 col = tex2D(_MainTex, i.uv.xy + dist.rg * _DistStrength);
                //col = pow(col, _HeatStrength) * (heat + 1);
                col = pow(col * heat, _HeatStrength);
                return col;
            }
            ENDCG
        }
    }
}
