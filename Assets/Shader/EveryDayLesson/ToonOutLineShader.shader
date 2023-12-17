Shader "Custom/ToonOutLineShader"
{
    Properties
    {
        _MainTexture ("Main Texture", 2D) = "white" {}
        _ShadowTexture ("Shadow Texture", 2D) = "white" {}
        _ShadowStrength("Shadow Strength",Range(0,1)) = 0.5
        _OutlineWidth ("Outline width", Range (0.005, 0.03)) = 0.01
        [HDR]_OutlineColor ("Outline Color", Color) = (0,0,0,1)
        [Toggle(USE_VERTEX_EXPANSION)] _UseVertexExpansion("Use vertex for Outline", int) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        UsePass "Custom/ToonLitShader/TOON"

        Pass
        {
            Cull Front

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #pragma shader_feature USE_VERTEX_EXPANSION

            #include "UnityCG.cginc"

            float _OutlineWidth;
            float4 _OutlineColor;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                float3 n = 0;

                #ifdef USE_VERTEX_EXPANSION //モデルの頂点方向に拡大するパターン
                
                //モデルの原点からみた各頂点の位置ベクトルを計算
                float3 dir = normalize(v.vertex.xyz);
                //UNITY_MATRIX_IT_MVはモデルビュー行列の逆行列の転置行列
                //各頂点の位置ベクトルをモデル座標系からビュー座標系に変換し正規化
                n = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, dir));
                
                #else //モデルの法線方向に拡大するパターン
                
                //法線をモデル座標系からビュー座標系に変換し正規化
                n = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, v.normal));
                
                #endif

                //ビュー座標系に変換した法線を投影座標系に変換　
                //アウトラインとして描画予定であるピクセルのXY方向のオフセット
                float2 offset = TransformViewToProjection(n.xy);
                o.pos.xy += offset * _OutlineWidth;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return _OutlineColor;
            }
            ENDCG
        }
    }
}
