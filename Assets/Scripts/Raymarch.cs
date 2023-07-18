using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
[ExecuteInEditMode]
public class Raymarch : MonoBehaviour
{
    [SerializeField]
    private Shader _shader;
    public Material _raymarchMaterial
    {
        get
        {
            if(!_raymarchMat && _shader)
            {
                _raymarchMat = new Material(_shader);
                _raymarchMat.hideFlags = HideFlags.HideAndDontSave;
            }
            return _raymarchMat;
        }
    }
    private Material _raymarchMat;
    public Camera _camera
    {
        get
        {
            if(!_cam)
            {
                _cam = GetComponent<Camera>();
            }
            return _cam;
        }
    }
    private Camera _cam;

    [Header("Controllers")]
    public Transform conL;
    public Transform conR;

    [Header("MainParameters")]
    public float maxDistance;
    [Range(1, 300)]
    public int maxIterations;
    [Range(1f, 0.0001f)]
    public float Accuracy;

    [Header("Directional Light")]
    public Transform directionalLight;
    public Color LightCol;
    [Range(0, 10)]
    public float LightIntensity;

    [Header("Shadow")]
    [Range(0, 4)]
    public float ShadowIntensity;
    public Vector2 ShadowDistance;
    [Range(1,128)]
    public float ShadowPenumbra;

    [Header("Occlusion")]
    [Range(0.01f,10.0f)]
    public float AoStepsize;
    [Range(0.0f, 1.0f)]
    public float AoIntensity;
    [Range(1, 5)]
    public int AoIterations;

    [Header("Distance Fog")]
    public Color fogColor;
    [Range(0.0f,1.0f)]
    public float fogDensity;

    [Header("Signed Distance Field: Main")]
    public Color mainColor;
    public float handScale;
    [Range(1,8)]
    public int fractalIndex;

    [Header("Signed Distance Field: Fractal")]
    public Vector3 Position;
    public Vector3 Rot1;
    public Vector3 Rot2;
    //Skala Iteracji
    public float Scale;
    public Vector3 Offset;
    public float Offset2;
    public int Iterations;
    //Skala Ca³oœci
    public float Scale2;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(!_raymarchMaterial)
        {
            Graphics.Blit(source, destination);
            return;
        }
        _raymarchMaterial.SetColor("_FogColor", fogColor);
        _raymarchMaterial.SetFloat("_FogDensity", fogDensity);

        _raymarchMaterial.SetVector("_LConPos",conL.position);
        _raymarchMaterial.SetVector("_RConPos", conR.position);

        _raymarchMaterial.SetVector("_LightDir", directionalLight ? directionalLight.forward : Vector3.down);
        _raymarchMaterial.SetMatrix("_CamFrustum", CamFrustum(_camera));
        _raymarchMaterial.SetMatrix("_CamToWorldMatrix", _camera.cameraToWorldMatrix);

        _raymarchMaterial.SetInt("_AoIterations", AoIterations);
        _raymarchMaterial.SetFloat("_AoStepsize", AoStepsize);
        _raymarchMaterial.SetFloat("_AoIntensity", AoIntensity);

        _raymarchMaterial.SetInt("_MaxIterations", maxIterations);
        _raymarchMaterial.SetFloat("_Accuracy", Accuracy);
        _raymarchMaterial.SetFloat("_maxDistance", maxDistance);

        _raymarchMaterial.SetColor("_LightCol", LightCol);
        _raymarchMaterial.SetFloat("_LightIntensity", LightIntensity);

        _raymarchMaterial.SetFloat("_ShadowIntensity", ShadowIntensity);
        _raymarchMaterial.SetVector("_ShadowDistance", ShadowDistance);
        _raymarchMaterial.SetFloat("_ShadowPenumbra", ShadowPenumbra);
        
        _raymarchMaterial.SetColor("_mainColor", mainColor);
        _raymarchMaterial.SetFloat("_handSize", handScale);

        _raymarchMaterial.SetInt("_fractalIndex", fractalIndex);

        _raymarchMaterial.SetVector("Rot1", Rot1);
        _raymarchMaterial.SetVector("Rot2", Rot2);
        _raymarchMaterial.SetVector("Position", Position);
        _raymarchMaterial.SetFloat("Scale", Scale);
        _raymarchMaterial.SetFloat("Scale2", Scale2);
        _raymarchMaterial.SetVector("Offset", Offset);
        _raymarchMaterial.SetFloat("Offset2", Offset2);
        _raymarchMaterial.SetInt("Iterations", Iterations);

        RenderTexture.active = destination;
       // _raymarchMaterial.SetTexture("_MainTex",source);

        GL.PushMatrix();
        GL.LoadOrtho();
        _raymarchMaterial.SetPass(0);
        GL.Begin(GL.QUADS);

        //BL
        GL.MultiTexCoord2(0, 0.0f, 0.0f);
        GL.Vertex3(0.0f, 0.0f, 3.0f);
        //BR
        GL.MultiTexCoord2(0, 1.0f, 0.0f);
        GL.Vertex3(1.0f, 0.0f, 2.0f);
        //TR
        GL.MultiTexCoord2(0, 1.0f, 1.0f);
        GL.Vertex3(1.0f, 1.0f, 1.0f);
        //TL
        GL.MultiTexCoord2(0, 0.0f, 1.0f);
        GL.Vertex3(0.0f, 1.0f, 0.0f);

        GL.End();
        GL.PopMatrix();
    }

    private Matrix4x4 CamFrustum(Camera cam)
    {
        Matrix4x4 frustum = Matrix4x4.identity;
        float fov = Mathf.Tan((cam.fieldOfView * 0.5f) * Mathf.Deg2Rad);

        Vector3 goUp = Vector3.up * fov;
        Vector3 goRight = Vector3.right * fov * cam.aspect;

        Vector3 TL = (-Vector3.forward - goRight + goUp);
        Vector3 TR = (-Vector3.forward + goRight + goUp);
        Vector3 BR = (-Vector3.forward + goRight - goUp);
        Vector3 BL = (-Vector3.forward - goRight - goUp);

        frustum.SetRow(0, TL);
        frustum.SetRow(1, TR);
        frustum.SetRow(2, BR);
        frustum.SetRow(3, BL);

        return frustum;
    }
}
