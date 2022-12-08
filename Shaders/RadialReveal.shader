Shader "Unlit/RadialReveal"
{
    Properties
    {
        _MainTex1 ("Texture1", 2D) = "white" {}
        _MainTex2 ("Texture2", 2D) = "white" {}
        _RevealAngle ("Reveal Angle", Range(-0.5,1.5)) = 0
        _Feather ("Feather", Range(0,1)) = 0
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

            sampler2D _MainTex1, _MainTex2;
            float4 _MainTex1_ST, _MainTex2_ST;
            float _RevealAngle, _Feather;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex1);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float pi = UNITY_PI;
                fixed4 col1 = tex2D(_MainTex1, i.uv);
                fixed4 col2 = tex2D(_MainTex2, i.uv);

                // Generate an angle between 0 and 1 based on UVs
                float2 newUV = i.uv.xy * 2 - 1;
                float angle = atan2(newUV.y, newUV.x) / pi; // This goes from -1 to 1
                angle = angle * 0.5 + 0.5; // This goes from 0 to 1

                // lerp between 2 textures based on how close _RevealAngle is to angle
                float reveal = smoothstep(angle - _Feather, angle + _Feather, _RevealAngle);
                float4 col = lerp(col1, col2, reveal);
                return col;
            }
            ENDCG
        }
    }
}
