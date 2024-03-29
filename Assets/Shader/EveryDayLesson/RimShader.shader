Shader "Custom/RimShader"
{
    Properties
    {
        _TintColor("Tint Color", Color) = (0,0.5,1,1)
        _RimColor("Rim Color", Color) = (0,1,1,1)
        _RimPower("Rim Power", Range(0,1)) = 0.4
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 100
        Cull Back
        //ZWrite On
        //ColorMask 0

        Pass
        {
            //ZWrite On
            //ColorMask 0

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            float4 _TintColor;
            float4 _RimColor;
            float _RimPower;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 world_pos : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.world_pos = mul(unity_ObjectToWorld, v.vertex).xyz;
                //法線を取得
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //カメラのベクトルを計算
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.world_pos.xyz);
                //法線とカメラのベクトルの内積を計算し、補間値を算出
                half rim = 1.0 - saturate(dot(viewDirection, i.normalDir));
                //補間値で塗分け
                float4 col = lerp(_TintColor, _RimColor, rim * _RimPower);
                return col;
            }
            ENDCG
        }
    }
}
