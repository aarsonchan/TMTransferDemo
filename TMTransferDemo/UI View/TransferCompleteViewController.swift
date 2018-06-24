//
//  TransferCompleteViewController.swift
//  TMTransferDemo
//
//  Created by ChanAarson on 21/6/2018.
//  Copyright © 2018 Aarson Chan. All rights reserved.
//

import UIKit

class TransferCompleteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Properties
    private var imgComplete:UIImageView!
    private var lblComplete:UILabel!
    private var tableView:UITableView!
    private var btnBack:UIButton!
    private var status:String!
    private var refNum:String!
    private var dateTime:String!
    private var payerAccnNum:String!
    private var payeeAccnNum:String!
    private var amount:String!
    private var currency:String!
    
    // MARK: - View Life Cycle
    convenience init(status: String, amount:String, currency:String, payerAccnNum:String, payeeAccnNum:String, refNum:String, dateTime:String) {
        self.init()
        self.status = status
        self.amount = amount
        self.currency = currency
        self.payerAccnNum = payerAccnNum
        self.payeeAccnNum = payeeAccnNum
        self.refNum = refNum
        self.dateTime = dateTime
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.title = NSLocalizedString("Money Transfer", comment: "")
        self.navigationItem.setHidesBackButton(true, animated:true);
        
        self.addImgCompleteToView()
        self.addLblCompleteToView()
        self.addBtnBackToView()
        self.addTableViewToView()
    }
    
    private func addImgCompleteToView() {
        self.imgComplete = UIImageView(image: UIImage(named: "complete")?.withRenderingMode(.alwaysTemplate))
        self.imgComplete.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.imgComplete)
        self.imgComplete.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 120.0).isActive = true
        self.imgComplete.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.imgComplete.widthAnchor.constraint(equalToConstant: 60).isActive = true
        self.imgComplete.heightAnchor.constraint(equalTo:self.imgComplete.widthAnchor).isActive = true
        //Configurations
        self.imgComplete.tintColor = .red
    }
    
    private func addLblCompleteToView() {
        self.lblComplete = UILabel(frame: .zero)
        self.lblComplete.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.lblComplete)
        self.lblComplete.topAnchor.constraint(equalTo: self.imgComplete.bottomAnchor, constant: 5.0).isActive = true
        self.lblComplete.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.lblComplete.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.9).isActive = true
        self.lblComplete.heightAnchor.constraint(equalToConstant:30.0).isActive = true
        //Configurations
        self.lblComplete.font = UIFont.systemFont(ofSize: 17.0)
        self.lblComplete.textColor = .black
        self.lblComplete.textAlignment = .center
        self.lblComplete.text = NSLocalizedString("Your instruction has been processed", comment: "")
    }
    
    private func addBtnBackToView() {
        self.btnBack = UIButton(type: .custom)
        self.btnBack.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.btnBack)
        self.btnBack.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -40.0).isActive = true
        self.btnBack.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        self.btnBack.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier:0.8).isActive = true
        self.btnBack.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        //Configurations
        self.btnBack.layer.cornerRadius = 10.0
        self.btnBack.layer.masksToBounds = true
        self.btnBack.backgroundColor = .red
        self.btnBack.setTitleColor(.white, for: .normal)
        self.btnBack.setTitle(NSLocalizedString("Do another transfer", comment: ""), for: .normal)
        self.btnBack.addTarget(self, action: #selector(goBack), for: .touchUpInside)
    }

    private func addTableViewToView() {
        self.tableView = UITableView(frame: .zero, style: .plain)
        self.view.addSubview(self.tableView)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.topAnchor.constraint(equalTo: self.lblComplete.bottomAnchor, constant: 50.0).isActive = true
        self.tableView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.tableView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.btnBack.topAnchor, constant: -10.0).isActive = true
        //Config
        self.tableView.isScrollEnabled = false
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.allowsSelection = false
    }
    
    // MARK: - Table Configurations
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:TransferCompleteTableViewCell = TransferCompleteTableViewCell.init(style: .default, reuseIdentifier: "Cell")
            switch indexPath.row {
            case 0:
                cell.lblMain.text = NSLocalizedString("From", comment: "")
                cell.lblSub.text = payerAccnNum
                break
            case 1:
                cell.lblMain.text = NSLocalizedString("To", comment: "")
                cell.lblSub.text = payeeAccnNum
                break
            case 2:
                let amountStr = String(format: "%.2f", Double.init(amount)!)
                cell.lblMain.text = NSLocalizedString("Amount", comment: "")
                cell.lblSub.text = amountStr + NSLocalizedString(" HKD", comment: "")
                break
            case 3:
                cell.lblMain.text = NSLocalizedString("Ref. Nmber", comment: "")
                cell.lblSub.text = refNum
                break
            case 4:
                cell.lblMain.text = NSLocalizedString("Date and Time", comment: "")
                cell.lblSub.text = dateConvert(oriDateTime: self.dateTime)
                break
            default:
                break
            }
        return cell
    }
    
    // MARK: - Actions
    //Start another monet transfer
    @objc private func goBack() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: - Others
    //Date Time Convertion for Server format to UI display Format
    private func dateConvert(oriDateTime:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmssSSS"
        let newDate = dateFormatter.date(from: self.dateTime)
        dateFormatter.dateFormat = "dd MMM yyyy HH:mm"
        let convertedDate = dateFormatter.string(from: newDate!)
        return convertedDate
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
