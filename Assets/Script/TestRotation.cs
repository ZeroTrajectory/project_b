using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestRotation : MonoBehaviour
{
    public Transform pointA;
    public Transform pointB;
    public Transform targetPoint;
    void Start()
    {
        Quaternion quaternion = Quaternion.LookRotation(pointA.position - pointB.position);
        targetPoint.rotation = quaternion;
    }
}
