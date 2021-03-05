using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BattleMap : MonoBehaviour
{
    public Transform m_cube;
    void Start()
    {
        for(int i = 0; i < 10;i++)
        {
            var cube = GameObject.Instantiate(m_cube,transform);
            cube.localPosition = new Vector3(1 * i,0,0);
        }
    }
}
