Shader "Custom/ButterflyShader"
{
    Properties
    {
        [NoScaleOffset]_MainTex ("Texture", 2D) = "white" {}
        [HDR]_MainColor("MainColor",Color) = (1,1,1,1)
        _FlapSpeed ("Flap Speed", Range(0,20)) = 10
        _FlapIntensity ("Flap Intensity", Range(0,2)) = 1
        _MoveSpeed ("Move Speed", Range(0,5)) = 1
        _MoveIntensity ("Move Intensity", Range(0,1)) = 0.2
        _RandomFlap ("Random Flap", Range(1,2)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        LOD 100

        Pass
        {
            Cull off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float2 uv : TEXCOORD0;
                //���S���W���󂯎��ϐ�
                float3 center : TEXCOORD1;
                //�����_���Ȓl���󂯎��ϐ�
                float random : TEXCOORD2;
                //���x���󂯎��ϐ�
                float3 velocity : TEXCOORD3;
                float4 color : COLOR;
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
            };

            sampler2D _MainTex;
            float4 _MainColor;
            float _FlapSpeed;
            float _FlapIntensity;
            float _MoveIntensity;
            float _MoveSpeed;
            float _RandomFlap;

            //�����_���Ȓl��Ԃ�
            float rand(float2 co) //�����̓V�[�h�l�ƌĂ΂��@�����l��n���Γ������̂�Ԃ�
            {
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
            }

            //����`�u���E���^�����v�Z����
            float fbm(float x, float t)
            {
                return sin(x + t) + 0.5 * sin(2.0 * x + t) + 0.25 * sin(4.0 * x + t);
            }

            v2f vert (appdata v)
            {
                v2f o;

                //���[�J�����W
                //Particle System��GameObject�����݂���Ƃ��낪���_�ƂȂ�Avertex�ɂ͂��̌��_���猩�����W�������Ă���
                //���̂��߁A�p�[�e�B�N���̒��S���W�������Čv�Z���s���A���Ƃɖ߂��Ƃ����H���𓥂�
                float3 local = v.vertex - v.center;

                //�����_���Ȓl���v�Z
                float randomFlap = lerp(_FlapSpeed / _RandomFlap, _FlapSpeed, rand(v.random));
                float flap = (sin(_Time.w * randomFlap) + 0.5) * 0.5 * _FlapIntensity;
                //Sign(x)��x��0���傫���ꍇ��1�A�������ꍇ��-1��Ԃ�
                //����ɂ��Ax=0�ƂȂ�ӏ�������Ώ̂ɉ�]���v�Z�ł���
                half c = cos(flap * sign(local.x));
                half s = sin(flap * sign(local.x));
                /*       |cos�� -sin��|
                  R(��) = |sin��  cos��|  2������]�s��̌���*/
                half2x2 rotateMatrix = half2x2(c, -s, s, c);

                //�H�̉�]�𔽉f
                local.xy = mul(rotateMatrix, local.xy);

                //�i�s�������������邽�߂̉�]�s����쐬
                //���ʂ͐i�s�����A���Ȃ킿Particle����擾����velocity
                float3 forward = normalize(v.velocity);
                float3 up = float3(0, 1, 0);
                float3 right = normalize(cross(forward, up));

                //�s����쐬
                //�ǂ����ϐ��ɋl�߂�Ƃ������s�I�[�_�[�ɂȂ��Ă���H���ۂ�
                //�Ȃ̂�transpose�œ]�u���s��
                //���Ȃ킿�ȉ��ł���
                //float3x3 mat = float3x3(right.x,up.x,forward.x,
                //                        right.y,up.y,forward.y,
                //                        right.z,up.z,forward.z);
                float3x3 mat = transpose(float3x3(right, up, forward));

                //Velocity(���ʕ���)�ɉ�������]�𔽉f
                v.vertex.xyz = mul(mat, local);

                //���_�����Ƃ̍��W�ɖ߂�
                v.vertex.xyz += v.center;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //�㉺�̈ړ��ʂ����߂Ĕ��f ���[���h���W�n�ŏ㉺�ړ�������
                float move = fbm(87034 * v.random, _Time.w * _MoveSpeed) * _MoveIntensity;
                o.vertex.y += move;
                o.uv = v.uv;
                //���_�J���[
                o.color = v.color;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //Plane��Z�������̕����ɂȂ�悤�Ƀe�N�X�`���[���T���v�����O
                //�e�N�X�`���[��Repeat�ɂ��Ă����K�v����
                float4 col = tex2D(_MainTex, -i.uv);
                col.rgb *= _MainColor.rgb;
                //���_�J���[��K�p�@�����Particle�̐F���E���悤�ɂȂ�
                col *= i.color;
                //�d�Ȃ����Ƃ��낪�����ɐ؂蔲����Ă��܂��̂œ��ߗ̈��Clip���Ă���
                clip(col.a - 0.01);
                return col;
            }
            ENDCG
        }
    }
}
