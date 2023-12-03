Shader "Custom/GeometryNormalMoveShader"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _PositionFactor("Position Factor", float) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            // �W�I���g���V�F�[�_�[�̊֐����ǂꂩGPU�ɋ�����
            #pragma geometry geom
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            fixed4 _Color;
            float _PositionFactor;

            // ���_�V�F�[�_�[�ɓn���Ă��钸�_�f�[�^
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            //�W�I���g���V�F�[�_�[����t���O�����g�V�F�[�_�[�ɓn���f�[�^
            struct g2f
            {
                float4 vertex : SV_POSITION;
            };

            //���_�V�F�[�_�[
            appdata vert(appdata v)
            {
                return v;
            }

            //�W�I���g���V�F�[�_�[
            //������input�͕����ʂ蒸�_�V�F�[�_�[����̓���
            //stream�͎Q�Ɠn���Ŏ��̏����ɒl���󂯓n�����Ă���@TriangleStream<>�ŎO�p�ʂ��o�͂���
            [maxvertexcount(3)] //�o�͂��钸�_�̍ő吔�@�����悭�킩��Ȃ�
            void geom(triangle appdata input[3], inout LineStream<g2f> stream)
            {
                // �@�����v�Z
                float3 vec1 = input[1].vertex - input[0].vertex;
                float3 vec2 = input[2].vertex - input[0].vertex;
                float3 normal = normalize(cross(vec1, vec2));

                [unroll] //�J��Ԃ���������ݍ���ōœK�����Ă�H
                for (int i = 0; i < 3; i++)
                {
                    appdata v = input[i];
                    g2f o;
                    //�@���x�N�g���ɉ����Ē��_���ړ�
                    v.vertex.xyz += normal * (sin(_Time.w) + 0.5) * _PositionFactor;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    stream.Append(o);
                }
            }

            // �t���O�����g�V�F�[�_�[
            fixed4 frag (g2f i) : SV_Target
            {
                return _Color;
            }
            ENDCG
        }
    }
}
