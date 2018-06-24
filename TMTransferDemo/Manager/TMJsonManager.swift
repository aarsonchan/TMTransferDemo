//
//  TMJsonManager.swift
//  TMTransferDemo
//
//  Created by ChanAarson on 22/6/2018.
//  Copyright © 2018 Aarson Chan. All rights reserved.
//

import UIKit
import CryptoSwift

class TMJsonManager: NSObject {

    var an: String = ""
    var sn: String = ""
    var jim: NSMutableDictionary
    var requestDictionary: NSMutableDictionary
    
    private static var mInstance:TMJsonManager?
    static func sharedInstance() -> TMJsonManager {
        if mInstance == nil {
            mInstance = TMJsonManager()
        }
        return mInstance!
    }
    
    override init() {
        requestDictionary = NSMutableDictionary()
        jim = NSMutableDictionary()
    }
    
    //Use RSA public Key to encrypt ARS random generated Key
    func setRequestWithEncryptAesKeyWithRsa(pubKey:TMPubKey, data:NSDictionary){
        do {
            let jsonObjData = try JSONSerialization.data(withJSONObject: data, options: [])
            let jsonObjString = String(data:jsonObjData, encoding:.utf8)
            let jsonHash = jsonObjString?.sha256().uppercased()
            let base64Encoded = jsonObjData.base64EncodedString()
            
            DDLogVerbose("Request Data: \(jsonObjString!)")
            let keyManager:TMKeyManager = TMKeyManager.sharedInstance()
            do {
                let aes = try AES(key: keyManager.aesKey, blockMode:.ECB)
                do {
                    let jsonObjectOutputData = try aes.encrypt(Array(base64Encoded.utf8))
                    jim = NSMutableDictionary()
                    jim["alias"] = pubKey.pubKeyName
                    jim["session_key"] = keyManager.encryptByPublicKey(input:Data.init(bytes: keyManager.aesKey), pubKey: pubKey)?.toHexString()
                    jim["data"] = jsonObjectOutputData.toHexString()
                    jim["hash"] = jsonHash
                    requestDictionary["jim"] = jim
                } catch let error {
                    DDLogError("Encrpt Error: \(error.localizedDescription)")
                }
            } catch let error {
                DDLogError("init Error:\(error.localizedDescription)")
            }
        } catch {
            DDLogError("Error: cannot create JSON from todo")
            return
        }
    }
    
    //As AES Key sent to server in build session API, will use that AES key (ref to sessionId return)to do encryption afterward for every API call
    func encryptJsonWithSessionId(sessionId:String, data:NSDictionary) {
        do {
            let jsonObjData = try JSONSerialization.data(withJSONObject: data, options: [])
            let jsonObjString = String(data:jsonObjData, encoding:.utf8)
            let jsonHash = jsonObjString?.sha256()
            let base64Encoded = jsonObjData.base64EncodedString()
            
            DDLogVerbose("Request Data: \(jsonObjString!)")
            let keyManager:TMKeyManager = TMKeyManager.sharedInstance()
            do {
                let aes = try AES(key: keyManager.aesKey, blockMode:.ECB) // aes128
                do {
                    let jsonObjectOutputData = try aes.encrypt(Array(base64Encoded.utf8))
                    jim = NSMutableDictionary()
                    jim["sid"] = sessionId
                    jim["data"] = jsonObjectOutputData.toHexString()
                    jim["hash"] = jsonHash
                    requestDictionary["jim"] = jim
                } catch let error {
                    DDLogError("Encrpt Error:\(error.localizedDescription)")
                }
            } catch let error {
                DDLogError("init Error:\(error.localizedDescription)")
            }
        } catch {
            DDLogError("Error: cannot create JSON from todo")
            return
        }
    }
    
    //Function of decrypt server response
    func decryptResponse(response:NSDictionary) -> NSDictionary{
        let jom:NSDictionary = response["jom"] as! NSDictionary
        let dataString:String = jom["data"] as! String
        let hashString:String = jom["hash"] as! String
        var decodeDict:NSDictionary = NSDictionary()
        
        let keyManager:TMKeyManager = TMKeyManager.sharedInstance()
        do {
            let aes = try AES(key: keyManager.aesKey, blockMode:.ECB)
            let decryptedData:Array<UInt8> = try aes.decrypt(Array<UInt8>(hex: dataString))
            let data = NSData(bytes:decryptedData, length:decryptedData.count)
            let decryptedString:String = String(data:data as Data, encoding:.utf8)!
            let decodeData:Data = Data(base64Encoded:decryptedString , options:Data.Base64DecodingOptions.ignoreUnknownCharacters)!
            let decodeString:String = String(data:decodeData, encoding:.utf8)!
            DDLogVerbose("Response Data: \(decodeString)")
            DDLogVerbose("Response Data hash:\(decodeString.sha256().uppercased())")
            if (decodeString.sha256().uppercased() ==  hashString) {
                DDLogVerbose("Hash equal")
                do {
                    decodeDict = try JSONSerialization.jsonObject(with: decodeData, options: []) as! NSDictionary
                    DDLogVerbose("Response rc: \(decodeDict["rc"]!)")
                } catch let error {
                    DDLogError("Encrpt Error: \(error.localizedDescription)")
                }
                return decodeDict
            } else {
                DDLogError("Hash not Equal")
                return decodeDict
            }
        } catch  let error {
            DDLogError("Encrpt Error: \(error.localizedDescription)")
        }
        return decodeDict
    }
    
    //Get the dummy static JSON response from online hosting
    func getDummyResponse(response:NSDictionary) -> NSDictionary {
        let jom:NSDictionary = response["jom"] as! NSDictionary
        return jom
    }
}
