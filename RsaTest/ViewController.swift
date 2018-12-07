//
//  ViewController.swift
//  RsaTest
//
//  Created by Nick on 2018/12/5.
//  Copyright © 2018 kcin.nil.app. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let plainText = Array(repeating: "🎒🎒🎒🎒", count: 5).joined()

    override func viewDidLoad() {
        super.viewDidLoad()
        testRsa()
        requsestPHP()
    }

    func testRsa() {
        let data = plainText.data(using: .utf8)!        
        do {
            let res = try RSASecurity.shared.encryptWithPublicKey(data: data)
            print(msg: res.base64Encoded())
            let decryptedData = try RSASecurity.shared.decryptWithPrivateKey(data: res)
            let decryptedString = String(data: decryptedData, encoding: .utf8)
            if decryptedString == plainText {
                print(msg: "正確")
            } else {
                print(msg: "錯誤")
            }
        } catch {
            print(msg: error)
        }
    }
    
    func requsestPHP() {
        let data = plainText.data(using: .utf8)!
        do {
            let res = try RSASecurity.shared.encryptWithPublicKey(data: data)
            guard let value = res.base64Encoded() else {
                print(msg: "encrypt Base64 fail")
                return
            }
            print(msg: value)
            request(with: value)
        } catch {
            print(msg: error)
        }
    }
    
    func request(with value: String) {
        
        let url = URL(string: "http://localhost:8888/RSATest.php")!
        let data = "data=\(value)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!.replacingOccurrences(of: "+", with: "%2B").data(using: .utf8)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = data
        
        URLSession.shared.dataTask(with: request) { (data, res, error) in
            if let data = data, let str = String(data: data, encoding: .utf8) {
                print(msg: str)
            } else {
                print(msg: "PHP 解碼失敗")
            }
            }.resume()
    }
    
}

extension Data {
    func base64Encoded() -> String? {
        return self.base64EncodedString(options: .lineLength64Characters)
    }
}

extension String {
    func base64Decoded() -> String? {
        guard let decodedData = Data(base64Encoded: self, options: .ignoreUnknownCharacters) else { return nil }
        return String(data: decodedData, encoding: .utf8)
    }
}
