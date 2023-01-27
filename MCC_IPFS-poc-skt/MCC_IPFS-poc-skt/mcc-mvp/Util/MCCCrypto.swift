//
//  MCCCrypto.swift
//  mcc-mvp
//
//  Created by jakejeong on 2018. 5. 18..
//  Copyright © 2018년 jakejeong. All rights reserved.
//

import Foundation
import RNCryptor

class MCCCrypto: NSObject {
    static var Instance = MCCCrypto()
    
   internal  func encryptMessage(message: String, encryptionKey: String) throws -> String {
        let messageData = message.data(using: .utf8)!
        let cipherData = RNCryptor.encrypt(data: messageData, withPassword: encryptionKey)
        return cipherData.base64EncodedString()
    }
    
   internal  func decryptMessage(encryptedMessage: String, encryptionKey: String) throws -> String {
        
        let encryptedData = Data.init(base64Encoded: encryptedMessage)!
        let decryptedData = try RNCryptor.decrypt(data: encryptedData, withPassword: encryptionKey)
        let decryptedString = String(data: decryptedData, encoding: .utf8)!
        
        return decryptedString
    }
}
