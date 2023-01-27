//
//  OrderStep2VC.swift
//  mcc-mvp
//
//  Created by jakejeong on 2018. 9. 17..
//  Copyright © 2018년 jakejeong. All rights reserved.
//

import UIKit

import STPopup
import PKHUD
import BFKit

class OrderStep2VC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    /*
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
    */
    
    var dataSource : [String] = ["소득 정보","사회 경력(근속연수)","차량 보유 여부","4대 보험 가입정보"]
    
    var selectedSource : [Int] = [0,0,0,0]
    
    @IBOutlet weak var tableView : UITableView!
    
    @IBOutlet weak var registRequestBtn : UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let isCompany = UserDefaults.standard.bool(forKey: MCCDefault.kUserIsCompany)
        
        self.registRequestBtn.backgroundColor = isCompany == true ?  UIColor.init(red: 21/255, green: 35/255, blue: 189/255, alpha: 1) : UIColor.init(red: 235/255, green: 64/255, blue: 77/255, alpha: 1)
        

//        let nextBtn = UIButton.init(type: .custom)
//        nextBtn.setTitle("뒤로", for: .normal)
//        nextBtn.setTitle("뒤로", for: .highlighted)
//        nextBtn.setTitleColor(UIColor.white, for: .normal)
//        nextBtn.setTitleColor(UIColor.white, for: .highlighted)
//        nextBtn.tintColor = UIColor.white
//        nextBtn.addTarget(self, action: #selector(didTouchBackAction), for: .touchUpInside)
//        let next = UIBarButtonItem.init(customView: nextBtn)
//
//        self.navigationItem.backBarButtonItem = next
//        // Do any additional setup after loading the view.
        
        
//        let leftBarButton = UIBarButtonItem(title: "⟨", style: UIBarButtonItemStyle.done, target: self, action: #selector(didTouchBackAction))
        let leftBarButton = UIBarButtonItem(image: UIImage(named: "img-back"), style: UIBarButtonItemStyle.done, target: self, action: #selector(didTouchBackAction))
        leftBarButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftBarButton
        
    }
    @IBAction func didTouchBackAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTouchRegistRequestAction(){
        
        
        let selectedCells : [IndexPath] = self.tableView.indexPathsForSelectedRows!;
        var index = 0
        var selectArray = [Int]()
        for indexPath in selectedCells {
            if selectedSource[indexPath.row] == 1 {
                if index == 0 {
                    selectArray.append(1)
                } else if index == 1 {
                    selectArray.append(2)
                } else if index == 2 {
                    selectArray.append(3)
                } else if index == 3 {
                    selectArray.append(4)
                }
            }
            index += 1
        }
        
        print(selectArray)
        guard let data = try? JSONSerialization.data(withJSONObject: selectArray, options: []) else {
            return;
        }
        
        DataCreate.Shared.createCreditModel.needdatatype =  String(data: data, encoding: String.Encoding.utf8)

        DispatchQueue.main.async {
            HUD.show(.labeledRotatingImage(image: UIImage(named: "mcc-loading"), title: nil, subtitle: nil))
            self.requestCreateCreditJob()
        }
        
//        showAlertWithBlock(okActionBlock: {
//            print("showAlert2 실행되었습니다.")
//            DispatchQueue.main.async {
//                HUD.show(.labeledRotatingImage(image: UIImage(named: "mcc-loading"), title: nil, subtitle: nil))
//                self.requestCreateCreditJob()
//            }
//
//        }) {
//            self.showAlert(message: "비밀번호 입력이 취소되었습니다.", actionMesage: "확인", actionStyle: UIAlertActionStyle.default, actionBlock: nil)
//        }
        
        
    }
    func requestCreateCreditJob() {
        
//        if self.genderIndex == NSNotFound {
//            return;
//        }
//
//        if self.locationIndex == NSNotFound {
//            return;
//        }
//
//        if self.userTypeIndex == NSNotFound {
//            return;
//        }
        
        var parameter : [String:String] = [:]
        parameter.append("credit", forKey: "ccId")
        parameter.append("createCreditJob", forKey: "ccFnc")
        parameter.append(NSNumber(value:DataCreate.Shared.createCreditModel.gender).stringValue, forKey: "param1")
        parameter.append(NSNumber(value:DataCreate.Shared.createCreditModel.maxage).stringValue, forKey: "param2")
        parameter.append(NSNumber(value:DataCreate.Shared.createCreditModel.minage).stringValue, forKey: "param3")
        parameter.append(DataCreate.Shared.createCreditModel.needdatatype, forKey: "param4")
        parameter.append(DataCreate.Shared.createCreditModel.owneraddress, forKey: "param5")
        parameter.append(NSNumber(value:DataCreate.Shared.createCreditModel.livelocation).stringValue, forKey: "param6")
        
        
        
        
        MCCRequest.Instance.requestInvoke(parameter: parameter, success: { (json) in
            
            print(json as Any)
            
            if json == nil {
                HUD.hide(afterDelay: 0.1, completion: { (completed) in
                    self.showAlert(message: "데이터가 등록에 실패 했습니다. 잠시후 다시시도해주세요.", actionMesage: "확인", actionStyle: UIAlertActionStyle.destructive, actionBlock: nil)
                    return
                })
            }
            
            DispatchQueue.main.async {
                HUD.hide(afterDelay: 0.1, completion: { (completed) in
                    self.showAlert(message: "데이터 등록이 완료되었습니다.", actionMesage: "확인", actionStyle: UIAlertActionStyle.default, actionBlock: {
                        self.navigationController?.dismiss(animated: true, completion: {});
                    })
                })
            }
            
        }) { (error) in
            HUD.hide(afterDelay: 0.1, completion: { (completed) in
                print(error)
            })
        }
        
    }
    
    func showAlert(message : String, actionMesage : String, actionStyle : UIAlertActionStyle, actionBlock : alertAction?) {
        // Alert generation.
        let alert: UIAlertController = UIAlertController(title: "MCC", message:message, preferredStyle: UIAlertControllerStyle.alert)
        
        // Cancel action generation.
        let OkAction = UIAlertAction(title: actionMesage, style: actionStyle) { (action: UIAlertAction!) -> Void in
            print("확인")
            if actionBlock != nil {
                actionBlock!()
            }
        }
        alert.addAction(OkAction)
        // Activate Alert.
        present(alert, animated: true, completion: nil)
    }
    
    func showAlertWithBlock(okActionBlock : alertAction?, cancelActionBlock : alertAction? ) {
        // Alert generation.
        let alert: UIAlertController = UIAlertController(title: "MCC", message: "데이터 의뢰를 신청하려면 비밀번호를 입력하세요.", preferredStyle: UIAlertControllerStyle.alert)
        
        // Cancel action generation.
        let CancelAction = UIAlertAction(title: "취소", style: UIAlertActionStyle.destructive) { (action: UIAlertAction!) -> Void in
            print("취소")
            if cancelActionBlock != nil {
                cancelActionBlock!()
            }
        }
        
        // OK action generation.
        let OkAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) { (action: UIAlertAction!) -> Void in
            print("확인")
            
            let tf1 : UITextField = alert.textFields![0]
            
            if tf1.text?.count == 0 {
                self.showAlertWithBlock(okActionBlock: okActionBlock, cancelActionBlock: cancelActionBlock)
                return
            }
            
            let localpassword = UserDefaults.standard.string(forKey: MCCDefault.kUserLocalPassword)
            
            if tf1.text != localpassword {
                self.showAlertWithBlock(okActionBlock: okActionBlock, cancelActionBlock: cancelActionBlock)
                return;
            }
            if okActionBlock != nil {
                okActionBlock!()
            }
        }
        
        // Added TextField to Alert.
        alert.addTextField { (textField: UITextField!) -> Void in
            
            // Hide the entered characters.
            textField.isSecureTextEntry = true
            textField.keyboardType = .numberPad
        }
        
        // Added action to Alert.
        alert.addAction(CancelAction)
        alert.addAction(OkAction)
        
        // Activate Alert.
        present(alert, animated: true, completion: nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderStepSelectTVCell", for: indexPath) as! OrderStepSelectTVCell
        cell.titleLabel?.text = self.dataSource[indexPath.row]
        return cell;
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedSource[indexPath.row] = 1
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selectedSource[indexPath.row] = 0
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
