Shader "Unlit/WaterDepth"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _CausticTex("Texture", 2D) = "white" {}
        _DisplaceTex("Displacement Texture", 2D) = "white" {}
        _Magnitude("Magnitude", Range(0,0.1)) = 0.1
        _TintColor("Tint Color", Color) = (0,0,0,1)
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
                float2 screenuv: TEXCOORD1;
            };

            sampler2D _MainTex;
            sampler2D _DisplaceTex;
            sampler2D _CausticTex;
            float4 _MainTex_ST;
            float4 _TintColor;
            float _Magnitude;

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

                fixed4 colCaustic = tex2D(_CausticTex, i.uv + disp);
                fixed4 colMain = tex2D(_MainTex, i.uv + (disp * 0.2));
                fixed4 col = (colCaustic + colMain) * _TintColor;
                return col;
            }
            ENDCG
        }
    }
}
