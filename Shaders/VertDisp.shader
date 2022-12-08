Shader "Unlit/VertDisp"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                float tex = tex2Dlod(_MainTex, float4(o.uv, 0, 1));
                tex = tex * 2 - 1;
                o.uv.x = sin(tex * 5 - _Time.y);

                v.vertex.z = o.uv.x * 0.0008;
                o.uv.x = o.uv.x * 0.5 + 0.25;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = fixed4(i.uv.x,0,0,1);
                return col;
            }
            ENDCG
        }
    }
}
