Shader "Unlit/Sample"
{
    Properties
    {
        _Tex ("Tex", 2D) = "" {}
    }

CGINCLUDE

sampler2D _Tex;

float flower(float2 p, float n, float radius, float angle, float waveAmp)
{
  float theta = atan2(p.y, p.x);
  float d = length(p) - radius + sin(theta*n + angle) * waveAmp;
  float b = 0.006 / abs(d);
  return b;
}

#define PI 3.14159265

float4 paint(float2 uv)
{
  //�@���Ԍo��
  //float t = _Time.y;
  //float3 col = float3(
  //  sin(t*2.), 
  //  sin(t*1.2+1.3),
  //  sin(-t*2.1-2));
  //col = col * .5 + .5;
  //return float4(col, 1);

  //�O���f�[�V����
  //return float4(uv, 0, 1);

  //�e�N�X�`��
  //return tex2D(_Tex, uv);

  //���W�̌��_�𒆐S��
  //float2 p = uv*2. - 1.;
  //return float4(p, 0, 1);

  // ��
  //float2 p = uv*2. - 1.;
  //float theta = atan2(p.y, p.x);
  //float d = length(p) - .5 + sin(theta*6. + _Time.y*.5) * .4; //�U�̕����͉Ԃт�̐��A�S�̕����͉Ԃт�̑傫���ƍׂ�
  //float b = 0.01 / abs(d); //0.05�͖��邳
  //float3 col = float3(.5, .0, 1.);
  //return float4(b * col, 1);

  float2 p = uv*2. - 1.;
  p *= 1.1;

  float3 col = 0;
  col += flower(p, 6., .9, _Time.y*1.5, .1) * float3(.1, .01, 1.);
  col += flower(p, 3., .2, PI*.5-_Time.y*.3, .2) * float3(1., .5, 0.);
  col += flower(p, 4., .5, _Time.y*.3, .1) * float3(0., 1., 1.);

  col += min( flower(p, 18., .7, -_Time.y*10., .01), 1.) * .1 * float3(.1, .6, .1);

  col += flower(p, 55., .05, -_Time.y*100., .1) * float3(1., .1, .1);

  return float4(col, 1);
}

ENDCG
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            // �\���̂̒�`
            struct appdata // vert�֐��̓���
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };
        
            struct fin // vert�֐��̏o�͂���frag�֐��̓��͂�
            {
                float4 vertex : SV_POSITION;
                float2 texcoord : TEXCOORD0;
            };

            // float4 vert(float4 vertex : POSITION) : SV_POSITION ���火�ɕύX
            fin vert(appdata v) // �\���̂��g�p�������o��
            {
                fin o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.texcoord = v.texcoord;
                return o;
            }

            float4 frag(fin IN) : SV_TARGET // �\����fin���g�p��������
            {
                return paint(IN.texcoord.xy);
            }
            ENDCG
        }
    }
}