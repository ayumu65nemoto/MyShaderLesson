Shader "Custom/GeometryColorfulShader"
{
    Properties
    {
        
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            appdata vert(appdata v)
            {
                //appdata o;
                //o.vertex = UnityObjectToClipPos(v.vertex);
                //UNITY_TRANSFER_FOG(o,o.vertex);
                return v;
            }

            struct g2f
            {
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            //�����_���Ȓl��Ԃ�
            float rand(float2 co)
            {
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
            }

            // �W�I���g���V�F�[�_�[
            [maxvertexcount(3)]
            void geom(triangle appdata input[3],inout TriangleStream<g2f> stream)
            {
                //1���̃|���S���̒��S
                float3 center = (input[0].vertex + input[1].vertex + input[2].vertex) / 3;
		        //�����_���Ȓl
                float r = rand(center.xy);
                float g = rand(center.xz);
                float b = rand(center.yz);

                [unroll]
                for (int i = 0; i < 3; i++)
                {
                    appdata v = input[i];
                    g2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.color = fixed4(r,g,b,1);
                    stream.Append(o);
                }
            }

            fixed4 frag (g2f i) : SV_Target
            {
                return i.color;
            }
            ENDCG
        }
    }
}
