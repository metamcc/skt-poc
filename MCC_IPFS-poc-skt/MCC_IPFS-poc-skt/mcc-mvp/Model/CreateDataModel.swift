//
//  CreateDataModel.swift
//  mcc-mvp
//
//  Created by jakejeong on 2018. 9. 17..
//  Copyright © 2018년 jakejeong. All rights reserved.
//

import UIKit

class CreateDataModel: NSObject {
    public var gender: Int! = NSNotFound
    public var maxage: Int! = NSNotFound
    public var minage: Int! = NSNotFound
    public var needdatatype: String! = nil
    public var owneraddress: String! = nil
    public var creditid: String! = nil
    public var livelocation: Int! = NSNotFound
    
    func clearAll(){
        self.gender = NSNotFound
        self.maxage = NSNotFound
        self.minage = NSNotFound
        self.needdatatype = nil
        self.owneraddress = nil
        self.creditid = nil
        self.livelocation = NSNotFound
    }
}
