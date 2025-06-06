﻿
Shader "Book/AlphaBlendBothSided"
{
    Properties
    {
        _Color("Color Tint", Color) = (1,1,1,1)
        _MainTex("Main Tex", 2D) = "white" {}
        _AlphaScale("Alpha Sale", Range(0,1)) = 1
    }
    SubShader
    {
        Tags {"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"}
        Pass {
            Tags { "LightMode"="UniversalForward" }
            
            Cull Back  // 这里和书中顺序相反才能得到正确的结果 原因未知

            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha // SrcAlpha*SrcColor+(1-SrcAlpha)*DstColor
            
            CGPROGRAM
            #include "Lighting.cginc"

            #pragma vertex vert
            #pragma fragment frag
            
            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _AlphaScale;
            
            struct a2v
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
                float4 texcoord: TEXCOORD0;
            };

            struct v2f
            {
                float4 pos: SV_POSITION;
                float2 uv: TEXCOORD0;
                float3 worldNormal: TEXCOORD1;
                float3 worldPos: TEXCOORD2;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_WorldToObject, v.vertex).xyz;
                
                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                fixed4 texColor = tex2D(_MainTex, i.uv);
                
                fixed3 albedo = texColor.rgb * _Color.rgb;
                fixed3 ambient = albedo * half3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w);
                
                fixed3 diffuse = albedo * _LightColor0.rgb * saturate(dot(worldNormal, worldLightDir));

                //fixed3 halfDir = normalize(lightDir + viewDir);
                //fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(bump, halfDir)), _Gloss);

                fixed3 color = ambient + diffuse;
                
                return fixed4(color, texColor.a * _AlphaScale);
            }
            ENDCG
        }

        Pass {
            Tags { "LightMode"="SRPDefaultUnlit" }  // 让urp中进行多pass渲染的一种方法
            
            Cull Front

            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha // SrcAlpha*SrcColor+(1-SrcAlpha)*DstColor
            
            CGPROGRAM
            #include "Lighting.cginc"

            #pragma vertex vert
            #pragma fragment frag
            
            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _AlphaScale;
            
            struct a2v
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
                float4 texcoord: TEXCOORD0;
            };

            struct v2f
            {
                float4 pos: SV_POSITION;
                float2 uv: TEXCOORD0;
                float3 worldNormal: TEXCOORD1;
                float3 worldPos: TEXCOORD2;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_WorldToObject, v.vertex).xyz;
                
                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                fixed4 texColor = tex2D(_MainTex, i.uv);
                
                fixed3 albedo = texColor.rgb * _Color.rgb;
                fixed3 ambient = albedo * half3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w);
                
                fixed3 diffuse = albedo * _LightColor0.rgb * saturate(dot(worldNormal, worldLightDir));

                //fixed3 halfDir = normalize(lightDir + viewDir);
                //fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(bump, halfDir)), _Gloss);

                fixed3 color = ambient + diffuse;
                
                return fixed4(color, texColor.a * _AlphaScale);
            }
            ENDCG
        }
    }
    Fallback "Hidden/Universal Render Pipeline/FallbackError"
}
