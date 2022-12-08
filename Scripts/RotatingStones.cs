using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotatingStones : MonoBehaviour
{
    private float rotateSpeed = 50.0f;
    
    void Start()
    {
        
    }

    void Update()
    {
        transform.Rotate(0, 0, rotateSpeed * Time.deltaTime);
    }
}
