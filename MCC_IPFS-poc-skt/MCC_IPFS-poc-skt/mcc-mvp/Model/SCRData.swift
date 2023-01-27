//
//  SCRData.swift
//  mcc-mvp
//
//  Created by jakejeong on 2018. 9. 18..
//  Copyright © 2018년 jakejeong. All rights reserved.
//

import UIKit

struct SCRData {
    // var dataSource : [String] = ["연봉","근속연수","은행거래내역","보험"]
    enum  DATA: Int {
        case none = 0, pay = 1, workingyear = 2, bankhistory = 3, insurance = 4
    }
    let type : DATA?
    let IsSelected : Bool = false
    
    init(type : DATA) {
        self.type = type
    }
    
    func string()->String {
        if self.type == .pay {
            return "소득금액증명" //국세청 소득금액증명서(봉급생활자)
        } else if self.type == .workingyear {
            return "건강보험자격확인" //국민건강보험 자격득실확인서
        } else if self.type == .bankhistory {
            return "자동차등록정보" // 국토교통부 자동차등록원부
        } else if self.type == .insurance {
            return "4대보험가입확인" //4대보험 가입내역확인서
        }
        return ""
    }
    
    func docId()->String {
        if self.type == .pay {
            return "NTS_SODEUK_BONGGUP"
        } else if self.type == .workingyear {
            return "NHIS_JAGEOK"
        } else if self.type == .bankhistory {
            return "ECAR_WONBU"
        } else if self.type == .insurance {
            return "INS4_GAIB"
        }
        return ""
    }
}
