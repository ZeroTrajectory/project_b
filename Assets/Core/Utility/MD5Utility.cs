using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Security.Cryptography;
using System.Text;

public class MD5Utility
{
    //获取字符串的MD5码
    public static string CreateMD5Hash(string input)
    {
        string hash = string.Empty;
        using (MD5 md5Hash = MD5.Create())
        {
            hash = GetMd5Hash(md5Hash, input);
        }

        return hash;
    }

    static string GetMd5Hash(MD5 md5Hash, string input)
    {
        // Convert the input string to a byte array and compute the hash.
        byte[] data = md5Hash.ComputeHash(Encoding.UTF8.GetBytes(input));

        // Create a new Stringbuilder to collect the bytes
        // and create a string.
        StringBuilder sBuilder = new StringBuilder();

        // Loop through each byte of the hashed data 
        // and format each one as a hexadecimal string.
        for (int i = 0; i < data.Length; i++)
        {
            sBuilder.Append(data[i].ToString("x2"));
        }

        // Return the hexadecimal string.
        return sBuilder.ToString();
    }


    // Verify a hash against a string.
    static bool VerifyMd5Hash(MD5 md5Hash, string input, string hash)
    {
        // Hash the input.
        string hashOfInput = GetMd5Hash(md5Hash, input);

        // Create a StringComparer an compare the hashes.
        StringComparer comparer = StringComparer.OrdinalIgnoreCase;

        if (0 == comparer.Compare(hashOfInput, hash))
        {
            return true;
        }
        else
        {
            return false;
        }
    }
        
    /// <summary>  
    ///  获取文件的MD5码,传入的文件名（含路径及后缀名)
    /// <param name="fileName"></param>  
    /// </summary>
    public static string GetFileMD5Hash(string fileName)  
    {  
        using (var md5 = MD5.Create())
        {
            using (var stream = File.OpenRead(fileName))
            {
                var hash = md5.ComputeHash(stream);
                return BitConverter.ToString(hash).Replace("-", "").ToLowerInvariant();
            }
        }
    }

    public static string GetBytesMD5Hash(byte[] data)
    {
        using (var md5 = MD5.Create())
        {
            var hash = md5.ComputeHash(data);
            return BitConverter.ToString(hash).Replace("-", "").ToLowerInvariant();
        }
    }

    public static byte[] DEFAULT_ENCRYPT_KEY
    {
        get
        {  
            return System.Text.Encoding.UTF8.GetBytes("djxlamfi");
        }
    }
    
    public static byte[] DEFAULT_ENCRYPT_IV
    {
        get
        {
            byte[] iv = {0xAB, 0xDE, 0x26, 0x88, 0x90, 0xBE, 0x9D, 0x2F};
            return iv;
        }
    }
    /// <summary>
    /// DES加密
    /// </summary>
    /// <param name="content">明文</param>K
    /// <param name="key">加密钥匙</param>
    /// <param name="iv">向量</param>
    /// <returns>返回密文</returns>
    public static string DESEncryptor(string content,byte[] desKey,byte[] desIV)
    {
        string cipherText = string.Empty;
        if(desIV.Length != desKey.Length)
        {
            UnityEngine.Debug.LogError("desIV的长度与desKey的长度不一致");
            return cipherText;
        }

        byte[] data = System.Text.Encoding.UTF8.GetBytes(content);
        DESCryptoServiceProvider des = new DESCryptoServiceProvider();
      
        using (MemoryStream ms = new MemoryStream())
        {
            using (CryptoStream cs = new CryptoStream(ms, des.CreateEncryptor(desKey, desIV), CryptoStreamMode.Write))
            {
                cs.Write(data, 0, data.Length);
                cs.FlushFinalBlock();
                cipherText = Convert.ToBase64String(ms.ToArray());
            }
        }

        return cipherText;
    }

    /// <summary>
    /// DES解密
    /// </summary>
    /// <param name="content">密文</param>K
    /// <param name="key">加密钥匙</param>
    /// <param name="iv">向量</param>
    /// <returns>返回明文</returns>
    public static string DESDecryptor(string content,byte[] desKey,byte[] desIV)
    {
        string plainText = string.Empty;

        if(desIV.Length != desKey.Length)
        {
            UnityEngine.Debug.LogError("desIV的长度与desKey的长度不一致");
            return plainText;
        }

        DESCryptoServiceProvider des = new DESCryptoServiceProvider();
        byte[] data = Convert.FromBase64String(content);

        using (MemoryStream ms = new MemoryStream())
        {
            using (CryptoStream cs = new CryptoStream(ms, des.CreateDecryptor(desKey, desIV), CryptoStreamMode.Write))
            {
                cs.Write(data, 0, data.Length);
                cs.FlushFinalBlock();
                plainText = Encoding.UTF8.GetString(ms.ToArray());
            }
        }
        return plainText;
    }


}
