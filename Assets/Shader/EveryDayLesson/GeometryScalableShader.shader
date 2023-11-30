Shader "Custom/GeometryScalableShader"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _ScaleFactor ("Scale Factor", Range(0,1.0)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            fixed4 _Color;
            float _ScaleFactor;

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

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
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
                //1���̃|���S���̒��S
                float3 center = (input[0].vertex + input[1].vertex + input[2].vertex) / 3;

                [unroll] //�J��Ԃ���������ݍ���ōœK�����Ă�H
                for (int i = 0; i < 3; i++)
                {
                    appdata v = input[i];
                    g2f o;
                    //���S���N�_�ɃX�P�[����ς���
                    v.vertex.xyz = (v.vertex.xyz - center) * (1.0 - _ScaleFactor) + center;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    stream.Append(o);
                }
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return _Color;
            }
            ENDCG
        }
    }
}
