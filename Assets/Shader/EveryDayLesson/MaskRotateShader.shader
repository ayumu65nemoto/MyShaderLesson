Shader "Custom/MaskRotateShader"
{
    Properties
    {
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
        //Mask用テクスチャ―
        [NoScaleOffset] _MaskTex ("Mask Texture (RGB)", 2D) = "white" {}
        //回転の速度
        _RotateSpeed ("Rotate Speed", float) = 1.0
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
                float2 uv1 : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
            };

            struct v2f
            {
                float2 uv1 : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _MaskTex;
            fixed _RotateSpeed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv1 = v.uv1;
                o.uv2 = v.uv2;
                //UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //Timeを入力として現在の回転角度を作る
                half timer = _Time.x;
                //回転行列を作る
                half angleCos = cos(timer * _RotateSpeed);
                half angleSin = sin(timer * _RotateSpeed);
                half2x2 rotateMatrix = half2x2(angleCos, -angleSin, angleSin, angleCos);
                //中心合わせ
                half2 uv1 = i.uv1 - 0.5;
                //中心を起点にメインテクスチャのUVを回転させる
                i.uv1 = mul(uv1, rotateMatrix) + 0.5;
                //マスク用画像のピクセルの色を計算
                fixed4 mask = tex2D(_MaskTex, i.uv2);
                //引数の値が”０以下なら”描画しない　すなわち”Alphaが0.5以下なら”描画しない
                clip(mask.a - 0.5);
                //メインテクスチャの色を取得
                fixed4 col = tex2D(_MainTex, i.uv1);
                //メイン画像とマスク画像のピクセルの計算結果をかけ合わせる
                return col * mask;
            }
            ENDCG
        }
    }
}
