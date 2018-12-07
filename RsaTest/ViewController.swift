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
