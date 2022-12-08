using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LightswitchScript : MonoBehaviour
{
    private bool on;
    private Renderer renderer;
    public GameObject flickeringBulb;
    private FlickeringLightScript flickeringLightScript;

    void Start()
    {
        // Start the switch off, get the material color
        on = false;
        renderer = GetComponent<Renderer>();
        renderer.material.SetColor("_Color", Color.red);

        // Get the lightbulb script
        flickeringLightScript = flickeringBulb.GetComponent<FlickeringLightScript>();

        // Make sure the light starts as off
        flickeringLightScript.Switch(false);
    }

    public void HitEvent(RaycastHit hit)
    {
        Switch();
    }

    private void Switch()
    {
        on = !on; 
        
        if (on) {
            renderer.material.SetColor("_Color", Color.green);
            flickeringLightScript.Switch(on);
        }
        else {
            renderer.material.SetColor("_Color", Color.red);
            flickeringLightScript.Switch(on);
        }
    }
}
