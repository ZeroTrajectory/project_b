using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using Sirenix.OdinInspector;
public class TestLoader : MonoBehaviour
{
    public SpriteRenderer m_spriteRenderer1;
    public SpriteRenderer m_spriteRenderer2;
    public SpriteRenderer m_spriteRenderer3;

    private const string IMAGE_PATH = "Assets/Image/a.png";
    void Start()
    {
        var stopWatch = new System.Diagnostics.Stopwatch();
        string IMAGE_AB_PATH = Application.dataPath + "/Test/TestAB/assets/image/a.ab";
        var ab = AssetBundle.LoadFromFile(IMAGE_AB_PATH);
        ab = AssetBundle.LoadFromFile(IMAGE_AB_PATH);
        m_spriteRenderer1.sprite = ab.LoadAsset<Sprite>(IMAGE_PATH);
        // ab.Unload(false);
        // ab = AssetBundle.LoadFromFile(IMAGE_AB_PATH);
        m_spriteRenderer2.sprite = ab.LoadAsset<Sprite>(IMAGE_PATH);
        // ab.Unload(false);
        // ab = AssetBundle.LoadFromFile(IMAGE_AB_PATH);
        m_spriteRenderer3.sprite = ab.LoadAsset<Sprite>(IMAGE_PATH);
        // ab.Unload(false);
        var m_spriteRenderer1Clone = Instantiate<GameObject>(m_spriteRenderer1.gameObject,transform);
        m_spriteRenderer1Clone.transform.position = new Vector3(-2.9f,-1.4f,4.9f);
        // ab.Unload(true);
    }

    [Button("ClearAB")]
    private void ClearAB()
    {

    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
