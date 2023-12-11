Shader "Custom/SimpleDiffuseShader"
{
    Properties
    {
        _MainColor ("Main Color", Color) = (0, 0, 0, 1)
        _DiffuseShade("Diffuse Shade",Range(0,1)) = 0.5
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

            fixed4 _MainColor;
            float _DiffuseShade;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float3 worldNormal:TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //�@�������̃x�N�g��
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //1�ڂ̃��C�g�̃x�N�g���𐳋K��
                float3 L = normalize(_WorldSpaceLightPos0.xyz);
                //���[���h���W�n�̖@���𐳋K��
                float3 N = normalize(i.worldNormal);
                //���C�g�x�N�g���Ɩ@���̓��ς���s�N�Z���̖��邳���v�Z �����o�[�g�̒����������ōs��
                fixed4 diffuseColor = max(0, dot(N, L) * _DiffuseShade + (1 - _DiffuseShade));
                //�F����Z
                fixed4 finalColor = _MainColor * diffuseColor;
                return finalColor;
            }
            ENDCG
        }
    }
}
