Shader "Custom/ToonOutLineShader"
{
    Properties
    {
        _MainTexture ("Main Texture", 2D) = "white" {}
        _ShadowTexture ("Shadow Texture", 2D) = "white" {}
        _ShadowStrength("Shadow Strength",Range(0,1)) = 0.5
        _OutlineWidth ("Outline width", Range (0.005, 0.03)) = 0.01
        [HDR]_OutlineColor ("Outline Color", Color) = (0,0,0,1)
        [Toggle(USE_VERTEX_EXPANSION)] _UseVertexExpansion("Use vertex for Outline", int) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        UsePass "Custom/ToonLitShader/TOON"

        Pass
        {
            Cull Front

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #pragma shader_feature USE_VERTEX_EXPANSION

            #include "UnityCG.cginc"

            float _OutlineWidth;
            float4 _OutlineColor;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                float3 n = 0;

                #ifdef USE_VERTEX_EXPANSION //���f���̒��_�����Ɋg�傷��p�^�[��
                
                //���f���̌��_����݂��e���_�̈ʒu�x�N�g�����v�Z
                float3 dir = normalize(v.vertex.xyz);
                //UNITY_MATRIX_IT_MV�̓��f���r���[�s��̋t�s��̓]�u�s��
                //�e���_�̈ʒu�x�N�g�������f�����W�n����r���[���W�n�ɕϊ������K��
                n = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, dir));
                
                #else //���f���̖@�������Ɋg�傷��p�^�[��
                
                //�@�������f�����W�n����r���[���W�n�ɕϊ������K��
                n = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, v.normal));
                
                #endif

                //�r���[���W�n�ɕϊ������@���𓊉e���W�n�ɕϊ��@
                //�A�E�g���C���Ƃ��ĕ`��\��ł���s�N�Z����XY�����̃I�t�Z�b�g
                float2 offset = TransformViewToProjection(n.xy);
                o.pos.xy += offset * _OutlineWidth;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return _OutlineColor;
            }
            ENDCG
        }
    }
}
