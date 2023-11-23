Shader "Custom/WorldSliceShader"
{
    Properties
    {
        //ここに書いたものがInspectorに表示される
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

            //変数の宣言　Propertiesで定義した名前と一致させる
            half4 _Color;
            half _SliceSpace;

            struct v2f
            {
                UNITY_FOG_COORDS(1)
                //こいつ(pos)には3D→2D(スクリーン)座標変換された後の頂点座標をいれるぜ！ってGPUに教える
                float4 pos : SV_POSITION;
                //こいつ(worldPos)にはワールド座標をいれるぜ！ってGPUに教える
                float3 worldPos : WORLD_POS;
            };

            v2f vert (appdata v)
            {
                v2f o;
                //unity_ObjectToWorld × 頂点座標(v.vertex) = 頂点のワールド座標　らしい
                //mulは行列の掛け算をやってくれる関数
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //各頂点のワールド座標(Y軸)それぞれに15をかけてfrac関数で少数だけ取り出す
                //そこから-0.5してclip関数に渡す　0を下回ったら描画しない
                clip(frac(i.worldPos.y * _SliceSpace) - 0.5);
                //RGBAにそれぞれのプロパティを当てはめてみる
                return half4(_Color);
            }
            ENDCG
        }
    }
}
