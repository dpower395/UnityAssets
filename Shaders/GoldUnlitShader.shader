Shader "Unlit/GoldUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _TintColor ("Tint Color", Color) = (1,1,1,1)
        _AmbientTex ("Ambient Texture", 2D) = "white" {}
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
                float2 screenuv : TEXCOORD1;
            };

            sampler2D _MainTex;
            sampler2D _AmbientTex;
            float4 _TintColor;
            float4 _MainTex_ST;
            float4 _AmbientTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _AmbientTex);
                //o.screenuv = ((o.vertex.xy * (o.vertex.y * 4))) * 1;
                o.screenuv = ((o.vertex.xy / o.vertex.w) + o.vertex.w);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //float4 ambient = tex2D(_AmbientTex, (i.screenuv * .2) - 10);
                float4 ambient = tex2D(_AmbientTex, i.screenuv);
                float4 col = ambient * _TintColor;

                return col;
            }
            ENDCG
        }
    }
}
