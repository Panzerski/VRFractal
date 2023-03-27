using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class geometry2 : Main
{
    public override GameObject Draw(GameObject obj, float d)
    {
        //n = 3;
        GameObject parent = new GameObject();
        parent.name = "rodzic rzedu " + d;
        parent.AddComponent<MeshCombine>();
        parent.transform.SetParent(transform);

        Instantiate(obj, parent.transform); //0,0,0
        Instantiate(obj, new Vector3(parent.transform.position.x + d, parent.transform.position.y, parent.transform.position.z), parent.transform.rotation, parent.transform); //1,0,0
        Instantiate(obj, new Vector3(parent.transform.position.x + 2 * d, parent.transform.position.y, parent.transform.position.z), parent.transform.rotation, parent.transform); //2,0,0
        Instantiate(obj, new Vector3(parent.transform.position.x, parent.transform.position.y+d, parent.transform.position.z), parent.transform.rotation, parent.transform); //0,1,0
        Instantiate(obj, new Vector3(parent.transform.position.x, parent.transform.position.y+2*d, parent.transform.position.z), parent.transform.rotation, parent.transform); //0,2,0
        Instantiate(obj, new Vector3(parent.transform.position.x, parent.transform.position.y, parent.transform.position.z+d), parent.transform.rotation, parent.transform); //0,0,1
        Instantiate(obj, new Vector3(parent.transform.position.x, parent.transform.position.y, parent.transform.position.z+2*d), parent.transform.rotation, parent.transform); //0,0,2
        Instantiate(obj, new Vector3(parent.transform.position.x+2*d, parent.transform.position.y+2*d, parent.transform.position.z+2*d), parent.transform.rotation, parent.transform); //2,2,2
        Instantiate(obj, new Vector3(parent.transform.position.x+2*d, parent.transform.position.y+2*d, parent.transform.position.z+d), parent.transform.rotation, parent.transform); //2,2,1
        Instantiate(obj, new Vector3(parent.transform.position.x+2*d, parent.transform.position.y+2*d, parent.transform.position.z), parent.transform.rotation, parent.transform); //2,2,0
        Instantiate(obj, new Vector3(parent.transform.position.x + 2 * d, parent.transform.position.y + d, parent.transform.position.z+2*d), parent.transform.rotation, parent.transform); //2,1,2
        Instantiate(obj, new Vector3(parent.transform.position.x + 2 * d, parent.transform.position.y + d, parent.transform.position.z), parent.transform.rotation, parent.transform); //2,1,0
        Instantiate(obj, new Vector3(parent.transform.position.x + 2 * d, parent.transform.position.y, parent.transform.position.z+d), parent.transform.rotation, parent.transform); //2,0,1
        Instantiate(obj, new Vector3(parent.transform.position.x + 2 * d, parent.transform.position.y, parent.transform.position.z+2*d), parent.transform.rotation, parent.transform); //2,0,2
        Instantiate(obj, new Vector3(parent.transform.position.x + d, parent.transform.position.y, parent.transform.position.z+2*d), parent.transform.rotation, parent.transform); //1,0,2
        Instantiate(obj, new Vector3(parent.transform.position.x + d, parent.transform.position.y + 2 * d, parent.transform.position.z), parent.transform.rotation, parent.transform); //1,2,0
        Instantiate(obj, new Vector3(parent.transform.position.x + d, parent.transform.position.y + 2 * d, parent.transform.position.z+2*d), parent.transform.rotation, parent.transform); //1,2,2
        Instantiate(obj, new Vector3(parent.transform.position.x, parent.transform.position.y + 2 * d, parent.transform.position.z+2*d), parent.transform.rotation, parent.transform); //0,2,2
        Instantiate(obj, new Vector3(parent.transform.position.x, parent.transform.position.y + 2 * d, parent.transform.position.z+d), parent.transform.rotation, parent.transform); //0,2,1
        Instantiate(obj, new Vector3(parent.transform.position.x, parent.transform.position.y + d, parent.transform.position.z+2*d), parent.transform.rotation, parent.transform); //0,1,2

        parent.GetComponent<MeshCombine>().CombineMeshes();

        DestroyChildren(transform);

        return parent;
    }
}
