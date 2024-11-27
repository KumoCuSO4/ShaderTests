
Shader "Book/DiffusePixelLevel"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1,1,1,1)
    }
    SubShader
    {
        Pass {
            Tags { "LightMode"="UniversalForward" }

            CGPROGRAM
            #include "Lighting.cginc"
            
            #pragma vertex vert
            #pragma fragment frag

            fixed4 _Diffuse;
            
            struct a2v
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
            };

            struct v2f
            {
                float4 pos: SV_POSITION;
                float3 worldNormal: NORMAL;
            };

            v2f vert(a2v i)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(i.vertex);
                o.worldNormal = normalize(mul(i.normal, (float3x3)unity_WorldToObject));
                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(i.worldNormal, worldLight));
                fixed3 color = ambient + diffuse;
                return fixed4(color, 1.0); // 有区别吗
            }
            ENDCG
        }
    }
}
