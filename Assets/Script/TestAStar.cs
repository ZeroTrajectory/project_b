using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public enum TestAStarType
{
    NoPass = 0,
    Normal = 1,
    Start = 2,
    End = 3,
    Path = 4,
}

public class TestAStar : MonoBehaviour
{
    public int maxRow = 15;
    public int maxCol = 20;
    private Dictionary<int,Dictionary<int,TestAStarCell>> cellDic = new Dictionary<int, Dictionary<int, TestAStarCell>>();
    public Transform temp;
    public Transform root;
    public Button btnStart;
    public Button btnSet;
    public int StartRow = 5;
    public int StartCol = 5;
    public int EndRow = 15;
    public int EndCol = 5;

    private List<TestAStarCell> openList = new List<TestAStarCell>();
    private List<TestAStarCell> closeList = new List<TestAStarCell>();

    private void Start()
    {
        for(int i = 0; i < maxRow; i++)
        {
            for(int j = 0; j < maxCol; j++)
            {
                var obj = GameObject.Instantiate(temp,root);
                obj.localScale = Vector3.one;
                var cell = obj.GetComponent<TestAStarCell>();
                cell.Init(i + 1,j + 1,maxRow,maxCol);
                if(!cellDic.ContainsKey(i+1))
                {
                    cellDic[i+1] = new Dictionary<int, TestAStarCell>();
                }
                cellDic[i+1][j+1] = cell;
            }
        }
        btnStart.onClick.AddListener(OnBtnStart);
        btnSet.onClick.AddListener(OnBtnSet);
    }

    private void OnBtnStart()
    {
        openList.Clear();
        closeList.Clear();
        var startCell = cellDic[StartRow][StartCol];
        closeList.Add(startCell);
        CheckCell(startCell);
    }

    private void OnBtnSet()
    {
        foreach(var dic in cellDic)
        {
            foreach(var cell in dic.Value)
            {
                cell.Value.SetType(TestAStarType.Normal);
                cell.Value.H = 0;
                cell.Value.G = 0;
                cell.Value.F = 0;
                cell.Value.parent = null;
            }
        }
        var startCell = cellDic[StartRow][StartCol];
        startCell.SetType(TestAStarType.Start);
        var enddCell = cellDic[EndRow][EndCol];
        enddCell.SetType(TestAStarType.End);
    }

    private void CheckCell(TestAStarCell parentCell)
    {
        int row = parentCell.row;
        int col = parentCell.col;
        for(int r = row - 1; r <= row + 1; r++)
        {
            if(r < 1 || r > maxRow)
            {
                continue;
            }
            for(int c = col - 1; c <= col + 1; c++)
            {
                if(c < 1 || c > maxCol)
                {
                    continue;
                }
                var cell = cellDic[r][c];
                if(isIn(closeList,cell))
                {
                    continue;
                }
                if(cell.type == TestAStarType.NoPass)
                {
                    closeList.Add(cell);
                    continue;
                }
                else if(cell.type == TestAStarType.End)
                {
                    cell.parent = parentCell;
                    ShowPath();
                    return;
                }
                else
                {
                    int G = parentCell.G + 10;
                    if(Mathf.Abs(parentCell.row - cell.row) + Mathf.Abs(parentCell.col - cell.col) > 1)
                    {
                        G = parentCell.G + 14;
                    }
                    int H = Mathf.Abs(EndRow - cell.row) + Mathf.Abs(EndCol - cell.col);
                    int F = G + H;
                    if(isIn(openList,cell))
                    {
                        if(cell.F > F)
                        {
                            cell.G = G;
                            cell.H = H;
                            cell.F = F;
                            cell.parent = parentCell;
                        }
                    }
                    else
                    {
                        cell.G = G;
                        cell.H = H;
                        cell.F = F;
                        cell.parent = parentCell;
                        openList.Add(cell);
                    }
                }
            }
        }
        SelectMinF();
    }

    private void SelectMinF()
    {
        TestAStarCell cell = null;
        for(int i =0; i < openList.Count; i++)
        {
            if(cell == null || cell.F > openList[i].F)
            {
                cell = openList[i];
            }
        }
        openList.Remove(cell);
        closeList.Add(cell);
        CheckCell(cell);
    }

    private void ShowPath()
    {
        var pathCell = cellDic[EndRow][EndCol];
        int protectNum = 999;
        while(pathCell.parent != null)
        {
            pathCell = pathCell.parent;
            if(pathCell.type == TestAStarType.Start)
            {
                break;
            }
            pathCell.SetType(TestAStarType.Path);
            protectNum--;
            if(protectNum < 0) break;
        }
    }

    private bool isIn(List<TestAStarCell> list,TestAStarCell cell)
    {
        for(int i = 0; i < list.Count; i++)
        {
            if(list[i].IsEqual(cell))
            {
                return true;
            }
        }
        return false;
    }
}
