using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;
using UnityEngine;

public class FileOutTool
{
    public static void OutPutFile(string outPath,string content)
    {
        using(FileStream fs = new FileStream(outPath,FileMode.Create))
        {
            byte[] bytes = Encoding.Default.GetBytes(content);
            fs.Write(bytes,0,bytes.Length);
            fs.Flush();
        }
    }
}
