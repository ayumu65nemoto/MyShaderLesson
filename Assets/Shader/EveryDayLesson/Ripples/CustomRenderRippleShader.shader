Shader "Custom/CustomRenderRippleShader"
{
    Properties
    {
        _S2("PhaseVelocity^2", Range(0.0, 0.5)) = 0.2
        _Attenuation("Attenuation", Range(0.0, 1.0)) = 0.999
        _DeltaUV("Delta UV", Float) = 0.1
    }

    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex CustomRenderTextureVertexShader //��p�̒�`�ς�vertex�V�F�[�_�֐�
            #pragma fragment frag

            #include "UnityCustomRenderTexture.cginc" //��p��cginc�t�@�C��

            half _S2;
            half _Attenuation;
            float _DeltaUV;
            sampler2D _MainTex;

            float4 frag(v2f_customrendertexture i) : SV_Target
            {
                float2 uv = i.globalTexcoord;

                // 1px������̒P�ʂ��v�Z����
                float du = 1.0 / _CustomRenderTextureWidth;
                float dv = 1.0 / _CustomRenderTextureHeight;
                float2 duv = float2(du, dv) * _DeltaUV;

                // ���݂̈ʒu�̃e�N�Z�����t�F�b�`
                float2 c = tex2D(_SelfTexture2D, uv);

                //�g��������
                //h(t + 1) = 2h + c(h(x + 1) + h(x - 1) + h(y + 1) + h(y - 1) - 4h) - h(t - 1)
                //����Ah(t + 1)�͎��̃t���[���ł̔g�̍�����\��
                //R,G�����ꂼ�ꍂ���Ƃ��Ďg�p
                float k = (2.0 * c.r) - c.g; //2h - h(t - 1) ���Ɍv�Z
                float p = (k + _S2 * ( //_S2�͌W�� �ʑ��̕ω����鑬�x
                    tex2D(_SelfTexture2D, uv + duv.x).r +
                    tex2D(_SelfTexture2D, uv - duv.x).r +
                    tex2D(_SelfTexture2D, uv + duv.y).r +
                    tex2D(_SelfTexture2D, uv - duv.y).r - 4.0 * c.r)
                ) * _Attenuation; //�����W��

                // ���݂̏�Ԃ��e�N�X�`����R�����ɁA�ЂƂO�́i�ߋ��́j��Ԃ�G�����ɏ������ށB
                return float4(p, c.r, 0, 0);
            }
            ENDCG
        }
    }
}
