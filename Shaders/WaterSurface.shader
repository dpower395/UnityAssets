Shader "Unlit/WaterSurface"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Caustic("Caustic", 2D) = "white" {}
        _DisplaceTex("Displacement Texture", 2D) = "white" {}
        _Magnitude("Magnitude", Range(0,0.1)) = 0.1
    }
    SubShader
    {
        Tags { "Queue"="Transparent+10" "RenderType"="Opaque" }
        LOD 100

        // Grabs the camera's render texture
        GrabPass { "_GrabTexture" }

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
                float2 screenuv: TEXCOORD1;
            };

            sampler2D _MainTex;
            sampler2D _DisplaceTex;
            sampler2D _GrabTexture;
            sampler2D _Caustic;
            float _Magnitude;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.screenuv = ((o.vertex.xy / o.vertex.w) + 1) * 0.5;
                o.screenuv.y = 1 - o.screenuv.y;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 disp = tex2D(_DisplaceTex, i.uv - (_Time.x * 2)).xy;
                disp = ((disp * 2) - 1) * _Magnitude;
                disp.x += .04;

                float4 col = tex2D(_GrabTexture, i.screenuv);
                col += (tex2D(_Caustic, i.uv + disp)) * 0.4;
                return col;
            }
            ENDCG
        }
    }
}
