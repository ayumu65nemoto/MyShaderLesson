Shader "Custom/CellularNoiseShader"
{
    Properties
    {
        _SquareNum ("SquareNum", int) = 5
        [HDR]_WaterColor("WaterColor", Color) = (0.09, 0.89, 1, 1)
        _WaveSpeed("WaveSpeed", Range(1,10)) = 1
        _FoamPower("FoamPower", Range(0,1)) = 0.6
        _FoamColor("FoamColor", Color) = (1, 1, 1, 1)
        _EdgeColor("EdgeColor", Color) = (1, 1, 1, 1)
        _DepthFactor("Depth Factor", float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha

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
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 screenPos : TEXCOORD1;
            };

            float2 random2(float2 st)
            {
                st = float2(dot(st, float2(127.1, 311.7)),
                            dot(st, float2(269.5, 183.3)));
                return -1.0 + 2.0 * frac(sin(st) * 43758.5453123);
            }

            uniform sampler2D _CameraDepthTexture;
            int _SquareNum;
            fixed4 _WaterColor;
            fixed4 _FoamColor; 
            fixed4 _EdgeColor;
            float _WaveSpeed;
            float _FoamPower;
            float _DepthFactor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 st = i.uv;
                st *= _SquareNum; //�i�q��̃}�X�ڍ쐬 UV�ɂ�����������������UV���J��Ԃ��W�J�����

                float2 ist = floor(st); //�e�}�X�ڂ̋N�_
                float2 fst = frac(st); //�e�}�X�ڂ̋N�_����̕`�悵�����ʒu

                float4 waveColor = 0;
                float m_dist = 100;

                //���g�܂ގ��͂̃}�X��T��
                for (int y = -1; y <= 1; y++)
                {
                    for (int x = -1; x <= 1; x++)
                    {
                        //����1�~1�̃G���A
                        float2 neighbor = float2(x, y);

                        //�_��xy���W
                        float2 p =  0.5 + 0.5 * sin(random2(ist+neighbor) +_Time.x *_WaveSpeed);

                        //�_�Ə����Ώۂ̃s�N�Z���Ƃ̋����x�N�g��
                        float2 diff = neighbor + p - fst;

                        m_dist = min(m_dist, length(diff));

                        waveColor =  lerp(_WaterColor,_FoamColor,smoothstep(1-_FoamPower,1,m_dist));
                    }
                }

                //�[�x�̌v�Z
                float4 depthSample = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos));
                half depth = LinearEyeDepth(depthSample);
                half screenDepth = depth - i.screenPos.w;
                float edgeLine = 1 - saturate(_DepthFactor * screenDepth);
                fixed4 finalColor = lerp(waveColor, _EdgeColor, edgeLine);
                
                return finalColor;
            }
            ENDCG
        }
    }
}
