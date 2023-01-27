//
//  DataShared.swift
//  mcc-mvp
//
//  Created by jakejeong on 2018. 9. 17..
//  Copyright © 2018년 jakejeong. All rights reserved.
//

import UIKit

class DataCreate: NSObject {
    static let Shared = DataCreate()
    public var createCreditModel = CreateDataModel()
    
    public var isCompany = NSNotFound
}



