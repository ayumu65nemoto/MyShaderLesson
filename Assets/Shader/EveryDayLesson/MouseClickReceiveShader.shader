Shader "Custom/MouseClickReceiveShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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

            //C#���ł�����ϐ�
            float4 _MousePosition;

            v2f vert (appdata v)
            {
                v2f o;
                //3D��ԍ��W���X�N���[�����W�ϊ�
                o.vertex = UnityObjectToClipPos(v.vertex);
                //�`�悵�����s�N�Z���̃��[���h���W���v�Z
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //�x�[�X�J���[�@��
                float4 baseColor = (1,1,1,1);
                
                /*"�}�E�X����o��Ray�ƃI�u�W�F�N�g�̏Փˉӏ�(���[���h���W)"��
                 �@"�`�悵�悤�Ƃ��Ă���s�N�Z���̃��[���h���W"�̋��������߂�*/
                float dist = distance( _MousePosition, i.worldPos);
                
                //���߂��������C�ӂ̋����ȉ��Ȃ�`�悵�悤�Ƃ��Ă���s�N�Z���̐F��ς���
                if( dist < 0.05)
                {
                    //�ԐF��Z���
                    baseColor *= float4(1,0,0,0);
                }
                
                return baseColor;
            }
            ENDCG
        }
    }
}
