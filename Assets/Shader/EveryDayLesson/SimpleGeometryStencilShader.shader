Shader "Custom/SimpleGeometryStencilShader"
{
    Properties
    {
        
    }
    SubShader
    {
        //�X�e���V���o�b�t�@�Ɋւ���
        Stencil
        {
            //�X�e���V���̒l
            Ref [_Ref]

            //�X�e���V���o�b�t�@�̒l�̔�����@
            //Equal�Ȃ̂�"�`�悵�悤�Ƃ��Ă���s�N�Z���̃X�e���V���o�b�t�@"��Ref�Ɠ����ꍇ�A���̃s�N�Z����`��̏����ΏۂƂ���
            Comp Equal
        }

        Tags { "RenderType"="Opaque" }
        LOD 100
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            float _PositionFactor;
            float _RotationFactor;
            float _ScaleFactor;
            sampler2D _MainTex;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 localPos : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            appdata vert (appdata v)
            {
                appdata o;
                o.localPos = v.vertex.xyz; //�W�I���g���[�V�F�[�_�[�Œ��_�𓮂����O��"�`�悵�悤�Ƃ��Ă���s�N�Z��"�̃��[�J�����W��ێ����Ă���
                o.uv = v.uv;
                return v;
            }

            struct g2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD1;
            };

            //��]������
            //p�͉�]�����������W�@angle�͉�]������p�x�@axis�͂ǂ̎������ɉ�]�����邩�@
            float3 rotate(float3 p, float angle, float3 axis)
            {
                float3 a = normalize(axis);
                float s = sin(angle);
                float c = cos(angle);
                float r = 1.0 - c;
                float3x3 m = float3x3(
                    a.x * a.x * r + c, a.y * a.x * r + a.z * s, a.z * a.x * r - a.y * s,
                    a.x * a.y * r - a.z * s, a.y * a.y * r + c, a.z * a.y * r + a.x * s,
                    a.x * a.z * r + a.y * s, a.y * a.z * r - a.x * s, a.z * a.z * r + c
                );

                return mul(m, p);
            }

            //�����_���Ȓl��Ԃ�
            float rand(float2 co)
            {
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
            }

            // �W�I���g���V�F�[�_�[
            [maxvertexcount(3)]
            void geom(triangle appdata input[3], uint pid : SV_PrimitiveID, inout TriangleStream<g2f> stream)
            {
                // �@�����v�Z
                float3 vec1 = input[1].vertex - input[0].vertex;
                float3 vec2 = input[2].vertex - input[0].vertex;
                float3 normal = normalize(cross(vec1, vec2));

                //1���̃|���S���̒��S
                float3 center = (input[0].vertex + input[1].vertex + input[2].vertex) / 3;
                float random = 2.0 * rand(center.xy) - 0.5;
                float3 r3 = random.xxx;

                [unroll]
                for (int i = 0; i < 3; i++)
                {
                    appdata v = input[i];
                    g2f o;

                    //�W�I���g���[�̈ړ��E��]�E�g��k������
                    v.vertex.xyz = center + rotate(v.vertex.xyz - center, (pid + _Time.y) * _RotationFactor, r3);
                    v.vertex.xyz = center + (v.vertex.xyz - center) * (1.0 - _ScaleFactor);
                    v.vertex.xyz += normal * _PositionFactor * abs(r3);

                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv = v.uv;

                    stream.Append(o);
                }
            }

            fixed4 frag (g2f i) : SV_Target
            {
                float4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
