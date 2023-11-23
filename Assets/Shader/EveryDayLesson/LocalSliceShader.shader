Shader "Custom/LocalSliceShader"
{
    Properties
    {
        //�����ɏ��������̂�Inspector�ɕ\�������
        _Color("MainColor",Color) = (0,0,0,0)
        //�X���C�X�����Ԋu
        _SliceSpace("SliceSpace",Range(0,30)) = 15
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

            //�ϐ��̐錾�@Properties�Œ�`�������O�ƈ�v������
            half4 _Color;
            half _SliceSpace;

            struct v2f
            {
                UNITY_FOG_COORDS(1)
                float4 pos : SV_POSITION;
                float3 localPos : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o;
                //�`�悵�悤�Ƃ��Ă��钸�_(���[�J�����W)
                o.localPos = v.vertex.xyz;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //�e���_�̃��[�J�����W(Y��)���ꂼ���15��������frac�֐��ŏ����������o��
                //��������-0.5����clip�֐���0�����������`�悵�Ȃ�
                clip(frac(i.localPos.y * _SliceSpace) - 0.5);
                //RGBA�ɂ��ꂼ��̃v���p�e�B�𓖂Ă͂߂Ă݂�
                return half4(_Color);
            }
            ENDCG
        }
    }
}
