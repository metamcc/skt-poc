//
//  TransactionDataModel.swift
//  mcc-mvp
//
//  Created by jakejeong on 2018. 9. 17..
//  Copyright © 2018년 jakejeong. All rights reserved.
//

import UIKit

class TransactionDataModel: NSObject {
    public var owneraddress: String! = nil
    public var provideraddr: String! = nil
    public var datakey: String! = nil
    public var date: String! = nil
    public var creditid: String! = nil
    public var transactionkey: String! = nil
    
    init(_owner : String, _provider : String, _dataKey : String, _date : String, _creditId : String, _transactionKey : String) {
        self.owneraddress = _owner
        self.provideraddr = _provider
        self.datakey = _dataKey
        self.date = _date
        self.creditid = _creditId
        self.transactionkey = _transactionKey
    }
}
