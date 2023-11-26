Shader "Custom/MouseClickReceiveShader"
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
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 worldPos : WORLD_POS;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            //C#側でいじる変数
            float4 _MousePosition;

            v2f vert (appdata v)
            {
                v2f o;
                //3D空間座標→スクリーン座標変換
                o.vertex = UnityObjectToClipPos(v.vertex);
                //描画したいピクセルのワールド座標を計算
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //ベースカラー　白
                float4 baseColor = (1,1,1,1);
                
                /*"マウスから出たRayとオブジェクトの衝突箇所(ワールド座標)"と
                 　"描画しようとしているピクセルのワールド座標"の距離を求める*/
                float dist = distance( _MousePosition, i.worldPos);
                
                //求めた距離が任意の距離以下なら描画しようとしているピクセルの色を変える
                if( dist < 0.05)
                {
                    //赤色乗算代入
                    baseColor *= float4(1,0,0,0);
                }
                
                return baseColor;
            }
            ENDCG
        }
    }
}
