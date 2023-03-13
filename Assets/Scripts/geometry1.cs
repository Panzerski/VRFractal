using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class geometry1 : MonoBehaviour
{
    public GameObject geo;
    public int p;

    void Start()
    {
        int i = 0;
        while(i<=p)
        {
            geo = Draw(geo, Mathf.Pow(2,i));
            i++;
        }

        GetComponent<MeshCombine>().CombineMeshes();
    }

    GameObject Draw(GameObject obj,float d)
    {
        GameObject parent = new GameObject();
        parent.name = "rodzic rzedu " + d ;
        parent.AddComponent<MeshCombine>();
        parent.transform.SetParent(transform);
        Instantiate(obj, parent.transform);
        Instantiate(obj, new Vector3(parent.transform.position.x + d, parent.transform.position.y, parent.transform.position.z), Quaternion.identity, parent.transform);
        Instantiate(obj, new Vector3(parent.transform.position.x + d, parent.transform.position.y, parent.transform.position.z + d), Quaternion.identity, parent.transform);
        Instantiate(obj, new Vector3(parent.transform.position.x, parent.transform.position.y, parent.transform.position.z + d), Quaternion.identity, parent.transform);
        Instantiate(obj, new Vector3(parent.transform.position.x + d/2, parent.transform.position.y + d, parent.transform.position.z + d/2), Quaternion.identity, parent.transform);
        parent.GetComponent<MeshCombine>().CombineMeshes();
        //CombineMeshes(parent);

        return parent;
    }

    
}

