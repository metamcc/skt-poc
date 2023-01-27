//
//  OrderStepSelectTVCell.swift
//  mcc-mvp
//
//  Created by JIK on 2018. 9. 16..
//  Copyright © 2018년 jakejeong. All rights reserved.
//

import UIKit

class OrderStepSelectTVCell: UITableViewCell {

    @IBOutlet weak var titleLabel : UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        DispatchQueue.main.async {
            if selected == true {
                let isCompany = UserDefaults.standard.bool(forKey: MCCDefault.kUserIsCompany)
                self.tintColor = isCompany == true ?  UIColor.init(red: 21/255, green: 35/255, blue: 189/255, alpha: 1) : UIColor.init(red: 235/255, green: 64/255, blue: 77/255, alpha: 1)
            }
            else{
                self.tintColor = UIColor.lightGray
            }
        }
        // Configure the view for the selected state
    }

}
