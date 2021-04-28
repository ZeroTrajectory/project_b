using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestContact : MonoBehaviour
{
    private void OnCollisionEnter(Collision other) 
    {
        if(other.gameObject.tag != "Bullet")
            return;
        Destroy(other.gameObject);
    }

    private void OnTriggerStay(Collider other) 
    {
        if( other.tag != "Bullet")
            return;
        if( other.attachedRigidbody)
            other.attachedRigidbody.AddForce(Vector3.up * 20);
    }
}
