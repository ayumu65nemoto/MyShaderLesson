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
  //　時間経過
  //float t = _Time.y;
  //float3 col = float3(
  //  sin(t*2.), 
  //  sin(t*1.2+1.3),
  //  sin(-t*2.1-2));
  //col = col * .5 + .5;
  //return float4(col, 1);

  //グラデーション
  //return float4(uv, 0, 1);

  //テクスチャ
  //return tex2D(_Tex, uv);

  //座標の原点を中心に
  //float2 p = uv*2. - 1.;
  //return float4(p, 0, 1);

  // 花
  //float2 p = uv*2. - 1.;
  //float theta = atan2(p.y, p.x);
  //float d = length(p) - .5 + sin(theta*6. + _Time.y*.5) * .4; //６の部分は花びらの数、４の部分は花びらの大きさと細さ
  //float b = 0.01 / abs(d); //0.05は明るさ
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

            // 構造体の定義
            struct appdata // vert関数の入力
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };
        
            struct fin // vert関数の出力からfrag関数の入力へ
            {
                float4 vertex : SV_POSITION;
                float2 texcoord : TEXCOORD0;
            };

            // float4 vert(float4 vertex : POSITION) : SV_POSITION から↓に変更
            fin vert(appdata v) // 構造体を使用した入出力
            {
                fin o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.texcoord = v.texcoord;
                return o;
            }

            float4 frag(fin IN) : SV_TARGET // 構造体finを使用した入力
            {
                return paint(IN.texcoord.xy);
            }
            ENDCG
        }
    }
}