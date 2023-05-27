using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.InputSystem;

public class InputHandler : MonoBehaviour
{
    public InputActionReference actionReference = null;

    private void Update()
    {
        actionReference.action.performed += ToMenu;
    }

    public void ToMenu(InputAction.CallbackContext context)
    {
        SceneManager.LoadSceneAsync("MainMenu");
    }
}
