Shader "Custom/ToonLitShader"
{
    Properties
    {
        _MainTexture ("Main Texture", 2D) = "white" {}
        _ShadowTexture ("Shadow Texture", 2D) = "white" {}
        _ShadowStrength("Shadow Strength",Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Name "TOON"
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            sampler2D _MainTexture;
            sampler2D _ShadowTexture;
            float _ShadowStrength;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD1;
                UNITY_FOG_COORDS(1)
                float3 worldNormal : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //�@�������̃x�N�g��
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //1�ڂ̃��C�g�̃x�N�g���𐳋K��
                float3 l = normalize(_WorldSpaceLightPos0.xyz);
                //���[���h���W�n�̖@���𐳋K��
                float3 n = normalize(i.worldNormal);
                //���ς�Lerp�̕�Ԓl���v�Z�@0�ȉ��̏ꍇ�̂ݕ�Ԓl�𗘗p����
                float interpolation = step(dot(n, l),0);
                //��Βl�Ő����ɂ��邱�Ƃŉe�̗̈��h������
                float2 absD = abs(dot(n, l));
                //�e�̗̈�̃e�N�X�`�����T���v�����O
                float3 shadowColor = tex2D(_ShadowTexture, absD).rgb;
                //���C���̃e�N�X�`�����T���v�����O
                float3 mainColor = tex2D(_MainTexture, i.uv).rgb;
                //��Ԓl��p���ĐF��h�����@�e�̋���(�e�e�N�X�`���[�̔Z��)�������Œ���
                float3 finalColor = lerp(mainColor, shadowColor * (1 - _ShadowStrength) * mainColor,interpolation);
                return float4(finalColor,1);
            }
            ENDCG
        }
    }
}
