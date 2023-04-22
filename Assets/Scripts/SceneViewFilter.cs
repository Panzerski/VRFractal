using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif

public class MonoBehaviour : UnityEngine.MonoBehaviour
{
#if UNITY_EDITOR
    bool hasChanged = false;

    public virtual void OnValidate()
    {
        hasChanged = true;
    }

    static MonoBehaviour()
    {
        SceneView.duringSceneGui += CheckMe;
    }

    static void CheckMe(SceneView sv)
    {
        if (Event.current.type != EventType.Layout)
            return;
        if (!Camera.main)
            return;
        // Get a list of everything on the main camera that should be synced.
        MonoBehaviour[] cameraFilters = Camera.main.GetComponents<MonoBehaviour>();
        MonoBehaviour[] sceneFilters = sv.camera.GetComponents<MonoBehaviour>();

        // Let's see if the lists are different lengths or something like that. 
        // If so, we simply destroy all scene filters and recreate from maincame
        if (cameraFilters.Length != sceneFilters.Length)
        {
            Recreate(sv);
            return;
        }
        for (int i = 0; i < cameraFilters.Length; i++)
        {
            if (cameraFilters[i].GetType() != sceneFilters[i].GetType())
            {
                Recreate(sv);
                return;
            }
        }

        // Ok, WHICH filters, or their order hasn't changed.
        // Let's copy all settings for any filter that has changed.
        for (int i = 0; i < cameraFilters.Length; i++)
            if (cameraFilters[i].hasChanged || sceneFilters[i].enabled != cameraFilters[i].enabled)
            {
                EditorUtility.CopySerialized(cameraFilters[i], sceneFilters[i]);
                cameraFilters[i].hasChanged = false;
            }
    }

    static void Recreate(SceneView sv)
    {
        MonoBehaviour filter;
        while (filter = sv.camera.GetComponent<MonoBehaviour>())
            DestroyImmediate(filter);

        foreach (MonoBehaviour f in Camera.main.GetComponents<MonoBehaviour>())
        {
            MonoBehaviour newFilter = sv.camera.gameObject.AddComponent(f.GetType()) as MonoBehaviour;
            EditorUtility.CopySerialized(f, newFilter);
        }
    }
#endif
}