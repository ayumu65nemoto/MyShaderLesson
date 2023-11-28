Shader "Custom/RandomVertexMoveShader"
{
    Properties
    {
        //���_�̓����̕�
        _VertMoveRange("VertMoveRange", Range(0, 0.5)) = 0.025
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            //�����_���Ȓl��Ԃ�
            float rand(float2 co) //�����̓V�[�h�l�ƌĂ΂��@�����l��n���Γ������̂�Ԃ�
            {
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
            }

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
            };

            float _VertMoveRange;

            v2f vert (appdata v)
            {
                v2f o;
                //�����_���Ȓl����
                float random = rand(v.vertex.xy);
                //�����_���Ȓl��sin�֐��̈����ɓn���Čo�ߎ��Ԃ��|�����킹�邱�ƂŊe���_�Ƀ����_���ȕω���^����
                float4 vert = float4(v.vertex.xyz + v.vertex.xyz * sin(1 +_Time.w * random) * _VertMoveRange, v.vertex.w);
                o.vertex = UnityObjectToClipPos(vert);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //�V�[�h�l�ɓ����l��n���ƑS�������l�ɂȂ�̂ň����̃V�[�h�l�ɕʂ̒l��n��
                float r = rand(i.vertex.xy + 0.1);
                float g = rand(i.vertex.xy + 0.2);
                float b = rand(i.vertex.xy + 0.3);
                return float4(r,g,b,1);
            }
            ENDCG
        }
    }
}
