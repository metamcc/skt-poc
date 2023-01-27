//
//  MainCreditTVCell.swift
//  mcc-mvp
//
//  Created by JIK on 2018. 9. 13..
//  Copyright © 2018년 jakejeong. All rights reserved.
//

import UIKit

class MainCreditTVCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel : UILabel!
    @IBOutlet weak var mainTitleLabel : UILabel!
    @IBOutlet weak var subTitleLabel : UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
