Shader "Custom/MaskRotateShader"
{
    Properties
    {
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
        //Mask�p�e�N�X�`���\
        [NoScaleOffset] _MaskTex ("Mask Texture (RGB)", 2D) = "white" {}
        //��]�̑��x
        _RotateSpeed ("Rotate Speed", float) = 1.0
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
                float2 uv1 : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
            };

            struct v2f
            {
                float2 uv1 : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _MaskTex;
            fixed _RotateSpeed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv1 = v.uv1;
                o.uv2 = v.uv2;
                //UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //Time����͂Ƃ��Č��݂̉�]�p�x�����
                half timer = _Time.x;
                //��]�s������
                half angleCos = cos(timer * _RotateSpeed);
                half angleSin = sin(timer * _RotateSpeed);
                half2x2 rotateMatrix = half2x2(angleCos, -angleSin, angleSin, angleCos);
                //���S���킹
                half2 uv1 = i.uv1 - 0.5;
                //���S���N�_�Ƀ��C���e�N�X�`����UV����]������
                i.uv1 = mul(uv1, rotateMatrix) + 0.5;
                //�}�X�N�p�摜�̃s�N�Z���̐F���v�Z
                fixed4 mask = tex2D(_MaskTex, i.uv2);
                //�����̒l���h�O�ȉ��Ȃ�h�`�悵�Ȃ��@���Ȃ킿�hAlpha��0.5�ȉ��Ȃ�h�`�悵�Ȃ�
                clip(mask.a - 0.5);
                //���C���e�N�X�`���̐F���擾
                fixed4 col = tex2D(_MainTex, i.uv1);
                //���C���摜�ƃ}�X�N�摜�̃s�N�Z���̌v�Z���ʂ��������킹��
                return col * mask;
            }
            ENDCG
        }
    }
}
