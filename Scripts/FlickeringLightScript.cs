using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FlickeringLightScript : MonoBehaviour
{
    private bool switchOn = false;
    private int randInt;
    private int lowRange = 0;
    private int highRange = 10;
    private float lastTime;
    private float curTime;

    private Light light;
    private Renderer renderer;

    void Start()
    {
        light = GetComponentInChildren<Light>();
        renderer = GetComponent<Renderer>();

        light.enabled = false;

        // Gets the time in seconds since start of game
        lastTime = Time.time;
    }

    void Update()
    {
        if (switchOn) {
            curTime = Time.time;

            // If enough time has passed, get a new randInt and update lastTime
            if (curTime - lastTime > 0.3f) {
                // Since range variables are ints: lowRange <= int < highRange
                randInt = Random.Range(lowRange, highRange);
                lastTime = Time.time;
            }
        
            if (randInt < 6) {
                renderer.material.SetColor("_Color", Color.yellow);
                light.enabled = true;
            }
            else {
                renderer.material.SetColor("_Color", Color.white);
                light.enabled = false;
            }
        }
        else {
            renderer.material.SetColor("_Color", Color.white);
            light.enabled = false;
        }
    }

    public void Switch(bool on)
    {
        if (on) {
            switchOn = true;
            lastTime = Time.time;
        }
        else {
            switchOn = false;
        }
    }

}
