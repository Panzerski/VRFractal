using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
[ExecuteInEditMode]
public class Raymarch : MonoBehaviour
{
    [SerializeField]
    private Shader shader;

    public Material material
    {
        get
        {
            if(!raymarchMaterial && shader)
            {
                raymarchMaterial = new Material(shader);
                raymarchMaterial.hideFlags = HideFlags.HideAndDontSave;
            }
            return raymarchMaterial;
        }
    }

    private Material raymarchMaterial;

    public Camera _camera
    {
        get
        {
            if(!cam)
            {
                cam = GetComponent<Camera>();
            }
            return cam;
        }
    }
    private Camera cam;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(!material)
        {
            Graphics.Blit(source, destination);
            return;
        }

        material.SetMatrix("_CamFrustum",CamFrustum(_camera));
        material.SetMatrix("_CamToWorld",_camera.cameraToWorldMatrix);
        material.SetVector("_CamWorldSpace",_camera.transform.position);

        RenderTexture.active = destination;
        GL.PushMatrix();
        GL.LoadOrtho();
        material.SetPass(0);
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
        GL.Vertex3(0.0f, 1.0f, 2.0f);

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
        Vector3 BL = (-Vector3.forward - goRight - goUp);
        Vector3 BR = (-Vector3.forward + goRight - goUp);

        frustum.SetRow(0, TL);
        frustum.SetRow(1, TR);
        frustum.SetRow(2, BR);
        frustum.SetRow(3, BL);

        return frustum;
    }
}
