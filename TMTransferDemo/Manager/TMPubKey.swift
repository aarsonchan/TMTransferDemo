//
//  TMPubKey.swift
//  TMTransferDemo
//
//  Created by ChanAarson on 22/6/2018.
//  Copyright © 2018 Aarson Chan. All rights reserved.
//

import UIKit

class TMPubKey: NSObject {
    var pubKeyName: String
    var pubKeyValue: String
    
    init(name: String, value:String) {
        pubKeyName = name
        pubKeyValue = value
    }
}
