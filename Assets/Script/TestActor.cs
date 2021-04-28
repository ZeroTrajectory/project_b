using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;
public class TestActor : MonoBehaviour
{
    public Transform goal;
    private NavMeshAgent m_agent;
    void Awake()
    {
        m_agent = GetComponent<NavMeshAgent>();
        m_agent.destination = goal.position;
    }

    // Update is called once per frame
    void Update()
    {
        if(Input.GetMouseButtonDown(0))
        {
            RaycastHit hit;
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            Debug.DrawLine(ray.origin,ray.GetPoint(100));
            if (Physics.Raycast(ray,out hit,100))
            {
                m_agent.destination = hit.point;
            }
        }
    }
}
