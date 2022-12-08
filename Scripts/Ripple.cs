using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Ripple : MonoBehaviour
{
    private Renderer shader;
    private Vector3 curTransform;
    private float radius = 0f;
    private float step = 0f;
    private bool createRipple = false;

    void Start()
    {
        shader = gameObject.GetComponent<Renderer>();
        shader.sharedMaterial.SetFloat("_Radius", 0f);
        shader.sharedMaterial.SetFloat("_Step", 0f);
    }

    void Update()
    {
        curTransform = transform.position;

        if (createRipple) {
            shader.sharedMaterial.SetFloat("_Radius", radius);
            shader.sharedMaterial.SetFloat("_Step", step);
            radius += 2f * Time.deltaTime;
            step -= .2f * Time.deltaTime;
        }
        if (radius > 5) {
            createRipple = false;
        }
    }

    void HitEvent(RaycastHit hit)
    {
        float rayY = (hit.point.y - curTransform.y) * 2;
        float rayZ = -(hit.point.z - curTransform.z) * 2;
        shader.sharedMaterial.SetVector("_Center", new Vector4(rayZ, rayY, 0, 0));

        radius = 0f;
        step = 0.4f;
        createRipple = true;
    }
}
