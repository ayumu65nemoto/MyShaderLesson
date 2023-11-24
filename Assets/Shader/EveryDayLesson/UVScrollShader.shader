Shader "Custom/UVScrollShader"
{
    Properties
    {
        //�F
        _Color("MainColor",Color) = (0,0,0,0)
        //�X���C�X�����Ԋu
        _SliceSpace("SliceSpace",Range(0,30)) = 15
        // ���Ԃɂ��F�̕ω��̑���
        _ColorChangeSpeed("ColorChangeSpeed", Range(0, 10)) = 1
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

            //�ϐ��̐錾�@Properties�Œ�`�������O�ƈ�v������
            half4 _Color;
            half _SliceSpace;
            half _ColorChangeSpeed;

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

            v2f vert (appdata v)
            {
                v2f o;
                //UV�X�N���[��
                o.uv = v.uv + _Time.y / 2 ;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //�e���_��UV���W(Y��)���ꂼ���15��������frac�֐��ŏ����������o��
                //��������-0.5����clip�֐���0�����������`�悵�Ȃ�
                clip(frac(i.uv.y * _SliceSpace) - 0.5);
                
                // ���Ԃɂ��F�̕ω����v�Z
                half timeColor = sin(_Time.y * _ColorChangeSpeed) * 0.5 + 0.5;

                // �v���p�e�B�Őݒ肵���F�Ǝ��Ԃɂ��ω�����Z���ĕԂ�
                return half4(_Color.r * timeColor, _Color.g * (timeColor / 2), _Color.b, _Color.a);
            }
            ENDCG
        }
    }
}
