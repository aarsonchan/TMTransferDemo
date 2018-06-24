//
//  EnterAmountViewController.swift
//  TMTransferDemo
//
//  Created by ChanAarson on 21/6/2018.
//  Copyright © 2018 Aarson Chan. All rights reserved.
//

import UIKit
import PKHUD

class EnterAmountViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Properties
    private var lblAmount:UILabel!
    private var txtFieldAmount:UITextField!
    private var lblRemarks:UILabel!
    private var btnConfirm:UIButton!
    private var accnFrom:String!
    private var accnTo:String!
    
    // MARK: - View Life Cycle
    convenience init(accnFrom:String, accnTo:String) {
        self.init()
        self.accnFrom = accnFrom
        self.accnTo = accnTo
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        self.title = NSLocalizedString("Money Transfer", comment: "")
        
        self.addLblAmountToView()
        self.addTxtFieldAmountToView()
        self.addLblRemarksToView()
        self.addBtnConfirmToView()
        
        //Build secure channel with RSA & AES
        self.sendBuildSessionRequest()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //init textfield for new transfer
        self.txtFieldAmount.text = ""
        self.txtFieldAmount.becomeFirstResponder()
    }
    
    private func addLblAmountToView() {
        self.lblAmount = UILabel(frame: .zero)
        self.view.addSubview(self.lblAmount)
        self.lblAmount.translatesAutoresizingMaskIntoConstraints = false
        self.lblAmount.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100.0).isActive = true
        self.lblAmount.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.lblAmount.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8).isActive = true
        self.lblAmount.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        //Configurations
        self.lblAmount.font = UIFont.systemFont(ofSize: 20.0)
        self.lblAmount.textColor = .darkGray
        self.lblAmount.text = NSLocalizedString("Please Enter Amount", comment: "")
    }
    
    private func addTxtFieldAmountToView() {
        self.txtFieldAmount = UITextField(frame: .zero)
        self.view.addSubview(self.txtFieldAmount)
        self.txtFieldAmount.translatesAutoresizingMaskIntoConstraints = false
        self.txtFieldAmount.topAnchor.constraint(equalTo: self.lblAmount.bottomAnchor, constant: 5.0).isActive = true
        self.txtFieldAmount.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.txtFieldAmount.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8).isActive = true
        self.txtFieldAmount.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        //Configurations
        self.txtFieldAmount.becomeFirstResponder()
        self.txtFieldAmount.delegate = self
        self.txtFieldAmount.placeholder = NSLocalizedString("HKD", comment: "")
        self.txtFieldAmount.backgroundColor = .white
        self.txtFieldAmount.tintColor = .red
        self.txtFieldAmount.textColor = .black
        self.txtFieldAmount.keyboardType = .decimalPad
        self.txtFieldAmount.borderStyle = .roundedRect
    }
    
    private func addLblRemarksToView() {
        self.lblRemarks = UILabel(frame: .zero)
        self.view.addSubview(self.lblRemarks)
        self.lblRemarks.translatesAutoresizingMaskIntoConstraints = false
        self.lblRemarks.topAnchor.constraint(equalTo: self.txtFieldAmount.bottomAnchor).isActive = true
        self.lblRemarks.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.lblRemarks.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8).isActive = true
        self.lblRemarks.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
        //Configurations
        self.lblRemarks.font = UIFont.systemFont(ofSize: 12.0)
        self.lblRemarks.textColor = .red
        self.lblRemarks.text = NSLocalizedString("", comment: "")
    }

    private func addBtnConfirmToView() {
        self.btnConfirm = UIButton(type: .custom)
        self.view.addSubview(self.btnConfirm)
        self.btnConfirm.translatesAutoresizingMaskIntoConstraints = false
        self.btnConfirm.topAnchor.constraint(equalTo: self.lblRemarks.bottomAnchor, constant: 5.0).isActive = true
        self.btnConfirm.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.btnConfirm.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8).isActive = true
        self.btnConfirm.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        //Configurations
        self.btnConfirm.layer.cornerRadius = 10.0
        self.btnConfirm.layer.masksToBounds = true
        self.btnConfirm.backgroundColor = .red
        self.btnConfirm.setTitleColor(.white, for: .normal)
        self.btnConfirm.setTitle(NSLocalizedString("Confirm", comment: ""), for: .normal)
        self.btnConfirm.addTarget(self, action: #selector(goValidate), for: .touchUpInside)
        
    }
    
    //MARK: - Actions
    
    //Check for amount validation before sent to server
    //Amount should be input with values in proper format
    @objc private func goValidate() {
        if (txtFieldAmount.text?.isEmpty)! {
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Amount cannot be empty", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction) in
            }))
            self.present(alert, animated: true)
            return
        }
        
        let regEx = "^[0-9][0-9]*(\\.\\d{1,2})?$|^[\\.]([\\d][\\d]?)$"
        let matchArray = self.getMatchAmountFormat(for: regEx, in: txtFieldAmount.text!)
        DDLogVerbose("regex:\(matchArray)")
        if matchArray.count == 0 {
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Amount Format invalid", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction) in
            }))
            self.present(alert, animated: true)
            return
        }
        self.sendTransferRequest()
    }

    //Pass the success result to Complete Page for display
    private func goNextPage(status:String, refNum:String, dataTime:String) {
        let transferCompleteViewController = TransferCompleteViewController(status:status, amount:txtFieldAmount.text!, currency:"344", payerAccnNum:accnFrom, payeeAccnNum:accnTo, refNum:refNum, dateTime:dataTime)
        self.navigationController?.pushViewController(transferCompleteViewController, animated: true)
    }
    
    //API Request for Money Transfer
    //Suppose all data must be encrpyted (With AES) when send to server as this is high risk transaction
    //In this demo, dummy static json will be reponsed from online hosting
    private func sendTransferRequest() {
        self.showLoadingView()
        let messageManager:TMMessageManager = TMMessageManager.sharedInstance()
        messageManager.requestTransferMoney(amount:self.getAmountConvertToServer(amount: txtFieldAmount.text!), currency:"344", payerAccnNum:accnFrom, payeeAccnNum:accnTo, successBlock: { (responseDict: NSDictionary) in
            let jom = responseDict["jom"] as! NSDictionary
            let status = jom["status"]  as! String
            let refNum = jom["refNum"]  as! String
            let dataTime = jom["dateTime"]  as! String
            
            DispatchQueue.main.async {
                self.hideLoadingView()
                self.goNextPage(status: status, refNum: refNum, dataTime: dataTime)
            }
            
        }) { (errorDict: NSDictionary) in
            self.hideLoadingView()
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("some error", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action:UIAlertAction) in
            }))
            self.present(alert, animated: true)
        }
    }
    
    //API Request for Build Session
    //Random generate AES sysmmetric Key and pass to server with RSA public Key encrpted
    //After this processs, every API sent to server afterward will use that AES Key for encrpytion
    private func sendBuildSessionRequest() {
        let messageManager:TMMessageManager = TMMessageManager.sharedInstance()
        messageManager.requestBuildSession(successBlock: { (responseDict: NSDictionary) in
            //
        }) { (errorDict: NSDictionary) in
            //
        }
    }
    
    //MARK: - HUD indicator
    private func showLoadingView() {
        DispatchQueue.main.async {
            HUD.flash(.labeledRotatingImage(image: UIImage(named: "progress"), title: "Loading", subtitle: "Please wait"))
        }
    }
    
    private func hideLoadingView() {
        DispatchQueue.main.async {
            HUD.hide()
        }
    }
    
    //MARK: - TextField Delegate
    //Checking for text length of amount input cannot more than 20
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField == txtFieldAmount) {
            let theText:String = textField.text!
            if(range.length + range.location > theText.lengthOfBytes(using: .utf8)) {
                return false
            }
            let newLength:Int =  theText.lengthOfBytes(using: .utf8) +  string.lengthOfBytes(using: .utf8) - range.length;
            return (newLength <= 20) ? true : false
        } else {
            return true
        }
    }
    
    //MARK: - Others
    //Regular Expression Matching
    private func getMatchAmountFormat(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            DDLogVerbose("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    //Convert Amount to be Server readable format
    private func getAmountConvertToServer(amount:String) -> String {
        let doubleAmount = Double.init(amount)
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 20
        let intAmount = doubleAmount! * 100 as NSNumber
        let stringAmount = formatter.string(from: intAmount)
        return stringAmount!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
