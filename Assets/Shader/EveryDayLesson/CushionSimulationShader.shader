Shader "Custom/CushionSimulationShader"
{
    Properties
    {
        _InteractiveDisplacement("Interactive Displacement", Range(-1.0, 1.0)) = 0.1
    }

    CGINCLUDE
    #include "UnityCustomRenderTexture.cginc"

    float _InteractiveDisplacement;

    //�ʏ���
    float4 frag(v2f_customrendertexture i) : SV_Target
    {
        float2 uv = i.globalTexcoord;
        // ���݂̈ʒu�̃e�N�Z�����t�F�b�`
        float2 self = tex2D(_SelfTexture2D, uv);
        //���X�ɉ��݂����ɖ߂�
        return float4(self.r * 0.99, 0, 0, 0);
    }

    //�C���^���N�e�B�u�ɉ����ė��p�����t���O�����g�V�F�[�_�[
    float4 frag_interactive(v2f_customrendertexture i) : SV_Target
    {
        float2 uv = i.globalTexcoord;
        // ���݂̈ʒu�̃e�N�Z�����t�F�b�`
        float2 self = tex2D(_SelfTexture2D, uv);
        //���X�ɉ���
        return float4(clamp((self.r - 0.01) * 1.0001,_InteractiveDisplacement,0), 0, 0, 0);
    }
    
    ENDCG

    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        //�f�t�H���g�ŗ��p�����Pass
        Pass
        {
            Name "Update"
            CGPROGRAM
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
            ENDCG
        }

        //�C���^���N�e�B�u�ɉ����ė��p�����Pass
        Pass
        {
            Name "Interactive"
            CGPROGRAM
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag_interactive
            ENDCG
        }
    }
}
