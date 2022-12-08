using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class VaseScript : MonoBehaviour
{
    private float pushStrength = 0.4f;
    private float springConstant = 0.005f;
    private float frictionConstant = 0.002f;
    private float masterRotationStrength = 1000.0f;
    private Vector3 pushForce;
    private Vector3 vectorDifference;
    private Vector3 restoringForce;
    private Vector3 masterRotation;
    private Vector3 friction;
    public Transform topOfVase;

    void Start()
    {
        pushForce = Vector3.zero;
        masterRotation = Vector3.zero;
    }

    void Update()
    {
        // Push() gives a force in the pushDirection
        // That force should get added on to some kind of global rotation vector
        masterRotation += pushForce; // Debug.Log("MasterRotation: " + masterRotation);

        // Once it gets added on, reset the push force to zero
        pushForce = Vector3.zero;

        // In very frame, calculate the restoring force and add it to the global rotation vector
        vectorDifference = transform.position - topOfVase.transform.position; // Debug.Log("Difference: " + vectorDifference);
        // Explanation: if the top of the vase is offset in the z direction, we want to rotate about the x-axis
        restoringForce = (new Vector3(vectorDifference.z, 0.0f, -vectorDifference.x)) * springConstant;
        masterRotation += restoringForce;

        // Apply friction in opposition to the master rotation in every frame
        friction = (-masterRotation) * frictionConstant;
        masterRotation += friction;

        // Apply the rotation vector to the transform in every frame
        transform.Rotate(masterRotation * Time.deltaTime * masterRotationStrength);
    }

    public void Push(Vector3 normal)
    {
        // Turn the normal into the direction the vase should move
        Vector3 pushDirection = new Vector3(-normal.z, 0.0f, normal.x); // Debug.Log("Push: " + pushDirection);

        // Create a push force based on the push direction
        pushForce = pushDirection * pushStrength;
    }
}
