using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class VaseColliderScript : MonoBehaviour
{
    public void HitEvent(RaycastHit hit)
    {
        Vector3 normal = hit.normal;

        VaseScript vaseScript = GetComponentInParent<VaseScript>();
        vaseScript.Push(normal);
    }
}
