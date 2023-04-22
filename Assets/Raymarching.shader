// Upgrade NOTE: replaced 'UNITY_INSTANCE_ID' with 'UNITY_VERTEX_INPUT_INSTANCE_ID'

Shader "Raymarching"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma target 3.0

            #include "UnityCG.cginc"
            #include "DistanceFunctions.cginc"

            sampler2D _MainTex;
            
            //uniform sampler2D _CameraDepthTexture;
            uniform float4x4 _CamFrustum, _CamToWorldMatrix;
            uniform float _maxDistance;
            uniform float4 _sphere1, _box1;
            uniform float3 _LightDir;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 ray : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                half index = v.vertex.z;
                v.vertex.z = 0;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                o.ray = _CamFrustum[(int)index].xyz;
                o.ray /= abs(o.ray.z);
                o.ray = mul(_CamToWorldMatrix, o.ray);


                return o;
            }

            float distanceField(float3 p)
            {
                float Sphere1 = sdSphere(p - _sphere1.xyz, _sphere1.w);
                float Box1 = sdBox(p - _box1.xyz, _box1.www);

                return Sphere1;
            }

            float3 getNormal(float3 p)
            {
                const float2 offset = float2(0.001, 0.0);
                float3 n = float3(
                    distanceField(p + offset.xyy) - distanceField(p - offset.xyy),
                    distanceField(p + offset.yxy) - distanceField(p - offset.yxy),
                    distanceField(p + offset.yyx) - distanceField(p - offset.yyx)
                    );
                return normalize(n);
            }

            fixed4 raymarching(float3 ro, float3 rd
                //,float depth
            )
            {
                fixed4 result = fixed4(1, 1, 1, 1);

                //mo�liwe �e wi�cej
                const int max_iteration = 128;

                float t = 0;
                for (int i = 0; i < max_iteration; i++)
                {
                    if (t > _maxDistance 
                        //|| t>=depth
                        )
                    {
                        result = fixed4(rd, 1);
                        break;
                    }

                    float3 p = ro + rd * t;

                    float d = distanceField(p);
                    if (d < 0.01)
                    {
                        float3 n = getNormal(p);
                        float light = dot(-_LightDir, n);

                        //result = fixed4(fixed3(1,1,1)*light,1);
                        result = fixed4(1,1,1,1)* light;
                        break;
                    }

                    t += d;

                }


                return result;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //float depth = LinearEyeDepth(tex2D(_CameraDepthTexture, i.uv).r);
                //depth *= length(i.ray);
                //fixed3 col = tex2D(_MainTex, i.uv);
                float3 rayDirection = normalize(i.ray.xyz);
                float3 rayOrigin = _WorldSpaceCameraPos;
                fixed4 result = raymarching(rayOrigin, rayDirection
                   // ,depth
                );
                //return fixed4(col*(1.0-result.w)+result.xyz*result.w ,1.0);
                return result;
            }
            ENDCG
        }
    }
}
