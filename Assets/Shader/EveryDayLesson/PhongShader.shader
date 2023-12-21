Shader "Custom/PhongShader"
{
    Properties
    {
        //�����ɏ��������̂�Inspector�ɕ\�������
        _MainColor("MainColor",Color) = (1,1,1,1)
        _Reflection("Reflection", Range(0, 10)) = 1
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
                float4 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float3 worldPos : WORLD_POS;
            };

            //�ϐ��̐錾�@Properties�Œ�`�������O�ƈ�v������
            float4 _MainColor;
            float _Reflection;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //���C�g�̕���
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                //���C�g�x�N�g���Ɩ@���x�N�g�����甽�˃x�N�g�����v�Z
                float3 refVec = reflect(-lightDir, i.normal);
                //�����x�N�g��
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                //�����x�N�g���Ɣ��˃x�N�g���̓��ς��v�Z
                float dotVR = dot(refVec, viewDir);
                //0�ȉ��͗��p���Ȃ��悤�ɓ��ς̒l���Čv�Z
                dotVR = max(0,dotVR);
                dotVR = pow(dotVR, _Reflection);
                float3 specular = _LightColor0.xyz * dotVR;
                //���ς��Ԓl�Ƃ��ēh����
                float4 finalColor =  _MainColor + float4(specular,1);
                return finalColor;
            }
            ENDCG
        }
    }
}
