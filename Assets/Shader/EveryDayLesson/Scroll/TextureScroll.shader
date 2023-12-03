Shader "Custom/TextureScroll"
{
    Properties
    {
        //スクロールさせるテクスチャ
        _MainTex ("Texture", 2D) = "white" {}
        //色
        _Color("MainColor",Color) = (0,0,0,0)
        //スライスされる間隔
        _SliceSpace("SliceSpace",Range(0,30)) = 15
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
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float3 localPos : TEXCOORD0;
                float2 uv : TEXCOORD1;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            half4 _Color;
            half _SliceSpace;

            v2f vert (appdata v)
            {
                v2f o;
                //描画しようとしている頂点(ローカル座標)
                o.localPos = v.vertex.xyz;
                o.uv = v.uv + _Time;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //頂点の色を計算
                fixed4 col = tex2D(_MainTex, i.uv);
                //各頂点のローカル座標(Y軸)それぞれに15をかけてfrac関数で少数だけ取り出す
                //そこから-0.5してclip関数で0を下回ったら描画しない
                clip(frac(i.localPos.y * _SliceSpace) - 0.5);
                //計算した色とプロパティで設定した色を乗算する
                return half4(col * _Color);
            }
            ENDCG
        }
    }
}
