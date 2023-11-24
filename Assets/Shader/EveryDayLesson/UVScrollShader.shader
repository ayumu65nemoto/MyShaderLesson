Shader "Custom/UVScrollShader"
{
    Properties
    {
        //色
        _Color("MainColor",Color) = (0,0,0,0)
        //スライスされる間隔
        _SliceSpace("SliceSpace",Range(0,30)) = 15
        // 時間による色の変化の速さ
        _ColorChangeSpeed("ColorChangeSpeed", Range(0, 10)) = 1
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

            //変数の宣言　Propertiesで定義した名前と一致させる
            half4 _Color;
            half _SliceSpace;
            half _ColorChangeSpeed;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                //UVスクロール
                o.uv = v.uv + _Time.y / 2 ;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //各頂点のUV座標(Y軸)それぞれに15をかけてfrac関数で少数だけ取り出す
                //そこから-0.5してclip関数で0を下回ったら描画しない
                clip(frac(i.uv.y * _SliceSpace) - 0.5);
                
                // 時間による色の変化を計算
                half timeColor = sin(_Time.y * _ColorChangeSpeed) * 0.5 + 0.5;

                // プロパティで設定した色と時間による変化を乗算して返す
                return half4(_Color.r * timeColor, _Color.g * (timeColor / 2), _Color.b, _Color.a);
            }
            ENDCG
        }
    }
}
