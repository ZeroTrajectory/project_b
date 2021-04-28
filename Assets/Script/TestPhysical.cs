using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestPhysical : MonoBehaviour
{
    public ConstantForce constant;
    private float sec = 0f;
    void Update()
    {
        if(Input.GetMouseButton(0))
        {
            sec += Time.deltaTime;
        }
        if(Input.GetMouseButtonUp(0))
        {
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            RaycastHit hit;
            if(Physics.Raycast(ray,out hit))
            {
                Debug.DrawLine(ray.origin,hit.point,Color.green);
                ConstantForce bullet = Instantiate<ConstantForce>(constant,ray.origin,Quaternion.LookRotation(hit.point - ray.origin));
                Debug.Log("射速：" + sec);
                bullet.relativeForce = new Vector3(0,0,sec * 45);
            }
            sec = 0f;
        }
    }
}
