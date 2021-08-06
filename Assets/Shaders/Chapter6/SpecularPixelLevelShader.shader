﻿// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// 逐像素高光
Shader "Unlit/Chapter6/SpecularPixelLevelShader"
{
    Properties
    {
        _Diffuse("Diffuse Color", Color) = (1, 1, 1, 1)
        _Specular("Specular Color", Color) = (1, 1, 1, 1)
        // 高光系数，控制高光区域。系数越大，区域越小
        _Gloss("Gloss", Range(8.0, 256)) = 20
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags { "LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL; 
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                fixed3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = normalize(mul(v.normal, (float3x3)(unity_WorldToObject)));
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                //获取光源方向
                fixed3 worldLightDiection = normalize(_WorldSpaceLightPos0.xyz);

                //计算漫反射
                fixed3 diffuse = _LightColor0.rgb * _Diffuse * saturate(dot(i.worldNormal, worldLightDiection));

                //计算光源方向关于法向量的反射向量
                fixed3 reflectDirection = normalize(reflect(-worldLightDiection, i.worldNormal));

                //计算观察向量
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);

                //计算高光
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(viewDir, reflectDirection)), _Gloss);
                
                fixed3 light = ambient + diffuse + specular;

                return fixed4(light, 1.0);
            }
            ENDCG
        }

    }
}