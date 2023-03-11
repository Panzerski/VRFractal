using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(MeshFilter))]
[RequireComponent(typeof(MeshRenderer))]
public class geometry1 : MonoBehaviour
{
    public GameObject geo;
   
    void Start()
    {
        Draw(geo, 1);
        
        //CombineMeshes();
    }
    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.J))
        {
            CombineMeshes();
        }
    }

    void Draw(GameObject obj,float d)
    {
        float d2 = d;
        Instantiate(obj, transform);
        Instantiate(obj, new Vector3(transform.position.x + d2, transform.position.y, transform.position.z), Quaternion.identity, transform);
        Instantiate(obj, new Vector3(transform.position.x + d2, transform.position.y, transform.position.z + d2), Quaternion.identity, transform);
        Instantiate(obj, new Vector3(transform.position.x, transform.position.y, transform.position.z + d2), Quaternion.identity, transform);
        Instantiate(obj, new Vector3(transform.position.x + d2/2, transform.position.y + d, transform.position.z + d2/2), Quaternion.identity, transform);
    }

    void CombineMeshes()
    {
        MeshFilter[] meshFilters = GetComponentsInChildren<MeshFilter>();
        CombineInstance[] combine = new CombineInstance[meshFilters.Length];

        int i = 0;
        while (i < meshFilters.Length)
        {
            combine[i].mesh = meshFilters[i].sharedMesh;
            combine[i].transform = meshFilters[i].transform.localToWorldMatrix;
            meshFilters[i].gameObject.SetActive(false);

            i++;
        }
        var meshFilter = transform.GetComponent<MeshFilter>();
        meshFilter.mesh = new Mesh();
        meshFilter.mesh.CombineMeshes(combine);
        transform.gameObject.SetActive(true);

        transform.localScale = new Vector3(1, 1, 1);
        transform.rotation = Quaternion.identity;
        transform.position = Vector3.zero;
    }
}

