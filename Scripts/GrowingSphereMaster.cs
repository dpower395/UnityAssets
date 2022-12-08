using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GrowingSphereMaster : MonoBehaviour
{
    private List<Transform> sphereList = new List<Transform>();

    void Start()
    {
        // Get all the children spheres
        foreach (Transform sphere in transform) {
            sphereList.Add(sphere);
        }
    }

    void Update()
    {
        // For each sphere in the list
        foreach (Transform sphere1 in sphereList) {
            // Get the position and radius
            Vector3 curPosition = sphere1.position;
            float curRadius = Mathf.Abs(sphere1.localScale.x * 0.5f);

            // For each other sphere in the list
            foreach (Transform sphere2 in sphereList) {
                if (sphere2.position != curPosition) {
                    // Get the radius and the distance between two spheres
                    float otherRadius = Mathf.Abs(sphere2.localScale.x * 0.5f);
                    float sphereDistance = (curPosition - sphere2.position).magnitude;

                    // If the sum of radii is >= distance
                    if (curRadius + otherRadius >= sphereDistance) {
                        // Send signal to reverse growth
                        sphere1.GetComponent<GrowingSphere>().SphereCollision();
                        sphere2.GetComponent<GrowingSphere>().SphereCollision();
                        // Activate sphere sound
                        sphere1.GetComponent<GrowingSphere>().PlaySound();
                        sphere1.GetComponent<GrowingSphere>().PlaySound();
                    }
                }
            }
        }
            
            
    }
}
