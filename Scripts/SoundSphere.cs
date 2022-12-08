using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SoundSphere : MonoBehaviour
{
    float lastTime;
    float curTime;
    float note;
    float step;
    float inverseFactor = 10.0f;
    float growthLimit = 5.0f;
    float shrinkLimit = 0.8f;
    AudioSource audio;
    Vector3 growthVector;

    void Start()
    {
        audio = GetComponent<AudioSource>();
        growthVector = new Vector3(0.8f,0.8f,0.8f);
        lastTime = 0.0f;
        step = 1.0f;
    }

    void Update()
    {
        // Limit the scale of the sphere
        float sphereScale = transform.localScale.x;
        if (sphereScale >= growthLimit || sphereScale <= shrinkLimit) {
            growthVector = -growthVector;
        }

        // Change the sphere scale
        transform.localScale += growthVector * Time.deltaTime;
    }

    void PlaySound(float scale)
    {
        curTime = Time.time;
        if (curTime - lastTime > 0.1f) {

            // 'Note' scales negatively with 'scale'
            note = 10.0f - (2.0f * scale);

            // Pitch = 1 is the pitch of your starting note
            // Increasing / decreasing 'note' by 1 alters pitch by a half-step
            audio.pitch =  Mathf.Pow(2.0f, (note)/12.0f);
            audio.Play();

            lastTime = Time.time;
        }
    }

    public void HitEvent(RaycastHit hit)
    {
        // Play the sound based on the scale of the sphere
        PlaySound(transform.localScale.x);
    }

}
