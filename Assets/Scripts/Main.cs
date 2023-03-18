using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Main : MonoBehaviour
{
    public GameObject geo;
    public int p;
    
    void Start()
    {
        int i = 0;
        while (i <= p)
        {
            geo = Draw(geo, Mathf.Pow(2, i));
            i++;
        }
        GetComponent<MeshCombine>().CombineMeshes();
    }

    public virtual GameObject Draw(GameObject obj, float d){ return gameObject; }
    public void DestroyChildren(Transform transform)
    {
        foreach (Transform child in transform)
        {
            Destroy(child.gameObject);
        }
    }
}
