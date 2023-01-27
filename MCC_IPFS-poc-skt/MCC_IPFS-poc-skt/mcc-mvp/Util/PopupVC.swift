//
//  PopupVC.swift
//  mcc-mvp
//
//  Created by jakejeong on 2018. 5. 18..
//  Copyright © 2018년 jakejeong. All rights reserved.
//

import UIKit

protocol PopupVCDelegate: class {
//    func onSelectNPKI(selected: Int)
}

class PopupVC: UIViewController {

    internal var object : [String:Any] = [:]
    weak var pDelegate : PopupVCDelegate? = nil
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
