Shader "Custom/ParallaxMappingShader"
{
    Properties
    {
        //�����ɏ��������̂�Inspector�ɕ\�������
        _MainColor("MainColor",Color) = (1,1,1,1)
        _Reflection("Reflection", Range(0, 10)) = 1
        _Specular("Specular", Range(0, 10)) = 1
        _HeightFactor ("Height Factor", Range(0.0, 0.1)) = 0.02
        _NormalMap ("Normal map", 2D) = "bump" {}
        _HeightMap ("HeightMap map", 2D) = "white" {}
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
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal: NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 lightDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            //�ϐ��̐錾�@Properties�Œ�`�������O�ƈ�v������
            float4 _MainColor;
            float _Reflection;
            float _Specular;
            float _HeightFactor;
            sampler2D _NormalMap;
            sampler2D _HeightMap;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                // �ڋ�Ԃ̍s����擾
                TANGENT_SPACE_ROTATION;
                // ���C�g�̕����x�N�g����ڋ�Ԃɕϊ�
                o.lightDir = normalize(mul(rotation, ObjSpaceLightDir(v.vertex)));
                // �J�����̕����x�N�g����ڋ�Ԃɕϊ�
                o.viewDir = normalize(mul(rotation, ObjSpaceViewDir(v.vertex)));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //�n�C�g�}�b�v���T���v�����O����UV�����炷
                float4 height = tex2D(_HeightMap, i.uv);
                i.uv += i.viewDir.xy * height.r * _HeightFactor;

                //�m�[�}���}�b�v����@�����擾
                float3 normal = UnpackNormal(tex2D(_NormalMap, i.uv));

                //���C�g�x�N�g���Ɩ@���x�N�g�����甽�˃x�N�g�����v�Z
                float3 refVec = reflect(-i.lightDir, normal);
                //�����x�N�g���Ɣ��˃x�N�g���̓��ς��v�Z
                float dotVR = dot(refVec, i.viewDir);
                //0�ȉ��͗��p���Ȃ��悤�ɓ��ς̒l���Čv�Z
                dotVR = max(0, dotVR);
                dotVR = pow(dotVR, _Reflection);
                //�X�y�L�����[
                float3 specular = _LightColor0.xyz * dotVR * _Specular;
                //���ς��Ԓl�Ƃ��ēh����
                float4 finalColor = _MainColor + float4(specular, 1);
                return finalColor;
            }
            ENDCG
        }
    }
}
