using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
public class TestAStarCell : MonoBehaviour
{
    public Image img;
    public Button btn;
    public TestAStarType type = TestAStarType.Normal;
    public TestAStarCell parent;
    public Text txtF;
    public Text txtG;
    public Text txtH;
    private int m_f;
    public int F
    {
        set
        {
            m_f = value;
            txtF.text = m_f.ToString();
        }
        get
        {
            return m_f;
        }
    }
    private int m_g;
    public int G
    {
        set
        {
            m_g = value;
            txtG.text = m_g.ToString();
        }
        get
        {
            return m_g;
        }    
    }
    private int m_h;
    public int H
    {
        set
        {
            m_h = value;
            txtH.text = m_h.ToString();
        }
        get
        {
            return m_h;
        }    
    }
    public int row = 0;

    public int col = 0;

    private void Start()
    {
        btn.onClick.AddListener(OnClick);
    }

    public void Init(int rrow,int ccol,int maxRow,int maxCol)
    {
        row = rrow;
        col = ccol;
        transform.localPosition = new Vector3(-maxCol/2 * 45 + col * 45, maxRow/2 * 45 - row * 45 + 50);
    }

    public void SetParent(TestAStarCell cell)
    {
        parent = cell;
    }

    public bool IsEqual(TestAStarCell cell)
    {
        return GetInstanceID() == cell.GetInstanceID();
    }

    private void OnClick()
    {
        if(type == TestAStarType.Normal)
        {
            type = TestAStarType.NoPass;
        }
        else if(type == TestAStarType.NoPass)
        {
            type = TestAStarType.Normal;
        }
        RefreshColor();
    }

    public void SetType(TestAStarType ttype)
    {
        type = ttype;
        RefreshColor();
    }

    private void RefreshColor()
    {
        switch(type)
        {
            case TestAStarType.NoPass:
                img.color = Color.grey;
                break;
            case TestAStarType.Normal:
                img.color = Color.white;
                break;
            case TestAStarType.Start:
            case TestAStarType.End:
                img.color = Color.red;
                break;
            case TestAStarType.Path:
                img.color = Color.green;
                break;
        }
    }
}
