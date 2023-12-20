Shader "Custom/ColorfulShadowShader"
{
    Properties
    {
        //�����ɏ��������̂�Inspector�ɕ\�������
        _MainColor("MainColor",Color) = (1,1,1,1)
        _ShadowColor("ShadowColor",Color) = (0,0,0,1)
        _ShadowTex("ShadowTexture", 2D) = "white" {}
        _ShadowIntensity ("Shadow Intensity", Range (0, 1)) = 0.6
    }
    SubShader
    {
        CGPROGRAM
        #pragma vertex vert
        #pragma fragment frag
        #include "UnityCG.cginc"
        ENDCG

        Pass
        {
            CGPROGRAM
            //�ϐ��̐錾�@Properties�Œ�`�������O�ƈ�v������
            half4 _MainColor;

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
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //RGBA�ɂ��ꂼ��̃v���p�e�B�𓖂Ă͂߂Ă݂�
                return half4(_MainColor);
            }
            ENDCG
        }

        //�e��h�肱�ރp�X
        Pass
        {
            Tags
            {
                "Queue"="geometry"
                "LightMode" = "ForwardBase"
            }
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma multi_compile_fwdbase
            #include "AutoLight.cginc"

            sampler2D _ShadowTex;
            float4 _ShadowTex_ST;
            float4 _ShadowColor;
            float _ShadowIntensity;

            //�O���[�o���ϐ�
            float _ShadowDistance;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 shadow_uv : TEXCOORD0;
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float2 shadow_uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 worldNormal:NORMAL;
                float3 worldPos : WORLD_POS;
                SHADOW_COORDS(1)
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                TRANSFER_SHADOW(o);
                //�^�C�����O�ƃI�t�Z�b�g�̏���
                o.shadow_uv = TRANSFORM_TEX(v.shadow_uv, _ShadowTex);
                //�@�������̃x�N�g��
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            float4 frag(v2f i) : COLOR
            {
                // �J�����ƃI�u�W�F�N�g�̋���(����)���擾
                // _WorldSpaceCameraPos�F��`�ς̒l�@���[���h���W�n�̃J�����̈ʒu
                float cameraToObjLength = clamp(length(_WorldSpaceCameraPos - i.worldPos), 0, _ShadowDistance);
                //1�ڂ̃��C�g�̃x�N�g���𐳋K��
                float3 L = normalize(_WorldSpaceLightPos0.xyz);
                //���[���h���W�n�̖@���𐳋K��
                float3 N = normalize(i.worldNormal);
                //���ς̌��ʂ�0�ȏ�Ȃ�1 ���̒l���g���ė����̉e�͕`�悵�Ȃ�
                float front = step(0, dot(N, L));
                //�e�̏ꍇ0�A����ȊO��1
                float attenuation = SHADOW_ATTENUATION(i);
                //�e�̌�����
                float fade = 1 - pow(cameraToObjLength / _ShadowDistance, _ShadowDistance);
                //�e�̐F
                float3 shadowColor = tex2D(_ShadowTex, i.shadow_uv) * _ShadowColor;
                //�e�̏ꏊ�Ƃ���ȊO�̏ꏊ��h����
                float4 finalColor = float4(shadowColor, (1 - attenuation) * _ShadowIntensity * front * fade);
                return finalColor;
            }
            ENDCG
        }

        //�e�𗎂Ƃ��������s��Pass
        Pass
        {
            Tags
            {
                "LightMode"="ShadowCaster"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

            struct v2f
            {
                V2F_SHADOW_CASTER;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
}
