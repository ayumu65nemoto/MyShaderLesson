Shader "Custom/GradationSkyShader"
{
    Properties
    {
        //�O���f�[�V�����J���[
        _TopColor("TopColor",Color) = (0,0,0,0)
        _UnderColor("UnderColor",Color) = (0,0,0,0)

        //�F�̋��E�̈ʒu
        _ColorBorder("ColorBorder",Range(0,3)) = 0.5
    }
    SubShader
    {
        Tags 
        { 
            "RenderType"="Background" //�Ŕw�ʂɕ`�悷��̂�Background
            "Queue"="Background" //�Ŕw�ʂɕ`�悷��̂�Background
            "PreviewType"="SkyBox" //�ݒ肷��΃}�e���A���̃v���r���[���X�J�C�{�b�N�X�ɂȂ�炵��
        }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            //�ϐ��̐錾�@Properties�Œ�`�������O�ƈ�v������
            float4 _UnderColor;
            float4 _TopColor;
            float _ColorBorder;

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
                float3 worldPos : WORLD_POS;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                //mul�͍s��̊|���Z������Ă����֐�
                o.worldPos = v.vertex.xyz;
                o.vertex = UnityObjectToClipPos(v.vertex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //�`�悵�����s�N�Z���̃��[���h���W�𐳋K��
                float3 dir = normalize(i.worldPos);
                //���W�A�����Z�o����
                //atan2(x,y) ���s���W�̊p�x�����W�A���ŕԂ�
                //atan(x)�ƈقȂ�A1�����̊p�x�����W�A���ŕԂ���@����̓X�J�C�{�b�N�X�̉~����̃��W�A�����Ԃ����
                //asin(x)  -��/2�`��/2�̊Ԃŋt������Ԃ��@x�͈̔͂�-1�`1
                float2 rad = float2(atan2(dir.x, dir.z), asin(dir.y));
                float2 uv = rad / float2(2.0 * UNITY_PI, UNITY_PI / 2);

                //������UV��Y�������̍��W�𗘗p���ĐF���O���f�[�V����������
                return lerp(_UnderColor, _TopColor, uv.y + _ColorBorder);
            }
            ENDCG
        }
    }
}
