//
//  CreateScrappingStepTVCell.swift
//  mcc-mvp
//
//  Created by jakejeong on 2018. 9. 17..
//  Copyright © 2018년 jakejeong. All rights reserved.
//

import UIKit

protocol CreateScrappingStepTVCellDelegate : NSObjectProtocol {
    func CreateScrappingStepTVCellDidSelectDetail(cell : CreateScrappingStepTVCell)
}


class CreateScrappingStepTVCell: UITableViewCell {

    @IBOutlet weak var titleLabel : UILabel?
    @IBOutlet weak var loadingImageView: UIImageView?
    
    @IBOutlet weak var baseBgView: UIView?
    
    @IBOutlet weak var acionBtn: UIButton?
    
    internal weak var delegate : CreateScrappingStepTVCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.loadingImageView?.image = UIImage(named: "ic_nor_check")
        
        self.baseBgView?.layer.cornerRadius = 10
        self.baseBgView?.clipsToBounds = true
        self.baseBgView?.borderWidth = 0.5
        self.baseBgView?.shadowColor = UIColor.lightGray
        self.baseBgView?.shadowOffsetX = -1
        self.baseBgView?.shadowOffsetY = 1
        self.baseBgView?.shadowRadius = 15
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func didTouchDetailAction() {
        delegate?.CreateScrappingStepTVCellDidSelectDetail(cell: self)
    }
    func normalStat() {
        self.loadingImageView?.image = UIImage(named: "ic_nor_check")
        self.loadingImageView?.highlightedImage = UIImage(named: "ic_nor_check")
    }
    func startStat() {
        self.loadingImageView?.image = UIImage(named: "ic_done_check")
    }
    func scrappingComplete() {
        self.loadingImageView?.image = UIImage(named: "ic_done_check")
        self.loadingImageView?.highlightedImage = UIImage(named: "ic_done_check")
    }
    let kRotationAnimationKey = "com.myapplication.rotationanimationkey" // Any key
    func runningScrapping(){
        self.loadingImageView?.image = UIImage(named: "ic_rotate_circle_loading")
        self.loadingImageView?.highlightedImage = UIImage(named: "ic_rotate_circle_loading")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if self.loadingImageView?.layer.animation(forKey: self.kRotationAnimationKey) == nil {
                let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
                rotationAnimation.fromValue = 0.0
                rotationAnimation.toValue = Float(Double.pi * 2.0)
                rotationAnimation.duration = 1.0
                rotationAnimation.repeatCount = Float.infinity
                self.loadingImageView?.layer.add(rotationAnimation, forKey: self.kRotationAnimationKey)
            }
        }
    }
    
    func stopScrapping() {
        if self.loadingImageView?.layer.animation(forKey: kRotationAnimationKey) != nil {
            self.loadingImageView?.layer.removeAnimation(forKey: kRotationAnimationKey)
            self.loadingImageView?.image = UIImage(named: "ic_nor_check")
            self.loadingImageView?.highlightedImage = UIImage(named: "ic_rotate_circle_loading")
        }
    }

}
