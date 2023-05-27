using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class Main : UnityEngine.MonoBehaviour
{
    public GameObject geo;
    GameObject temp;
    public int p;
    public static bool first;
    public int n;

    void Start()
    {
        first = true;
        int i = 0;

        while (i <= p)
        {
            if (first)
            {
                geo = Draw(geo, Mathf.Pow(n, i));
                first = false;
            }
            else
            {
                temp = geo;
                Destroy(geo);
                geo = Draw(temp, Mathf.Pow(n, i));
            }

            i++;
        }
        GetComponent<MeshCombine>().CombineMeshes();
    }

    public virtual GameObject Draw(GameObject obj, float d) { return gameObject; }
    public void DestroyChildren(Transform transform)
    {
        foreach (Transform child in transform)
        {
            Destroy(child.gameObject);
        }
    }
}
