<?php

// 設定公、私鑰檔名
const PRIVATE_KEY = 'private_key.pem';
const PUBLIC_KEY = 'public.pem';
const PASSPHRASE = '1234';

function public_encrypt($plain_text)
{
    $fp = fopen(PUBLIC_KEY, "r");
    $pub_key = fread($fp, 4096);
    fclose($fp);
    $pub_key_res = openssl_get_publickey($pub_key);
    if(!$pub_key_res) {
        throw new Exception('Public Key invalid');
    } else {
        openssl_public_encrypt($plain_text, $crypt_text, $pub_key_res, OPENSSL_PKCS1_OAEP_PADDING);
        openssl_free_key($pub_key_res);
        return base64_encode($crypt_text); // 加密後的內容為 binary 透過 base64_encode() 轉換為 string 方便傳輸
    }
}

function private_decrypt($encrypted_text)
{
    $fp = fopen(PRIVATE_KEY, "r");
    $priv_key = fread($fp, 4096);
    fclose($fp);
    // $private_key_res = openssl_get_privatekey($priv_key);
    $private_key_res = openssl_get_privatekey($priv_key, PASSPHRASE); // 如果使用密碼
    if(!$private_key_res) {
        throw new Exception('Private Key invalid');
    }
    // 先將密文做 base64_decode() 解釋
    openssl_private_decrypt(base64_decode($encrypted_text), $decrypted, $private_key_res, OPENSSL_PKCS1_OAEP_PADDING);
    openssl_free_key($private_key_res);
    return $decrypted;
}

$value = $_POST['data'];
echo private_decrypt($value);

// 測試 PHP 自己加密 自己解密
// $value = public_encrypt('🦀🦀🦀🦀🦀');
// echo $value;
// $decrypted = private_decrypt($value);
// echo $decrypted;