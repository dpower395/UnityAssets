Shader "Unlit/SapphireShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _AmbientTex ("Ambient Texture", 2D) = "white" {}
        _TintColor("Tint Color", Color) = (1,1,1,1)
        _Transparency("Transparency", Range(0.0,0.75)) = 0.25
    }
    SubShader
    {
        Tags { "Queue"="Transparent+10" "RenderType"="Transparent" }
        LOD 100
        
        ZWrite Off
        // This gives cooler transparency
        Blend SrcAlpha SrcColor

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
                // Should look up what TexCoord1 is
                float2 screenuv : TEXCOORD1;
            };

            sampler2D _MainTex;
            sampler2D _AmbientTex;
            float4 _TintColor;
            float _Transparency;

            // These are required for tiling / offset
            float4 _MainTex_ST;
            float4 _AmbientTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                // Required for tiling / offset
                o.uv = TRANSFORM_TEX(v.uv, _AmbientTex);
                
                // Causes the ambient texture to change based on the camera
                // o.vertex.x * _ adjusts strength of 'internal reflection'
                o.screenuv = ((o.vertex.xy / o.vertex.w) + o.vertex.w);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Texture on outside of emerald, 'i.uv * _' controls tiling
                float4 main = tex2D(_MainTex, i.uv * .5);
                // Texture on inside of emerald, 'i.uv * _' controls tiling
                float4 ambient = tex2D(_AmbientTex, i.screenuv * 3);

                float4 col = main + ambient + _TintColor;

                col.a = _Transparency;

                return col;
            }
            ENDCG
        }
    }
}
