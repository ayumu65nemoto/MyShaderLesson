Shader "Custom/HexFloorShader"
{
    Properties
    {
        [HDR]_MainColor("MainColor", Color) = (1, 1, 1, 1)
        _RepeatFactor ("RepeatFactor", Range(0,10000)) = 50
        _DistanceInterpolation ("DistanceInterpolation", Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Tranparent"
        }
        //�s�����x�𗘗p����Ƃ��ɕK�v �����ʂ�A1 - �t���O�����g�V�F�[�_�[��Alpha�l�@�Ƃ����Ӗ�
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldPos : WORLD_POS;
            };

            float4 _MainColor;
            float _RepeatFactor;
            float _DistanceInterpolation;

            //UV����Z�p�`�^�C�����o��
            float hex(float2 uv, float scale = 1)
            {
                float2 p = uv * scale;
                p.x *= 1.15470053838; // x���W��2/��3�{ (�Z�p�`�̉������̑傫������3/2�{�ɂȂ�)
                float isTwo = frac(floor(p.x) / 2.0) * 2.0; // ������ڂȂ�1.0
                p.y += isTwo * 0.5; // ������ڂ�0.5���炷  
                p = frac(p) - 0.5;
                p = abs(p); // �㉺���E�Ώ̂ɂ���
                // �Z�p�`�^�C���Ƃ��ďo��
                return abs(max(p.x * 1.5 + p.y, p.y * 2.0) - 1.0);
            }

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex); //���[�J�����W�n�����[���h���W�n�ɕϊ�
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // �J�����ƃI�u�W�F�N�g�̋���(����)���擾
                // _WorldSpaceCameraPos�F��`�ς̒l�@���[���h���W�n�̃J�����̈ʒu
                float cameraToObjLength = length(_WorldSpaceCameraPos - i.worldPos);

                //�Z�p�`�`���UV�𗘗p���ĕ�Ԓl���v�Z
                float interpolation = hex(i.uv, _RepeatFactor);
                float3 finalColor = lerp(_MainColor, 0, interpolation);
                //�Z�p�`�`���UV�𗘗p���ăA���t�@��h����
                float alpha = lerp(1, 0, interpolation);
		//1m�ȉ����A_DistanceInterpolation��0�̂Ƃ��A���t�@�����S��0�ɂȂ�Ȃ��̂�max�֐���1�ȏ���L�[�v����
                alpha *= lerp(1, 0, max(cameraToObjLength, 1) * _DistanceInterpolation);
                clip(alpha);
                return float4(finalColor, alpha);
            }
            ENDCG
        }
    }
}
