Shader "Custom/3DHoloShader"
{
    Properties
    {
        _MainColor("Main Color", Color) = (0,0.0,1)
        _RimColor("Rim Color", Color) = (1,1,1,1)
        _MainTex("Main Texture", 2D) = "white" {}
        _Alpha("Alpha", Range(0,1)) = 1
        _FrameRate ("FrameRate", Range(0,30)) = 15
        _Frequency ("Frequency", Range(0,1)) = 0.1
        _GlitchScale ("GlitchScale", Range(0,10)) = 1
        _LineSpeed("Line Speed",Range(1,5)) = 1
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Back

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
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
            };

            //�����_���Ȓl��Ԃ�
            float rand(float2 co) //�����̓V�[�h�l�ƌĂ΂��@�����l��n���Γ������̂�Ԃ�
            {
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
            }

            //�p�[�����m�C�Y
            float perlinNoise(fixed2 st)
            {
                fixed2 p = floor(st);
                fixed2 f = frac(st);
                fixed2 u = f * f * (3.0 - 2.0 * f);

                float v00 = rand(p + fixed2(0, 0));
                float v10 = rand(p + fixed2(1, 0));
                float v01 = rand(p + fixed2(0, 1));
                float v11 = rand(p + fixed2(1, 1));

                return lerp(lerp(dot(v00, f - fixed2(0, 0)), dot(v10, f - fixed2(1, 0)), u.x),
                            lerp(dot(v01, f - fixed2(0, 1)), dot(v11, f - fixed2(1, 1)), u.x),
                            u.y) + 0.5f;
            }

            float4 _MainColor;
            float4 _RimColor;
            sampler2D _MainTex;
            float _Alpha;
            float _FrameRate;
            float _Frequency;
            float _GlitchScale;
            float _LineSpeed;

            //�O���b�`�p�Ƀm�C�Y���v�Z
            float2 glitch_noise_calculate(float2 uv)
            {
                float posterize = floor(frac(perlinNoise(frac(_Time)) * 10) / (1 / _FrameRate)) * (1 / _FrameRate);
                //uv.y�����̃m�C�Y�v�Z -1 < random < 1
                float noiseY = 2.0 * rand(posterize) - 0.5;
                //�O���b�`�̍����̕�Ԓl�v�Z �ǂ̍����ɏo�����邩�͎��ԕω��Ń����_��
                float glitchLine1 = step(uv.y - noiseY, rand(uv));
                float glitchLine2 = step(uv.y - noiseY, 0);
                noiseY = saturate(glitchLine1 - glitchLine2);
                //uv.x�����̃m�C�Y�v�Z -0.1 < random < 0.1
                float noiseX = (2.0 * rand(posterize) - 0.5) * 0.1;
                float frequency = step(abs(noiseX), _Frequency);
                noiseX *= frequency;
                return float2(noiseX, noiseY);
            }

            v2f vert (appdata v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                //���_�ɃO���b�`�𔽉f
                float2 noise = glitch_noise_calculate(o.uv);
                o.vertex.x = lerp(o.vertex.x, o.vertex.x + noise.x * _GlitchScale, noise.y);
                //���[���h���W�@�X�L�������C���ɗ��p
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                //�@���@�����ɗ��p
                o.normalDir = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;
                float2 noise = glitch_noise_calculate(uv);
                //�O���b�`�K�p
                uv.x = lerp(uv.x, uv.x + noise.x * _GlitchScale, noise.y);
                //�m�C�Y�J���[
                float4 noiseColor = tex2D(_MainTex, uv) * _MainColor;
                //�������C�g
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                half rim = 1.0 - saturate(dot(viewDirection, i.normalDir));
                //�X�L�������C���@�������T�C�Y
                float fraclines = frac(i.worldPos.y + _Time.y * _LineSpeed);
                float scanlines = step(fraclines, 0.5);
                //�X�L�������C���@�傫���T�C�Y
                float big_scanlines = frac((i.worldPos.y) - _Time.x * 4.0 *  _LineSpeed);
                //�ŏI�̐F���v�Z
                fixed4 col = noiseColor + (big_scanlines * 0.4 * _MainColor) + (rim * _RimColor);
                //�A���t�@���v�Z
                col.a = _Alpha * (scanlines + rim + big_scanlines);
                return col;
            }
            ENDCG
        }
    }
}
