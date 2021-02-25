using System.Collections;
using System.Collections.Generic;
using Core.Load;
using UnityEngine;
using UnityEngine.UI;
public class TestLoader : MonoBehaviour
{
    public Image m_img;
    void Start()
    {
        AssetManager.instance.LoadAysnc("Assets/Image/a.png", typeof(Sprite),
            new LoadAssetCallbacks((assetName, asset, userData) =>
            {
                m_img.sprite = (Sprite)asset;
            },
            (assetName, errorMessage, userData) =>
            {
                Debug.LogError(errorMessage);
            })  
            ,4);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
