using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BoxArray : MonoBehaviour
{
    private GameObject cube;
    private GameObject[] cubeArray;
    private Vector3 parentPosition;
    private Vector3 newPosition;
    private int size = 5;
    private float height = 1f;
    private float amplitude = 0.2f;
    private float speed = 1.5f;

    void Start()
    {
        // Initialize stuff
        cube = transform.GetChild(0).gameObject;
        parentPosition = transform.position;
        cubeArray = new GameObject[size*size];

        // Populate array with clones of cube
        for (int i = 0; i < size; i++) {
            for (int j = 0; j < size; j++) {
            newPosition = parentPosition + new Vector3(i/2f, height, j/2f);
            GameObject newCube = Instantiate(cube, newPosition, Quaternion.identity, transform);
            cubeArray[(i * 5) + j] = newCube;
            }
        }

        // Hide the original cube
        cube.GetComponent<Renderer>().enabled = false;
    }

    void Update()
    {
        // Wave effect
        for (int i = 0; i < cubeArray.Length; i++) {
            GameObject curCube = cubeArray[i]; // Get the cube from the array
            Vector3 pos = curCube.transform.position; // Can't directly modify t.position so put it in a vector3
            pos.y = height + Mathf.Sin((Time.time + pos.x + pos.z) * speed) * amplitude; // Sin based on time and position
            curCube.transform.position = pos; // Set the position to a new vector3
        }
    }
}
