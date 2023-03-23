using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Main : MonoBehaviour
{
    public GameObject geo;
    GameObject temp;
    public int p;
    public static bool first;

    void Start()
    {
        first=true;
        int i = 0;

        //Instantiate(geo, transform);
        while (i <= p)
        {
            if(first)
            {
                geo = Draw(geo, Mathf.Pow(2, i));
                first=false;
            }
            else
            {
                temp = geo;
                Destroy(geo);
                geo = Draw(temp, Mathf.Pow(2, i));
            }
            
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
