Shader "Custom/RecalculateNormalShader"
{
    Properties
    {
        //�����ɏ��������̂�Inspector�ɕ\�������
        _MainColor("MainColor",Color) = (1,1,1,1)
        _DiffuseShade("Diffuse Shade",Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags 
        { 
            "RenderType"="Opaque" 
            "LightMode"="UniversalForward" 
        }
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
                float3 normal: NORMAL;
                float3 tangent: TANGENT;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float3 ambient : COLOR0; //����
            };

            //�ϐ��̐錾�@Properties�Œ�`�������O�ƈ�v������
            float4 _MainColor;
            float _DiffuseShade;

            v2f vert (appdata v)
            {
                v2f o;

                //�ڋ�Ԃ̃x�N�g���̋ߖT�_���쐬
                float3 posT = v.vertex + v.tangent;
                float3 posB = v.vertex + normalize(cross(v.normal, v.tangent));
               
                //���_�𓮂���
                v.vertex.y = v.vertex.y + sin(v.vertex.x * 2.0 + _Time.y) * cos(v.vertex.z * 2.0 + _Time.y);

                //�ߖT�l��������
                posT.y = posT.y + sin(posT.x * 2.0 + _Time.y) * cos(posT.z * 2.0 + _Time.y);
                posB.y = posB.y + sin(posB.x * 2.0 + _Time.y) * cos(posB.z * 2.0 + _Time.y);
                
                //�����������_���W�ƋߖT�_�Őڋ�Ԃ̃x�N�g�����Čv�Z����
                float3 modifiedTangent = posT - v.vertex;
                float3 modifiedBinormal = posB - v.vertex;
                
                //�v�Z�����ڋ�Ԃ̃x�N�g����p���Ė@�����Čv�Z����
                o.normal = normalize(cross(modifiedBinormal, modifiedTangent));
                o.vertex = UnityObjectToClipPos(v.vertex);
                //����
                o.ambient = ShadeSH9(float4(o.normal, 1));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //���C�g�̕���
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                //Diffuse����
                float4 diffuseColor = max(0, dot(i.normal, lightDir) * _DiffuseShade + (1 - _DiffuseShade));
                //�F����Z
                float4 finalColor = _MainColor * diffuseColor * _LightColor0 * float4(i.ambient, 0);
                return finalColor;
            }
            ENDCG
        }
    }
}
