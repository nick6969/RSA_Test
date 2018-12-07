//
//  Security.swift
//  RsaTest
//
//  Created by Nick on 2018/12/5.
//  Copyright © 2018 kcin.nil.app. All rights reserved.
//

import Foundation
import Security

enum RSAError: Error {
    case pathError
    case noFileError
    case loadCertificateCreateFail
    case certificateError(message: String)
    case noKey
    
    case noData
    case encryptFail(message: String)
    case decryptFail(message: String)
}

final class RSASecurity {
    
    static let shared: RSASecurity = RSASecurity()
    
    private let secPadding: SecPadding = .OAEP
    private var paddingMinusCount: Int {
        switch secPadding {
        case []: return 0
        case .OAEP: return 42
        default: return 11
        }
    }
    private let publicKeyFileName: String = "public_key.der"
    private let privateKeyFileName: String = "private_key.p12"
    private let privateKeyPassWord: String = "1234"

    private var publicKeyRef: SecKey?
    private var privateKeyRef: SecKey?
    
    private init() {
        do {
            try loadPublicKey(with: publicKeyFileName)
            try loadPrivateKey(with: privateKeyFileName, password: privateKeyPassWord)
        } catch {
            print(msg: error)
        }
    }

    func encryptWithPublicKey(data: Data?) throws -> Data {
        guard let data = data else { throw RSAError.noData }
        guard let publicKey = publicKeyRef else { throw RSAError.noKey }
        return try encrypt(data: data, key: publicKey)
    }
    
    func decryptWithPrivateKey(data: Data?) throws -> Data {
        guard let data = data else { throw RSAError.noData }
        guard let privateKey = privateKeyRef else { throw RSAError.noKey }
        return try decrypt(data: data, key: privateKey)
    }

}

// MARK: - Load Key
extension RSASecurity {
    
    private func loadPublicKey(with fileName: String) throws {
        guard let path = Bundle.main.path(forResource: fileName, ofType: nil) else {
            throw RSAError.pathError
        }
        
        guard let certificateData = NSData(contentsOfFile: path) else {
            throw RSAError.noFileError
        }
        
        guard let secCertificateRef = SecCertificateCreateWithData(kCFAllocatorDefault, certificateData) else {
            throw RSAError.loadCertificateCreateFail
        }
        
        let policyRef = SecPolicyCreateBasicX509()
        var trustRef: SecTrust?
        
        let status = SecTrustCreateWithCertificates(secCertificateRef, policyRef, &trustRef)
        if status != noErr {
            throw RSAError.certificateError(message: getOSStatusMessage(status))
        }
        
        guard let trust = trustRef,
            let key = SecTrustCopyPublicKey(trust) else {
                throw RSAError.noKey
        }
        self.publicKeyRef = key
    }

    private func loadPrivateKey(with fileName: String, password: String) throws {
        guard let path = Bundle.main.path(forResource: fileName, ofType: nil) else {
            throw RSAError.pathError
        }
        
        guard let pkcs12Data = NSData(contentsOfFile: path) else {
            throw RSAError.noFileError
        }

        var imported: CFArray?
        let options = [kSecImportExportPassphrase as String: password as CFString]
        let status = SecPKCS12Import(pkcs12Data, (options as CFDictionary), &imported)
        switch status {
        case noErr:
            let identityDict = unsafeBitCast(CFArrayGetValueAtIndex(imported, 0), to: CFDictionary.self) as NSDictionary
            // swiftlint:disable force_cast
            let identityRef = identityDict[kSecImportItemIdentity as String] as! SecIdentity
            var privateKeyRef: SecKey?
            let error = SecIdentityCopyPrivateKey(identityRef, &privateKeyRef)
            if error == noErr {
                self.privateKeyRef = privateKeyRef
            } else {
                throw RSAError.certificateError(message: getOSStatusMessage(status))
            }
        default:
            throw RSAError.certificateError(message: getOSStatusMessage(status))
        }
    }
    
}

// MARK: - implementation Encrypt
extension RSASecurity {

    private func encrypt(data: Data, key: SecKey) throws -> Data {
        let plainData = [UInt8](data)
        let blockSize = SecKeyGetBlockSize(key)
        let maxChunkSize = blockSize - paddingMinusCount
        var encryptedData: [UInt8] = []
        
        var index = 0
        while index < plainData.count {
            let indexEnd = min(index + maxChunkSize, plainData.count)
            let chunkData = Array(plainData[index..<indexEnd])
            var encryptedDataBuffer = [UInt8](repeating: 0, count: blockSize)
            var encryptedDataLength = blockSize
            
            let status = SecKeyEncrypt(key,
                                       secPadding,
                                       chunkData,
                                       indexEnd-index,
                                       &encryptedDataBuffer,
                                       &encryptedDataLength)
            if status != noErr {
                throw RSAError.encryptFail(message: getOSStatusMessage(status))
            }
            encryptedData += encryptedDataBuffer
            index += maxChunkSize
        }
        return Data(bytes: encryptedData, count: encryptedData.count)
    }

}

// MARK: - implementation decrypt
extension RSASecurity {
    
    private func decrypt(data: Data, key: SecKey) throws -> Data {
        let cipherData = [UInt8](data)
        let blockSize = SecKeyGetBlockSize(key)
        var decryptedData: [UInt8] = []
        
        var index = 0
        while index < cipherData.count {
            let indexEnd = min(index + blockSize, cipherData.count)
            let chunkData = Array(cipherData[index..<indexEnd])
            var decryptedDataBuffer = [UInt8](repeating: 0, count: blockSize)
            var decryptedDataLength = blockSize
            
            let status = SecKeyDecrypt(key,
                                       secPadding,
                                       chunkData,
                                       indexEnd-index,
                                       &decryptedDataBuffer,
                                       &decryptedDataLength)
            if status != noErr {
                throw RSAError.decryptFail(message: getOSStatusMessage(status))
            }
            decryptedDataBuffer = decryptedDataBuffer.filter { $0 != 0x00 }
            decryptedData += decryptedDataBuffer
            index += blockSize
        }
        return Data(bytes: decryptedData, count: decryptedData.count)
    }
}

extension RSASecurity {
    
    private func getOSStatusMessage(_ status: OSStatus) -> String {
        if #available(iOS 11.3, *) {
            return SecCopyErrorMessageString(status, nil)! as String
        } else {
            return "An error occurred with code \(status)"
        }
    }
    
}
