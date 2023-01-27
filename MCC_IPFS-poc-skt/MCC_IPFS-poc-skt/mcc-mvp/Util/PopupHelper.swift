//
//  PopupHelper.swift
//  mcc-mvp
//
//  Created by jakejeong on 2018. 5. 18..
//  Copyright © 2018년 jakejeong. All rights reserved.
//

import Foundation
import STPopup
class PopupHelper{
    
    /// Show a popup using the STPopup framework [STPopup on Cocoapods](https://cocoapods.org/pods/STPopup)
    /// - parameters:
    ///   - storyBoard: the name of the storyboard the popup viewcontroller will be loaded from
    ///   - popupName: the name of the viewcontroller in the storyboard to load
    ///   - viewController: the viewcontroller the popup will be popped up from
    ///   - blurBackground: boolean to indicate if the background should be blurred
    /// - returns: -
    static func showPopupFromStoryBoard( storyBoard: String, popupName: String, viewController: UIViewController, blurBackground: Bool, size : CGSize, sender : Dictionary<String,Any>?){
        let storyboard = UIStoryboard(name: storyBoard, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: popupName) as? PopupVC
        if sender != nil {
            vc?.object = sender!
        }
        vc?.contentSizeInPopup =  size
        vc?.landscapeContentSizeInPopup = size
        let popup = STPopupController(rootViewController: vc!)
        popup.style = STPopupStyle.formSheet
        
        if blurBackground{
            let blurEffect = UIBlurEffect.init(style: UIBlurEffectStyle.dark)
            if ((NSClassFromString("UIBlurEffect")) != nil) {
                popup.backgroundView = UIVisualEffectView(effect: blurEffect)
            }
        }
        DispatchQueue.main.async {
            popup.present(in: viewController)
        }
    }
    
    static func showPopupFromStoryBoard(style: STPopupStyle,  storyBoard: String, popupName: String, viewController: UIViewController, delegate:UIViewController?, blurBackground: Bool, size : CGSize, sender : Dictionary<String,Any>?){
        let storyboard = UIStoryboard(name: storyBoard, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: popupName) as? PopupVC
        if sender != nil {
            vc?.object = sender!
        }
        vc?.contentSizeInPopup =  size
        vc?.landscapeContentSizeInPopup = size
        (vc as! SelectNPKIVC).delegate  = delegate as? SelectNPKIDelegate
        let popup = STPopupController(rootViewController: vc!)
        popup.style = style
        
        if blurBackground{
            let blurEffect = UIBlurEffect.init(style: UIBlurEffectStyle.dark)
            if ((NSClassFromString("UIBlurEffect")) != nil) {
                popup.backgroundView = UIVisualEffectView(effect: blurEffect)
            }
        }
        DispatchQueue.main.async {
            popup.present(in: viewController)
        }
    }
}
