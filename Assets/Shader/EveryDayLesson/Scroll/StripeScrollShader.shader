Shader "Custom/StripeScrollShader"
{
    Properties
    {
        //�F
        _StripeColor1("StripeColor1",Color) = (1,0,0,0)
        _StripeColor2("StripeColor2",Color) = (0,1,0,0)
        //�X���C�X�����Ԋu
        _SliceSpace("SliceSpace",Range(0,1)) = 0.5
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
            half4 _StripeColor1;
            half4 _StripeColor2;
            half _SliceSpace;

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
                o.uv = v.uv + _Time.x * 2;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //��Ԓl�̌v�Z�@�ƌ����Ă�0��1�����Ԃ��Ă��Ȃ�
                //step�֐��Fstep(t, x)
                //x�̒l��t�����������ꍇ�ɂ�0�A�傫���ꍇ�ɂ�1��Ԃ�
                half interpolation = step(frac(i.uv.y * 15), _SliceSpace);
                //Color1��Color2�̂ǂ��炩��Ԃ�
                half4 color = lerp(_StripeColor1,_StripeColor2, interpolation);
                //�v�Z���I������s�N�Z���̐F��Ԃ�
                return color;
            }
            ENDCG
        }
    }
}
