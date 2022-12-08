using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GrowingSphere : MonoBehaviour
{
    public bool run = true;
    private float lastTime;
    private float curTime;
    private float reverseDelay = 0.001f;
    private Vector3 growthVector;
    
    void Start()
    {
        lastTime = 0.0f;
        growthVector = new Vector3(1,1,1);
    }

    void Update()
    {
        if (run) {
            curTime = Time.time;
            transform.localScale += growthVector * Time.deltaTime;
        }
    }

    public void SphereCollision()
    {
        // If not enough time has passed between the last shift, don't reverse growth
        if (curTime - lastTime > reverseDelay) {
            growthVector = -growthVector;
            lastTime = Time.time;
        }
    }

    public void PlaySound()
    {
        // 'Note' scales negatively with 'scale'
        float note = 10.0f - (2.0f * transform.localScale.x);

        // Pitch = 1 is the pitch of your starting note
        // Increasing / decreasing 'note' by 1 alters pitch by a half-step
        GetComponent<AudioSource>().pitch =  Mathf.Pow(2.0f, (note)/12.0f);
        GetComponent<AudioSource>().Play();
    }

}
