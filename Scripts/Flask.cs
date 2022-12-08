using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Flask : MonoBehaviour
{
    private bool inControl = false;
    private float moveSpeed = 0.4f;
    private float flaskRotationSpeed = 10.0f;
    private Vector3 flaskRotation;
    private Vector3 moveDirection;
    private GameObject container;
    private GameObject plane;

    // Rotation constants
    private float rotationSpeed = 500.0f;
    private float frictionConstant = 0.004f;
    private float restoringConstant = 0.005f;
    private Vector3 masterRotation;
    private Vector3 rotationImpulse;
    private Vector3 restoringForce;
    private Vector3 vectorDifference;
    public Transform planeEdge;

    // Bounce constants
    private float planeBaseline;
    private float heightDifference;
    private float bouncingSpeed = 2.0f;
    private float bounceRestoringConstant = 0.1f;
    private float bounceFrictionConstant = 0.004f;
    private Vector3 masterTranslate;
    private Vector3 pushPulse;
    private Vector3 restoringPush;


    void Start()
    {
        // Can I just assign these in the inspector?
        container = transform.GetChild(0).gameObject;
        plane = transform.GetChild(1).gameObject;

        flaskRotation = Vector3.zero;

        masterRotation = Vector3.zero;
        moveDirection = Vector3.zero;
        rotationImpulse = Vector3.zero;

        masterTranslate = Vector3.zero;
        pushPulse = Vector3.zero;
        planeBaseline = plane.transform.position.y;

    }

    void Update()
    {
        // Get input from keys
        FlaskInput();

        // Move the flask and reset the movement direction
        transform.Translate(moveDirection * moveSpeed);
        moveDirection = Vector3.zero;

        // Rotate the flask and reset the rotation direction
        container.transform.Rotate(flaskRotation * flaskRotationSpeed);
        flaskRotation = Vector3.zero;

        // Apply the push impulse to the master translate and reset it
        masterTranslate += pushPulse;
        pushPulse = Vector3.zero;
        // Calculate and apply restoring force
        planeBaseline = transform.position.y;
        heightDifference = plane.transform.position.y - planeBaseline;
        restoringPush = new Vector3(0.0f, -heightDifference, 0.0f) * bounceRestoringConstant;
        masterTranslate += restoringPush;
        // Apply friction
        masterTranslate += (-masterTranslate) * bounceFrictionConstant;
        // Move plane
        plane.transform.Translate(masterTranslate * Time.deltaTime * bouncingSpeed);

        // Apply the rotation impulse to the master rotation and reset it
        masterRotation += rotationImpulse;
        rotationImpulse = Vector3.zero;
        // Calculate restoring force, apply to master rotation
        vectorDifference = plane.transform.position - planeEdge.position;
        restoringForce = new Vector3(0.0f, 0.0f, vectorDifference.y) * restoringConstant;
        masterRotation += restoringForce;
        // Apply friction in opposition to the master rotation in every frame
        masterRotation += (-masterRotation) * frictionConstant;
        // Apply the master rotation to the clipping plane
        plane.transform.Rotate(masterRotation * Time.deltaTime * rotationSpeed);

        // Account for plane drift
        Vector3 drift = plane.transform.position - transform.position;
        if (Mathf.Abs(drift.x) > 0.1f || Mathf.Abs(drift.z) > 0.1f) {
            plane.transform.position = transform.position;
        }
    }

    private void FlaskInput()
    {
        // Right
        if (inControl && Input.GetKeyDown("l")) {
            // Set the movement direction
            moveDirection = Vector3.left; // Try using quaternions from the shooting video here
            // Generate a rotation impulse
            rotationImpulse = Vector3.forward;
            return;
        }
        // Left
        if (inControl && Input.GetKeyDown("j")) {
            moveDirection = Vector3.right;
            rotationImpulse = Vector3.back;
            return;
        }
        // Up
        if (inControl && Input.GetKeyDown("i")) {
            moveDirection = Vector3.up;
            pushPulse = Vector3.down;
            return;
        }
        // Down
        if (inControl && Input.GetKeyDown("k")) {
            moveDirection = Vector3.down;
            pushPulse = Vector3.up;
            return;
        }
        // Rotate Right
        if (inControl && Input.GetKeyDown("o")) {
            flaskRotation = Vector3.forward;
            rotationImpulse = Vector3.forward;
            return;
        }
        // Rotate Left
        if (inControl && Input.GetKeyDown("u")) {
            flaskRotation = Vector3.back;
            rotationImpulse = Vector3.back;
            return;
        }
    }

    private void HitEvent(RaycastHit hit)
    {
        inControl = !inControl;
    }
}
