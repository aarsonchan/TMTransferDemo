//
//  TransferCompleteTableViewCell.swift
//  TMTransferDemo
//
//  Created by ChanAarson on 24/6/2018.
//  Copyright © 2018 Aarson Chan. All rights reserved.
//

import UIKit

class TransferCompleteTableViewCell: UITableViewCell {

    var lblMain: UILabel!
    var lblSub: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.white
        self.addLblMainToView()
        self.addLblSubToView()
    }
    
    private func addLblMainToView() {
        self.lblMain = UILabel(frame:.zero)
        self.lblMain.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.lblMain)
        self.lblMain.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20.0).isActive = true
        self.lblMain.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier:0.5).isActive = true
        self.lblMain.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.lblMain.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        //Configurations
        self.lblMain.font = UIFont.systemFont(ofSize: 16.0)
        self.lblMain.textColor = UIColor.darkGray
    }
    
    private func addLblSubToView() {
        self.lblSub = UILabel(frame:.zero)
        self.lblSub.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.lblSub)
        self.lblSub.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20.0).isActive = true
        self.lblSub.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier:0.5).isActive = true
        self.lblSub.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.lblSub.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        //Configurations
        self.lblSub.font = UIFont.systemFont(ofSize: 16.0)
        self.lblSub.textColor = UIColor.darkGray
        self.lblSub.textAlignment = .right
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
