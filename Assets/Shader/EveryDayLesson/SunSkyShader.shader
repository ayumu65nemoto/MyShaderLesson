Shader "Custom/SunSkyShader"
{
    Properties
    {
        _BGColor ("Background Color", Color) = (0.05, 0.9, 1, 1)
        _SunColor ("Color", Color) = (1, 0.8, 0.5, 1)
        _SunDir ("Sun Direction", Vector) = (0, 0.5, 1, 0)
        _SunStrength("Sun Strengh", Range(0, 200)) = 30
    }
    SubShader
    {
        Tags 
        { 
            "RenderType"="Background" //最背面に描画するのでBackground
            "Queue"="Background" //最背面に描画するのでBackground
            "PreviewType"="SkyBox" //設定すればマテリアルのプレビューがスカイボックスになるらしい
        }
        LOD 100

        Pass
        {
            ZWrite Off //常に最背面に描画するので深度情報の書き込み不要

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            fixed3 _BGColor;
            fixed3 _SunColor;
            float3 _SunDir;
            float _SunStrength;

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
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 dir = normalize(_SunDir); //太陽の位置ベクトル正規化
                float angle = dot(dir, i.uv); //太陽の位置ベクトル　と　描画されるピクセルの位置ベクトル　の内積
                //pow(x,y)はxをy乗する　
                //0 < max(0, angle) < 1 なので　_SunStrengthを大きくするほど計算結果は0に近づく
                fixed3 c = _BGColor + _SunColor * pow(max(0, angle), _SunStrength);
                return fixed4(c, 1);
            }
            ENDCG
        }
    }
}
