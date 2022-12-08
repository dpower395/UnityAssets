Shader "Unlit/Spiral"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NoiseTex ("Noise", 2D) = "white" {}
        _Tint ("Tint", color) = (0,0,0,1)
        _Rotate ("Rotate", Range(0.0, 2.0)) = 0.0
        _Noise ("Noise", Range(0.0, 2.0)) = 0.0
        _NoiseRotation ("Noise Rotation", Range(0.0, 2.0)) = 0.0
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
                float2 polarUV : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NoiseTex;
            float4 _Tint;
            float _Rotate;
            float _Noise;
            float _NoiseRotation;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.polarUV = float2(0,0);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Need to do reverse polar coordinate transformation
                // Don't think about it as "where you are" on the texture
                // Think about it as "If radius changes, x changes and y stays the same. If angle changes, y changes and x stays the same."
                float pi = 3.14;
                float2 center = float2(0.5, 0.5);
                float radius = length((i.uv.xy - center));
                float angle = atan2(i.uv.y - center.x, i.uv.x - center.y) * 4;
                i.polarUV = float2(radius, angle / pi);

                fixed4 noise = tex2D(_MainTex, i.polarUV + (_Rotate * _NoiseRotation));
                fixed4 col = tex2D(_MainTex, i.polarUV + _Rotate + (noise * _Noise));
                
                return col * _Tint;
            }
            ENDCG
        }
    }
}