Shader "Custom/CameraDistanceShader"
{
    Properties
    {
        //�e�N�X�`���[(�I�t�Z�b�g�̐ݒ�Ȃ�)
        [NoScaleOffset] _NearTex ("NearTexture", 2D) = "white" {}
        //�e�N�X�`���[(�I�t�Z�b�g�̐ݒ�Ȃ�)
        [NoScaleOffset] _FarTex ("FarTexture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            //�ϐ��̐錾
            sampler2D _NearTex;
            sampler2D _FarTex;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float3 worldPos : WORLD_POS;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.uv = v.uv;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex); //���[�J�����W�n�����[���h���W�n�ɕϊ�
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //���ꂼ��̃e�N�X�`����UV����s�N�Z���̐F���v�Z
                float4 nearCol = tex2D(_NearTex,i.uv);
                float4 farCol = tex2D(_FarTex,i.uv);

                // �J�����ƃI�u�W�F�N�g�̋���(����)���擾
                // _WorldSpaceCameraPos�F��`�ς̒l�@���[���h���W�n�̃J�����̈ʒu
                float cameraToObjLength = length(_WorldSpaceCameraPos - i.worldPos);
                // Lerp���g���ĐF��ω��@��Ԓl��"�J�����ƃI�u�W�F�N�g�̋���"���g�p
                fixed4 col = fixed4(lerp(nearCol, farCol, cameraToObjLength * 0.1));
                //Alpha��0�ȉ��Ȃ�`�悵�Ȃ�
                clip(col);
                //�ŏI�I�ȃs�N�Z���̐F��Ԃ�
                return col;
            }
            ENDCG
        }
    }
}
