Shader "Custom/LocalSliceShader"
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
                float4 pos : SV_POSITION;
                float3 localPos : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o;
                //描画しようとしている頂点(ローカル座標)
                o.localPos = v.vertex.xyz;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //各頂点のローカル座標(Y軸)それぞれに15をかけてfrac関数で少数だけ取り出す
                //そこから-0.5してclip関数で0を下回ったら描画しない
                clip(frac(i.localPos.y * _SliceSpace) - 0.5);
                //RGBAにそれぞれのプロパティを当てはめてみる
                return half4(_Color);
            }
            ENDCG
        }
    }
}
