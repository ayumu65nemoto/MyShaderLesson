Shader "Unlit/GradationShader"
{
    Properties
    {
        _Color1("Color_1" , Color) = (1,1,1,1)
        _Color2("Color_2" , Color) = (1,1,1,1)
        _Color3("Color_3" , Color) = (1,1,1,1)
        _Color4("Color_4" , Color) = (1,1,1,1)
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
            };

            float4 _Color1;
            float4 _Color2;
            float4 _Color3;
            float4 _Color4;

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
                fixed4 x_col = lerp(_Color1, _Color2, i.uv.x);
                fixed4 y_col = lerp(_Color3, _Color4, i.uv.y);
                return lerp(x_col, y_col, 0.5);
            }
            ENDCG
        }
    }
}
