//
//  TMMessageManager.swift
//  TMTransferDemo
//
//  Created by ChanAarson on 21/6/2018.
//  Copyright © 2018 Aarson Chan. All rights reserved.
//

import Foundation
import Alamofire

class TMMessageManager: NSObject {
    
    weak var request: Alamofire.Request?
    private static var mInstance:TMMessageManager?
    var sessionId: String!
    
    static func sharedInstance() -> TMMessageManager {
        if mInstance == nil {
            mInstance = TMMessageManager()
        }
        return mInstance!
    }
    
    //Send Request Function with White List Checking and Certificate Pinning before sent
    public func sendRequest(param: NSDictionary, urlString:String, successBlock: @escaping (NSDictionary)-> (), failBlock: @escaping (String)-> ()) {
        
        //White List Checking
        if !self.isWhiteListCheckValid(urlString: urlString) {
            failBlock("White List Error")
            return
        }
        //Certicate Pinning
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            "dgateway.transfermoneydemo.com.hk": .pinCertificates(certificates: ServerTrustPolicy.certificates(), validateCertificateChain: true, validateHost: true)
        ]// .cer file generated from server need to import to project
        let manager = Alamofire.SessionManager(serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies))
        manager.session.configuration.timeoutIntervalForRequest = 30
        let queue = DispatchQueue(label:"com.transfermoneydemo.response-queue", qos: .utility, attributes: [.concurrent])
        let parameters: Parameters = param as! Parameters
        manager.request(URL(string: urlString)!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
            .validate(statusCode: 200..<500) //Checking HTTP Status Code
            .response(queue: queue, responseSerializer: DataRequest.jsonResponseSerializer(), completionHandler: { (response) in
            
            switch (response.result) {
            case .success:
                DDLogVerbose("Response: \(response.result.value! as Any)")
                successBlock(response.result.value as! NSDictionary)
                break
            case .failure(let error):
                DDLogError("\n\nAuth request failed with error:\n\(error)\n\(error.localizedDescription)")
                failBlock(error.localizedDescription)
                break
            }
        })
    }
    
    //White List Checking
    //Return error and fail if checked that URL domain mismatch
    private func isWhiteListCheckValid(urlString:String) -> Bool {
        let checkUrl: URL = URL(string:urlString)!
        let donmainUrlStr:String = "\(checkUrl.scheme ?? "")://\(checkUrl.host ?? "")"
        let whiteListStr = TMConfig().getTMWhiteListUrl()
        let whiteList:Array = whiteListStr.components(separatedBy: ";")
        for whiteListUrl in whiteList {
            if whiteListUrl == donmainUrlStr {
                return true
            }
        }
        return false
    }
    
    //MARK: - API Call
    //Request of generating a random AES Symmetric Key and pass to Server using RSA public key encrpytion (Assume Server owns the RSA private key)
    func requestBuildSession(successBlock: @escaping (NSDictionary)-> (), failBlock: @escaping (NSDictionary)-> ()) {
        DDLogVerbose("\n\n=================== Build Sesstion Start =====================")
        let jsonManager = TMJsonManager.sharedInstance()
        let keyManager:TMKeyManager = TMKeyManager.sharedInstance()
        //Generate Random AES Key
        keyManager.generateRandomAesKey()
        let randomNumber :Int = Int(arc4random() % 10)
        let pubKey = keyManager.pubKeyArray[randomNumber]
        
        //Build & encrypt JSON Content
        let jsonObject:NSMutableDictionary = NSMutableDictionary.init()
        jsonObject["osType"] = "I"
        jsonObject["appVersion"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        jsonManager.setRequestWithEncryptAesKeyWithRsa(pubKey:pubKey, data: jsonObject)
        jsonManager.requestDictionary["action"] = "SessionBuild"
        
        //Set Request to Server
        sendRequest(param:jsonManager.requestDictionary , urlString: TMConfig().getTMTransferUrl(), successBlock: { (responseDict:NSDictionary) in
            let responseDict =  jsonManager.decryptResponse(response: responseDict)
            let rc = responseDict["rc"] as! String
            let sid = responseDict["sessionId"] as! String
            if (rc == "0000") {
                DDLogVerbose("Server Accept")
                self.sessionId = sid
                successBlock(responseDict)
            } else {
                failBlock( NSDictionary(dictionary: ["error" : rc]))
            }
        }, failBlock: { (errorCode:String) in
            //In Demo, due to hardcode invalid url, app flow will go to this
            DDLogVerbose("Dummy Server Accept")
            self.sessionId = "62736582365" //assume server response accepted and return valid sessionId
            successBlock([:])
        })
    }
    
    //Request of transfer money using AES Key as encrpytion
    //There will be dummy API call in fail block for Demo
    public func requestTransferMoney(amount:String, currency:String, payerAccnNum:String, payeeAccnNum:String, successBlock: @escaping (NSDictionary)-> (), failBlock: @escaping (NSDictionary)-> ()) {
        DDLogVerbose("\n\n=================== Transfer Money Start =====================")
        let jsonManager = TMJsonManager.sharedInstance()
        let jsonObject:NSMutableDictionary = NSMutableDictionary.init()

        //Build & encrypt JSON Content
        jsonObject["amount"] = amount
        jsonObject["currency"] = currency
        jsonObject["payerAccnNum"] = payerAccnNum
        jsonObject["payeeAccnNum"] = payeeAccnNum
        jsonManager.encryptJsonWithSessionId(sessionId: self.sessionId, data: jsonObject)
        jsonManager.requestDictionary["action"] = "TransferMoney"
        DDLogVerbose("Request: \(jsonManager.requestDictionary)")
        
        //Set Request to Server
        sendRequest(param:jsonManager.requestDictionary , urlString: TMConfig().getTMTransferUrl(), successBlock: { (responseDict:NSDictionary) in
            //Get Response from Server and decrypt message
            let responseDict =  jsonManager.decryptResponse(response: responseDict)
            let rc = responseDict["rc"] as! String
            if (rc == "0000") {
                DDLogVerbose("Server Accept")
                successBlock(responseDict)
            } else {
                failBlock( NSDictionary(dictionary: ["error" : rc]))
            }
        }, failBlock: { (errorCode:String) in
            DDLogVerbose("Fail in requestTransferMoney")
            //In Demo, due to hardcode invalid url, app flow will go to this
            //Get the static JSON response from online host
            self.sendToGetDummyJsonFromHost(successBlock: { (resDict: NSDictionary) in
                DDLogVerbose("Dummy Server Accept")
                successBlock(resDict)
            }, failBlock: { (errorCode:NSDictionary) in
                failBlock(errorCode)
            })
        })

    }
    
    //A dummy API call with static JSON reponse from online hosting
    private func sendToGetDummyJsonFromHost(successBlock: @escaping (NSDictionary)-> (), failBlock: @escaping (NSDictionary)-> ()) {
        DDLogVerbose("sendToGetDummyJsonFromHost")
        Alamofire.request(URL(string: TMConfig().getDummyJsonResponse())!)
            .validate(statusCode: 200..<500) //Checking HTTP Status Code
            .responseJSON { (response) in
            switch (response.result) {
            case .success:
                DDLogVerbose("Response: \(response.result.value! as Any)")
                successBlock(response.result.value as! NSDictionary)
                break
            case .failure(let error):
                DDLogError("\n\nAuth request failed with error:\n\(error)\n\(error.localizedDescription)")
                failBlock(response.result.value as! NSDictionary)
                break
            }
        }
    }
}
