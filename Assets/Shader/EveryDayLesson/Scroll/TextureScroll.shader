Shader "Custom/TextureScroll"
{
    Properties
    {
        //�X�N���[��������e�N�X�`��
        _MainTex ("Texture", 2D) = "white" {}
        //�F
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

            struct v2f
            {
                float3 localPos : TEXCOORD0;
                float2 uv : TEXCOORD1;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            half4 _Color;
            half _SliceSpace;

            v2f vert (appdata v)
            {
                v2f o;
                //�`�悵�悤�Ƃ��Ă��钸�_(���[�J�����W)
                o.localPos = v.vertex.xyz;
                o.uv = v.uv + _Time;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //���_�̐F���v�Z
                fixed4 col = tex2D(_MainTex, i.uv);
                //�e���_�̃��[�J�����W(Y��)���ꂼ���15��������frac�֐��ŏ����������o��
                //��������-0.5����clip�֐���0�����������`�悵�Ȃ�
                clip(frac(i.localPos.y * _SliceSpace) - 0.5);
                //�v�Z�����F�ƃv���p�e�B�Őݒ肵���F����Z����
                return half4(col * _Color);
            }
            ENDCG
        }
    }
}
