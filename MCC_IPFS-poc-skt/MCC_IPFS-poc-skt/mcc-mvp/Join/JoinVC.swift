//
//  JoinVC.swift
//  mcc-mvp
//
//  Created by jakejeong on 2018. 9. 13..
//  Copyright © 2018년 jakejeong. All rights reserved.
//

import UIKit

import PKHUD
import BFKit

protocol JoinVCVCDelegate : NSObjectProtocol {
    func JoinVCDidCompleted()
}

public typealias alertAction = () -> Void

class JoinVC: UIViewController {
    
    @IBOutlet weak var titleLabel : UILabel!
    
    @IBOutlet weak var emailBaseView : UIView!
    @IBOutlet weak var emailTF : UITextField!
    
    @IBOutlet weak var nickNameBaseView : UIView!
    @IBOutlet weak var nickNameTF : UITextField!
    
    @IBOutlet weak var ageBaseView : UIView!
    @IBOutlet weak var ageTF : UITextField!
    
    
    @IBOutlet weak var genderBaseView : UIView!
    @IBOutlet weak var malBtn: UIButton!
    @IBOutlet weak var femalBtn: UIButton!
    @IBOutlet var genderCollection: [UIButton]!
    
    var genderIndex : Int!
    
    @IBOutlet weak var userTypeBaseView : UIView!
    @IBOutlet weak var companyBtn: UIButton!
    @IBOutlet weak var userBtn: UIButton!
    @IBOutlet var userTypeCollection: [UIButton]!
    
    var userTypeIndex : Int!
    
    @IBOutlet weak var locationBaseView : UIView!
    @IBOutlet weak var seoulBtn: UIButton!
    @IBOutlet weak var kyunggiBtn: UIButton!
    @IBOutlet weak var inchonBtn: UIButton!
    @IBOutlet weak var etcBtn: UIButton!
    @IBOutlet var locationCollection: [UIButton]!
    
    var locationIndex : Int!
    
    @IBOutlet weak var genderHeightConstraint : NSLayoutConstraint!
    @IBOutlet weak var locationHeightConstraint : NSLayoutConstraint!
    @IBOutlet weak var ageHeightConstraint : NSLayoutConstraint!
    
    
    @IBOutlet weak var joinDoneBtn : UIButton!
    
    internal weak var delegate : JoinVCVCDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.joinDoneBtn.layer.cornerRadius = 10
        self.joinDoneBtn.clipsToBounds = true
        
        let viewArray = [self.ageBaseView, self.userTypeBaseView, self.emailBaseView, self.nickNameBaseView, self.locationBaseView, self.genderBaseView]
        
        self.genderHeightConstraint.constant = 0
        self.locationHeightConstraint.constant = 0
         self.ageHeightConstraint.constant = 0
        
        for v in viewArray {
            v?.layer.cornerRadius = 10
            v?.clipsToBounds = true
            v?.borderWidth = 0.5
            v?.borderColor = UIColor.lightGray
        }
        
        for btn in self.userTypeCollection {
            btn.setTitleColor(UIColor.lightGray, for: UIControlState.normal)
            btn.setTitleColor(UIColor.darkGray, for: UIControlState.selected)
            btn.isSelected = false
            btn.borderWidth = 0.5
            btn.borderColor = UIColor.color(color: .lightGray, alpha: 0.5)
        }
        for btn in self.locationCollection {
            btn.setTitleColor(UIColor.lightGray, for: UIControlState.normal)
            btn.setTitleColor(UIColor.darkGray, for: UIControlState.selected)
            btn.isSelected = false
            btn.borderWidth = 0.5
            btn.borderColor = UIColor.color(color: .lightGray, alpha: 0.5)
        }
        for btn in self.genderCollection {
            btn.setTitleColor(UIColor.lightGray, for: UIControlState.normal)
            btn.setTitleColor(UIColor.darkGray, for: UIControlState.selected)
            btn.isSelected = false
            btn.borderWidth = 0.5
            btn.borderColor = UIColor.color(color: .lightGray, alpha: 0.5)
        }
        
        
        
        self.userTypeIndex = NSNotFound;
        self.genderIndex = NSNotFound;
        self.locationIndex = NSNotFound
        
        print("Join VC ViewdidLoad")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func genderAction(sender : UIButton) {
        for btn  in self.genderCollection {
            if btn == sender {
                btn.isSelected = true
                btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.heavy)
            }
            else{
                btn.isSelected = false
                btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.light)
            }
        }
        self.genderIndex = sender.tag
    }
    @IBAction func locationAction(sender : UIButton) {
        for btn  in self.locationCollection {
            if btn == sender {
                btn.isSelected = true
                btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.heavy)
            }
            else{
                btn.isSelected = false
                btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.light)
            }
        }
        self.locationIndex = sender.tag
    }
    @IBAction func userTypeAction(sender : UIButton) {
        for btn  in self.userTypeCollection {
            if btn == sender {
                btn.isSelected = true
                btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.heavy)
            }
            else{
                btn.isSelected = false
                btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.light)
            }
        }
        self.userTypeIndex = sender.tag
        if self.companyBtn.isSelected {
            UIView.animate(withDuration: 0.15) {
                self.genderHeightConstraint.constant = 0
                self.locationHeightConstraint.constant = 0
                self.ageHeightConstraint.constant = 0
                self.view.needsUpdateConstraints()
            }
            
        } else {
            UIView.animate(withDuration: 0.15) {
                self.genderHeightConstraint.constant = 50
                self.locationHeightConstraint.constant = 50
                self.ageHeightConstraint.constant = 50
                self.view.needsUpdateConstraints()
            }
        }
    }
    
    @IBAction func didtouchDoenAction(sender : UIButton) {
        HUD.show(.labeledRotatingImage(image: UIImage(named: "mcc-loading"), title: nil, subtitle: nil))
        self .requestJoin();
        
    }
    
    func requestJoin() {
        
        if self.companyBtn.isSelected {
            self.genderIndex = 0;
            self.locationIndex = 0;
            self.ageTF.text = "40"
        } else {
            if self.genderIndex == NSNotFound {
                HUD.hide(afterDelay: 0.1, completion: { (completed) in
                })
                return;
            }
            
            if self.locationIndex == NSNotFound {
                HUD.hide(afterDelay: 0.1, completion: { (completed) in
                })
                return;
            }
            
            if self.userTypeIndex == NSNotFound {
                HUD.hide(afterDelay: 0.1, completion: { (completed) in
                })
                return;
            }
        }
        
        
        var parameter : [String:String] = [:]
        parameter.append("wallet", forKey: "ccId")
        parameter.append("createWallet", forKey: "ccFnc")
        parameter.append(self.emailTF.text!, forKey: "param1")
        parameter.append(self.nickNameTF.text!, forKey: "param2")
        parameter.append(NSNumber(value: self.genderIndex).stringValue, forKey: "param3")
        parameter.append(self.ageTF.text!, forKey: "param4")
        parameter.append(NSNumber(value: self.userTypeIndex).stringValue, forKey: "param5")
        parameter.append(NSNumber(value: self.locationIndex).stringValue, forKey: "param6")
        

        MCCRequest.Instance.requestInvoke(parameter: parameter, success: { (json) in
            
            let value = (json as AnyObject).value(forKey: "walletaddress");
            UserDefaults.standard.set(value, forKey: MCCDefault.kWalletAddress)
            
            let password = (json as AnyObject).value(forKey: "password");
            UserDefaults.standard.set(password, forKey: MCCDefault.kWalletPassword)
            
            let isCompany = self.userTypeIndex == 0 ? true : false
            
            UserDefaults.standard.set(isCompany, forKey: MCCDefault.kUserIsCompany)
            
            UserDefaults.standard.set(self.genderIndex, forKey: MCCDefault.kUserGender)
            UserDefaults.standard.set(self.locationIndex, forKey: MCCDefault.kUserLiveLocation)
            UserDefaults.standard.set(self.ageTF.text?.intValue, forKey: MCCDefault.kUserAge)
            
            
            DispatchQueue.main.async {
                HUD.hide(afterDelay: 0.1, completion: { (completed) in
                    self.delegate.JoinVCDidCompleted();
                    if isCompany == true {
                        self.navigationController?.dismiss(animated: true, completion: {});
                    } else {
                        self.performSegue(withIdentifier: MCCSegueKeys.showJoinDetailVC, sender: nil)
                    }
//                    self.showAlert(okActionBlock: {
//                        self.delegate.JoinVCDidCompleted();
//                        if isCompany == true {
//                            self.navigationController?.dismiss(animated: true, completion: {});
//                        } else {
//                            self.performSegue(withIdentifier: MCCSegueKeys.showJoinDetailVC, sender: nil)
//                        }
//                    })
                })
            }
            
        }) { (error) in
            HUD.hide(afterDelay: 0.1, completion: { (completed) in
                print(error)
            })
        }
        
    }
    func showAlert(okActionBlock : alertAction?) {
        
        var message = ""
        
        let isCompany = UserDefaults.standard.bool(forKey: MCCDefault.kUserIsCompany)
        
        message = isCompany == true ? "데이터 의뢰신청전에 확인할 비밀번호를 입력하세요." : "데이터 의뢰 동의에 확인할 비밀번호를 입력하세요"
        
        // Alert generation.
        let alert: UIAlertController = UIAlertController(title: "MCC", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        //        // Cancel action generation.
        //        let CancelAction = UIAlertAction(title: "취소", style: UIAlertActionStyle.destructive) { (action: UIAlertAction!) -> Void in
        //            print("취소")
        //        }
        
        // OK action generation.
        let OkAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) { (action: UIAlertAction!) -> Void in
            print("확인")
            let tf1 : UITextField = alert.textFields![0]
            let tf2 : UITextField = alert.textFields![1]
            
            if tf1.text?.count == 0 || tf2.text?.count == 0 {
                self.showAlert(okActionBlock: okActionBlock)
                return
            }
            
            if tf1.text != tf2.text {
                self.showAlert(okActionBlock: okActionBlock)
                return;
            }
            UserDefaults.standard.set(tf1.text, forKey: MCCDefault.kUserLocalPassword)
            okActionBlock!()
        }
        
        // Added TextField to Alert.
        alert.addTextField { (textField: UITextField!) -> Void in
            
            let stringAttributes: [NSAttributedStringKey : Any] = [
                .foregroundColor : UIColor.lightGray,
                .font : UIFont.systemFont(ofSize: 12.0)
            ]
            textField.attributedPlaceholder = NSAttributedString(string: "비밀번호를 입력하세요.", attributes: stringAttributes)
            textField.font = UIFont.systemFont(ofSize: 20)
            // Hide the entered characters.
            textField.isSecureTextEntry = true
            textField.keyboardType = .numberPad
        }
        
        // Added TextField to Alert.
        alert.addTextField { (textField: UITextField!) -> Void in
            
            let stringAttributes: [NSAttributedStringKey : Any] = [
                .foregroundColor : UIColor.lightGray,
                .font : UIFont.systemFont(ofSize: 12.0)
            ]
            textField.attributedPlaceholder = NSAttributedString(string: "한번더 입력하세요.", attributes: stringAttributes)
            textField.font = UIFont.systemFont(ofSize: 20)
            // Hide the entered characters.
            textField.isSecureTextEntry = true
            textField.keyboardType = .numberPad
        }
        
        // Added action to Alert.
//        alert.addAction(CancelAction)
        alert.addAction(OkAction)
        
        // Activate Alert.
        present(alert, animated: true, completion: nil)
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
