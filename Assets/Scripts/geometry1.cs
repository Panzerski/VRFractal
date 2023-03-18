using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class geometry1 : Main
{
    public override GameObject Draw(GameObject obj,float d)
    {
        GameObject parent = new GameObject();
        parent.name = "rodzic rzedu " + d ;
        parent.AddComponent<MeshCombine>();
        parent.transform.SetParent(transform);
        
        Instantiate(obj, parent.transform);
        Instantiate(obj, new Vector3(parent.transform.position.x+1.4142f*d, parent.transform.position.y, parent.transform.position.z-0.8165f * d), parent.transform.rotation, parent.transform);
        Instantiate(obj, new Vector3(parent.transform.position.x+ 0.94281f*d, parent.transform.position.y+1.3333f * d, parent.transform.position.z), parent.transform.rotation, parent.transform);
        Instantiate(obj, new Vector3(parent.transform.position.x+1.4142f * d, parent.transform.position.y, parent.transform.position.z+0.8165f * d), parent.transform.rotation, parent.transform);

        parent.GetComponent<MeshCombine>().CombineMeshes();

        DestroyChildren(transform);

        return parent;
    }

    

    
}

