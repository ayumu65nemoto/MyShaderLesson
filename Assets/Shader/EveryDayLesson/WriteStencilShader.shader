Shader "Custom/WriteStencilShader"
{
    Properties
    {
        _Ref("Ref", Int) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry-1" }
        LOD 100

        Pass
        {
            //�J���[�`�����l���ɏ������ރ����_�[�^�[�Q�b�g��ݒ肷��
            //0�̏ꍇ�A�S�ẴJ���[�`�����l�������������ꉽ���������܂�Ȃ�
            ColorMask 0
            ZWrite Off
            //�X�e���V���o�b�t�@�Ɋւ���
            Stencil
            {
                //�X�e���V���̒l
                Ref [_Ref]

                //�X�e���V���o�b�t�@�̒l�̔�����@
                //Always�Ȃ̂ŃX�e���V���o�b�t�@�̃e�X�g�͏�ɒʉ߂���
                Comp Always

                //�X�e���V���o�b�t�@�ɒl���������ނ��ǂ���
                //Replace�Ȃ̂Ŋ����̒l��Ref�̒l�ɒu��������
                Pass Replace
            }
        }
    }
}
