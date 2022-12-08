using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerScript : MonoBehaviour
{
    private float playerSpeed = 6.0f;
    private float floatSpeed = 2.0f;
    private float lookSpeed = 1.8f;
    private bool mouseClick;
    private bool newMovementBool = false;
    private float rotationHorizontalLight = 0.0f;
    private float rotationVerticalLight = 0.0f;
    private float rotationHorizontalCamera = 0.0f;
    private float rotationVerticalCamera = 0.0f;
    private float newCameraSpeed = 0.1f;
    private float range = 6f;

    public Light light;
    public Light laserPointer;
    public Transform lightTransform;
    public Transform cameraTransform;
    private CharacterController characterController;

    Vector3 moveDirection = Vector3.zero;

    void Start()
    {
        // Moving and rotating the controller moves the player
        characterController = GetComponent<CharacterController>();

        // Initialize light and laser pointer off
        light.enabled = false;
        laserPointer.enabled = false;

        // Lock cursor
        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;
    }

    void Update()
    {
        // Switch control scheme
        if (Input.GetKeyDown("0")) {
            newMovementBool = !newMovementBool;
        }
        // Use my new control scheme
        if (newMovementBool) {
            MovementNew();
            FlashlightNew();
            CameraNew();
        }
        // Use regular fps control scheme
        else {
            Movement();
            Camera();
            Flashlight();
            Interact();
        }
    }

    private void MovementNew()
    {
        // forward is (0,0,1)
        // The transform code here makes it so w always goes forward
        Vector3 forward = transform.TransformDirection(Vector3.forward);

        // WASD inputs
        float forwardSpeed = playerSpeed * Input.GetAxis("Vertical");

        // Combine the x and y movement vectors into one vector
        moveDirection = (forward * forwardSpeed);
        
        // Move the player
        characterController.Move(moveDirection * Time.deltaTime);

        // Horizontal rotation
        if (Input.GetKeyDown("d")) {
            transform.Rotate(0, 90, 0);
        }
        if (Input.GetKeyDown("a")) {
            transform.Rotate(0, -90, 0);
        }
    }

    private void FlashlightNew()
    {
        // Horizontal rotation input
        rotationHorizontalLight += Input.GetAxis("Mouse X");
        rotationHorizontalLight = Mathf.Clamp(rotationHorizontalLight, -45, 45);
        
        // Vertical rotation input
        rotationVerticalLight -= Input.GetAxis("Mouse Y");
        rotationVerticalLight = Mathf.Clamp(rotationVerticalLight, -25, 25);

        // Rotate flashlight
        lightTransform.localRotation = Quaternion.Euler(rotationVerticalLight, rotationHorizontalLight, 0);

        // Flashlight switch
        mouseClick = Input.GetMouseButtonDown(0);
        if (mouseClick) {
            light.enabled = !light.enabled;
        }
    }

    private void CameraNew() {
        // Horizontal camera rotation from flashlight
        if (lightTransform.localRotation.y > 0.27) {
            rotationHorizontalCamera += newCameraSpeed;
            rotationHorizontalCamera = Mathf.Clamp(rotationHorizontalCamera, -15, 15);
        }
        else if (lightTransform.localRotation.y < -0.27) {
            rotationHorizontalCamera -= newCameraSpeed;
            rotationHorizontalCamera = Mathf.Clamp(rotationHorizontalCamera, -15, 15);
        }

        // Vertical camera rotation from flashlight
        if (lightTransform.localRotation.x < -0.14) {
            rotationVerticalCamera -= newCameraSpeed;
            rotationVerticalCamera = Mathf.Clamp(rotationVerticalCamera, -25, 25);
        }
        else if (lightTransform.localRotation.x > 0.14) {
            rotationVerticalCamera += newCameraSpeed;
            rotationVerticalCamera = Mathf.Clamp(rotationVerticalCamera, -25, 25);
        }

        // Apply rotations
        cameraTransform.localRotation = Quaternion.Euler(rotationVerticalCamera, rotationHorizontalCamera, 0);
    }

    private void Movement() {
        // Transform the local "forward" into global "forward"
        Vector3 forward = transform.TransformDirection(Vector3.forward);
        Vector3 right = transform.TransformDirection(Vector3.right);

        // WASD inputs
        float curSpeedX = playerSpeed * Input.GetAxis("Vertical");
        float curSpeedY = playerSpeed * Input.GetAxis("Horizontal");

        // Combine the x and y movement vectors into one vector
        moveDirection = (forward * curSpeedX) + (right * curSpeedY);

        // Move the player
        characterController.Move(moveDirection * Time.deltaTime);

        // Floating
        if (Input.GetKey("space")) {
            characterController.Move(floatSpeed * Vector3.up * Time.deltaTime);
        }
        if (Input.GetKey("left shift")) {
            characterController.Move(floatSpeed * Vector3.down * Time.deltaTime);
        }
    }

    private void Camera() {
        // Horizontal rotation (about y-axis)
        transform.Rotate(0, Input.GetAxis("Mouse X") * lookSpeed, 0);

        // Vertical rotation
        rotationVerticalCamera += -Input.GetAxis("Mouse Y") * lookSpeed;
        rotationVerticalCamera = Mathf.Clamp(rotationVerticalCamera, -30, 30); // must hard-code?
        cameraTransform.localRotation = Quaternion.Euler(rotationVerticalCamera, 0, 0);
    }

    private void Flashlight() {
        mouseClick = Input.GetMouseButtonDown(0);
        if (mouseClick) {
            laserPointer.enabled = !laserPointer.enabled;
        }
    }

    private void Interact()
    {
        if (Input.GetKeyDown("e")) {
            // Use the camera's "forward" to direct the raycast
            Vector3 forward = cameraTransform.forward;
            // Use the camera's position to position the raycast
            Vector3 position = cameraTransform.position;
            // Stores info about what the raycast hit
            RaycastHit hit;
            // Game object that was hit
            GameObject hitObject;

            // Shoots out a raycast with given range from current position and direction, stores it in hit
            if (Physics.Raycast(position, forward, out hit, range)) {
                // Pass the GameObject we hit into hitObject
                hitObject = hit.collider.gameObject;

                // If we hit an object, call the HitEvent method in one of the scripts
                if (hitObject != null) {
                    hitObject.SendMessage("HitEvent", hit, SendMessageOptions.DontRequireReceiver);
                }
            }

        }
        if (Input.GetKeyDown("1")) {
            Camera postCamera = GameObject.FindGameObjectWithTag("PostCamera").GetComponent<Camera>();
            postCamera.GetComponent<PostEffectsController>().whichShader = 1;
        }
        if (Input.GetKeyDown("2")) {
            Camera postCamera = GameObject.FindGameObjectWithTag("PostCamera").GetComponent<Camera>();
            postCamera.GetComponent<PostEffectsController>().whichShader = 2;
        }
        if (Input.GetKeyDown("3")) {
            Camera postCamera = GameObject.FindGameObjectWithTag("PostCamera").GetComponent<Camera>();
            postCamera.GetComponent<PostEffectsController>().whichShader = 3;
        }
        if (Input.GetKeyDown("4")) {
            Camera postCamera = GameObject.FindGameObjectWithTag("PostCamera").GetComponent<Camera>();
            postCamera.GetComponent<PostEffectsController>().whichShader = 4;
        }
    }
}
