Shader "Unlit/Disintegrate"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MaskTex ("Texture", 2D) = "white" {}
        _RevealValue ("Reveal", Range(-0.5, 1.5)) = 0.0
        _Feather ("Feather", Range(0.0, 0.4)) = 0.0
        _ErodeColor ("Erode Color", color) = (1,1,1,1)

        [Enum(UnityEngine.Rendering.BlendMode)]
        _SrcFactor("Src Factor", Float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)]
        _DstFactor("Dst Factor", Float) = 10
        [Enum(UnityEngine.Rendering.BlendOp)]
        _Opp("Operation", Float) = 0
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "RenderType"="Transparent" }
        LOD 100
        Blend [_SrcFactor] [_DstFactor]
        BlendOp [_Opp]

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
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _MaskTex;
            float4 _MaskTex_ST;
            float _RevealValue;
            float _Feather;
            float4 _ErodeColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.uv, _MaskTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv.xy);
                fixed4 mask = tex2D(_MaskTex, i.uv.zw);
                //float erosion = smoothstep(mask.r - _Feather, mask.r + _Feather, _RevealValue);
                float maskHigh = step(mask.r, _RevealValue + _Feather);
                float maskLow = step(mask.r, _RevealValue - _Feather);
                float erosion = maskHigh - maskLow;
                float3 finalCol = lerp(col.rgb, _ErodeColor.rgb, erosion);
                return fixed4(finalCol.rgb, col.a * maskHigh);
            }
            ENDCG
        }
    }
}
