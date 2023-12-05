Shader "Custom/GradationNightSkyWithMoonShader"
{
    Properties
    {
        _SquareNum ("SquareNum", int) = 10
        _MoonColor("MoonColor",Color) = (0,0,0,0)

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
            int _SquareNum;
            float4 _MoonColor;
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
                float4 vertex : SV_POSITION;
                float3 worldPos : WORLD_POS;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            //�����_���Ȓl��Ԃ�
            float rand(float2 co) //�����̓V�[�h�l�ƌĂ΂��@�����l��n���Γ������̂�Ԃ�
            {
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
            }

            //�����_���Ȓl��Ԃ�
            float2 random2(float2 st)
            {
                st = float2(dot(st, float2(127.1, 311.7)), dot(st, float2(269.5, 183.3)));
                return -1.0 + 2.0 * frac(sin(st) * 43758.5453123);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //�`�悵�����s�N�Z���̃��[�J�����W�𐳋K��
                float3 dir = normalize(i.worldPos);
                //���W�A�����Z�o����
                //atan2(x,y) ���s���W�̊p�x�����W�A���ŕԂ�
                //atan(x)�ƈقȂ�A1�����̊p�x�����W�A���ŕԂ���@����̓X�J�C�{�b�N�X�̉~����̃��W�A�����Ԃ����
                //asin(x)  -��/2�`��/2�̊Ԃŋt������Ԃ��@x�͈̔͂�-1�`1
                float2 rad = float2(atan2(dir.x, dir.z), asin(dir.y));
                float2 uv = rad / float2(UNITY_PI / 2, UNITY_PI / 2);

                uv *= _SquareNum; //�i�q��̃}�X�ڍ쐬 UV�ɂ�����������������UV���J��Ԃ��W�J�����

                float2 ist = floor(uv); //�e�}�X�ڂ̋N�_
                float2 fst = frac(uv); //�e�}�X�ڂ̋N�_����̕`�悵�����ʒu

                float4 color = 0;

                //���g�܂ގ��͂̃}�X��T��
                for (int y = -1; y <= 1; y++)
                {
                    for (int x = -1; x <= 1; x++)
                    {
                        //����1�~1�̃G���A
                        float2 neighbor = float2(x, y);

                        //�_��xy���W
                        float2 p = random2(ist);

                        //�_�Ə����Ώۂ̃s�N�Z���Ƃ̋����x�N�g��
                        float2 diff = neighbor + p - fst;

                        //�F�𐯂��ƂɃ����_���ɓ��Ă͂߂�@���̍��W�𗘗p
                        float r = rand(p + 1);
                        float g = rand(p + 2);
                        float b = rand(p + 3);
                        float4 randColor = float4(r, g, b, 1);

                        //"�_"��"���ݕ`�悵�悤�Ƃ��Ă���s�N�Z���Ƃ̋���"�𗘗p���Đ���`�悷�邩�ǂ������v�Z
                        //step(t,x) ��x��t���傫���ꍇ1��Ԃ�
                        float interpolation = 1 - step(0.01, length(diff));
                        color = lerp(color, randColor, interpolation);
                    }
                }

                //������UV��Y�������̍��W�𗘗p���ĐF���O���f�[�V����������
                color += lerp(_UnderColor, _TopColor, uv.y + _ColorBorder);
                //��
                color = lerp(_MoonColor, color, step(uv.y, _SquareNum * 0.75));

                return color;
            }
            ENDCG
        }
    }
}
