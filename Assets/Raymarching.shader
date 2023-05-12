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
            uniform int _MaxIterations;
            uniform float _Accuracy;
            uniform float4 _sphere1, _box1;
            uniform float _handSize;
            uniform float3 _LightDir,_LightCol;
            uniform float _LightIntensity;
            uniform fixed3 _mainColor;
            uniform float2 _ShadowDistance;
            uniform float _ShadowIntensity;
            uniform float _ShadowPenumbra;

            uniform float3 _LConPos,_RConPos;


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
                float Hand1 = sdSphere(p - _LConPos, _handSize);
                float Hand2 = sdSphere(p - _RConPos, _handSize);

                return opU(opU(Sphere1,Box1),opU(Hand1,Hand2));
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

            float hardShadow(float3 ro, float3 rd, float mint, float maxt)
            {
                for (float t = mint; t < maxt;)
                {
                    float h = distanceField(ro+rd*t);
                    if (h < 0.001)
                    {
                        return 0.0;
                    }
                    t += h;
                }
                return 1.0;
            }

            float softShadow(float3 ro, float3 rd, float mint, float maxt, float k)
            {
                float result = 1.0;
                for (float t = mint; t < maxt;)
                {
                    float h = distanceField(ro + rd * t);
                    if (h < 0.001)
                    {
                        return 0.0;
                    }
                    result = min(result, k * h / t);
                    t += h;
                }
                return result;
            }

            uniform float _AoStepsize, _AoIntensity;
            uniform int _AoIterations;

            float AmbientOcclusion(float3 p, float3 n)
            {
                float step = _AoStepsize;
                float ao = 0.0;
                float dist;
                for (int i = 1; i <= _AoIterations; i++)
                {
                    dist = step * i;
                    ao +=max(0.0,(dist - distanceField(p + n * dist)) / dist);
                }
                return (1.0 - ao * _AoIntensity);
            }

            float3 Shading(float3 p, float3 n)
            {
                float3 result;
                float3 color = _mainColor.rgb;
                float3 light = (_LightCol*dot(-_LightDir, n)*0.5+0.5)*_LightIntensity;

                float shadow = softShadow(p, -_LightDir, _ShadowDistance.x, _ShadowDistance.y,_ShadowPenumbra) * 0.5 + 0.5;
                shadow = max(0.0,pow(shadow, _ShadowIntensity));
                float ao = AmbientOcclusion(p, n);

                result = color * light * shadow * ao;

                return result;
            }

            fixed4 raymarching(float3 ro, float3 rd
                //,float depth
            )
            {
                fixed4 result = fixed4(1, 1, 1, 1);

                const int max_iteration = _MaxIterations;

                float t = 0;
                for (int i = 0; i < max_iteration; i++)
                {
                    if (t > _maxDistance
                        //|| t>=depth
                        )
                    {
                        //result = fixed4(rd, 1);
                        result = fixed4(0.2,0.2,0.2,1);

                        break;
                    }

                    float3 p = ro + rd * t;

                    float d = distanceField(p);
                    if (d < _Accuracy)
                    {
                        float3 n = getNormal(p);
                        float3 s = Shading(p, n);

                        result = fixed4(_mainColor.rgb*s, 1);
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
