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

    [Header("Signed Distance Field")]
    public Color mainColor;
    public Vector4 sphere1, box1;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(!_raymarchMaterial)
        {
            Graphics.Blit(source, destination);
            return;
        }

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
        
        _raymarchMaterial.SetVector("_sphere1", sphere1);
        _raymarchMaterial.SetVector("_box1", box1);
        _raymarchMaterial.SetColor("_mainColor", mainColor);

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
