//
//  TMKeyManager.swift
//  TMTransferDemo
//
//  Created by ChanAarson on 22/6/2018.
//  Copyright © 2018 Aarson Chan. All rights reserved.
//

import UIKit
import CryptoSwift
import SwiftyRSA

class TMKeyManager: NSObject {

    public var pubKeyArray: Array <TMPubKey>
    var aesKey: Array<UInt8>
    
    private static var mInstance:TMKeyManager?
    static func sharedInstance() -> TMKeyManager {
        if mInstance == nil {
            mInstance = TMKeyManager()
        }
        return mInstance!
    }
    
    //Get RSA Keys from TMConfig in the beginning
    override init() {
        pubKeyArray = []
        aesKey = []
        var keyName:String = ""
        var keyValue:String = ""
        let keyArray:Array<String> = TMConfig().getTMSessionKeyArray()
        for key:String in keyArray {
            var keyElement:Array = key.components(separatedBy: "|")
            keyName = keyElement[0]
            keyValue = keyElement[1]
            pubKeyArray.append(TMPubKey.init(name: keyName, value: keyValue))
        }
    }
    
    //Generation of AES Random Key
    func generateRandomAesKey() {
        aesKey = AES.randomIV(AES.blockSize)
    }
    
    //RSA encrpytion with public key in TMConfig (Private Key stored in Server)
    func encryptByPublicKey(input:Data, pubKey:TMPubKey) -> Data? {
        do {
            do {
                let publicKey = try PublicKey.init(base64Encoded: pubKey.pubKeyValue)
                let clear = ClearMessage.init(data: input)
                let encrypted:EncryptedMessage
                do {
                    encrypted = try clear.encrypted(with: publicKey, padding: .PKCS1)
                    return encrypted.data
                } catch {
                    DDLogVerbose("Fail in RSA Encrpytion")
                }
                
            } catch let error as SwiftyRSAError{
                DDLogVerbose("Fail in create Public Key: \(error.localizedDescription)")
            }
        } catch  {
            DDLogVerbose("Error: Fail In Encrypt RSA")
        }
        return nil
    }
}
