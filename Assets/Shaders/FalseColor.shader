Shader "Book/FalseColor"
{
    Properties
    {
        [KeywordEnum(Normal, Tangent, Binormal, Texcoord, Texcoord1, TexcoordFrac, Texcoord1Frac, Color)] _Type("False Color Type", int) = 0
    }
    SubShader
    {
        Pass {
            Tags { "RenderType"="Opaque" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma shader_feature_local _TYPE_NORMAL _TYPE_TANGENT _TYPE_BINORMAL _TYPE_TEXCOORD _TYPE_TEXCOORD1 _TYPE_TEXCOORDFRAC _TYPE_TEXCOORD1FRAC _TYPE_COLOR
            #include "UnityCG.cginc"

            struct v2f
            {
                float4 pos: SV_POSITION;
                fixed4 color: COLOR0;
            };

            v2f vert(appdata_full i)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(i.vertex);
                
                #if defined(_TYPE_NORMAL)
                    o.color = fixed4(i.normal * 0.5 + float3(0.5, 0.5, 0.5), 1.0); // 法线
                #elif defined(_TYPE_TANGENT)
                    o.color = fixed4(i.tangent * 0.5 + float3(0.5, 0.5, 0.5), 1.0); // 切线
                #elif defined(_TYPE_BINORMAL)
                    fixed3 binormal = cross(i.normal, i.tangent.xyz) * i.tangent.w;
                    o.color = fixed4(binormal * 0.5 + float3(0.5, 0.5, 0.5), 1.0); // 副法线
                #elif defined(_TYPE_TEXCOORD)
                    o.color = fixed4(i.texcoord.xy, 0.0, 1.0); // 第一组纹理坐标
                #elif defined(_TYPE_TEXCOORD1)
                    o.color = fixed4(i.texcoord1.xy, 0.0, 1.0); // 第二组纹理坐标
                #elif defined(_TYPE_TEXCOORDFRAC)
                    // 第一组纹理坐标的小数部分
                    o.color = frac(i.texcoord);
                    if(any(saturate(i.texcoord) - i.texcoord))
                    {
                        o.color.b = 0.5;
                    }
                    o.color.a = 1.0;
                #elif defined(_TYPE_TEXCOORD1FRAC)
                    // 第二组纹理坐标的小数部分
                    o.color = frac(i.texcoord1);
                    if(any(saturate(i.texcoord1) - i.texcoord1))
                    {
                        o.color.b = 0.5;
                    }
                    o.color.a = 1.0;
                #elif defined(_TYPE_COLOR)
                    o.color = i.color; // 顶点颜色
                #endif
                
                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                return i.color;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
