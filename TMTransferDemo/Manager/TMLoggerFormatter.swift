//
//  TMLoggerFormatter.swift
//  TMTransferDemo
//
//  Created by ChanAarson on 22/6/2018.
//  Copyright © 2018 Aarson Chan. All rights reserved.
//

import UIKit

class TMLoggerFormatter: NSObject, DDLogFormatter {

    let dateFormmater = DateFormatter()
    
    public override init() {
        super.init()
        dateFormmater.dateFormat = "yyyy/MM/dd HH:mm:ss:SSS"
    }
    
    //MARK: - DDLogFormatter
    //Customize Logger Format
    public func format(message logMessage: DDLogMessage) -> String? {
        
        let logLevel: String
        switch logMessage.flag {
        case DDLogFlag.error:
            logLevel = "ERROR"
        case DDLogFlag.warning:
            logLevel = "WARNING"
        case DDLogFlag.info:
            logLevel = "INFO"
        case DDLogFlag.debug:
            logLevel = "DEBUG"
        default:
            logLevel = "VERBOSE"
        }
        
        let dt = dateFormmater.string(from: logMessage.timestamp)
        let logMsg = logMessage.message
        let lineNumber = logMessage.line
        let file = logMessage.fileName
        let threadId = logMessage.threadID
        
        return "\(dt) [\(threadId)] [\(logLevel)] [\(file):\(lineNumber)] - \(logMsg)"
    }
}
