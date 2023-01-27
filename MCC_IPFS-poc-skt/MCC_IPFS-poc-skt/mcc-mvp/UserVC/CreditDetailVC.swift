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

class CreditDetailVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var dataSource : [SCRData] = [SCRData(type: .pay),SCRData(type: .workingyear),SCRData(type: .bankhistory),SCRData(type: .insurance)]
    
    var selectedSource : [Int] = [1,1,1,1]
    
    var creditData : Credit?
    var transactionDataSource = [Transaction]()
    
    @IBOutlet weak var tableView : UITableView!
    
    @IBOutlet weak var registRequestBtn : UIButton!
    
    @IBOutlet weak var mainTitleLabel : UILabel!
    @IBOutlet weak var dateLabel : UILabel!
    
    @IBOutlet weak var topLabel : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let isCompany = UserDefaults.standard.bool(forKey: MCCDefault.kUserIsCompany)
        
        
        self.mainTitleLabel.text = creditData?.ownername
        self.dateLabel.text = creditData?.creditdate
        
        self.tableView.reloadData()
//
//        let closeBtn = UIButton.init(type: .custom)
//        closeBtn.setTitle("닫기", for: .normal)
//        closeBtn.setTitle("닫기", for: .highlighted)
//        closeBtn.setTitleColor(UIColor.darkGray, for: .normal)
//        closeBtn.setTitleColor(UIColor.black, for: .highlighted)
//        closeBtn.addTarget(self, action: #selector(didTouchCloseAction), for: .touchUpInside)
//        let close = UIBarButtonItem.init(customView: closeBtn)
        
        let leftBarButton = UIBarButtonItem(image: UIImage(named: "img-close"), style: UIBarButtonItemStyle.done, target: self, action: #selector(didTouchCloseAction))
        self.navigationItem.leftBarButtonItems = [leftBarButton]
        
        self.requestMyTransactionCredit(success: {
            let rightBarButton = UIBarButtonItem(title: "내 데이터 삭제", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.didTouchRemoveMyDataAction))
            rightBarButton.tintColor = UIColor.white
            self.navigationItem.rightBarButtonItem = rightBarButton
        }, credit: self.creditData!)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        var index = 0
        for result in selectedSource {
            if result == 1 {
                self.tableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .none)
            }
            index += 1
        }
    }
    func requestDeleteMyIPFSData( transactionDataKey : String, providerAddress : String) {
        HUD.show(.labeledRotatingImage(image: UIImage(named: "mcc-loading"), title: nil, subtitle: nil))
        //        let userAddress = UserDefaults.standard.string(forKey: MCCDefault.kWalletAddress)
        
        var parameter : [String:String] = [:]
        parameter.append("transaction", forKey: "ccId")
        parameter.append("deleteMyIPFSData", forKey: "ccFnc")
        parameter.append(transactionDataKey, forKey: "param1")
        parameter.append(providerAddress, forKey: "param2")
        print(parameter)
        
        MCCRequest.Instance.requestQuery(parameter: parameter, success: { (resultArray) in
            
            HUD.hide(afterDelay: 0.1, completion: { (completed) in
                DispatchQueue.main.async {
                    self.showAlert(message: "데이터가 삭제되었습니다.", actionMesage: "확인", actionStyle: .default, actionBlock: {
                        self.didTouchCloseAction()
                    })
                }
            })
        }) { (error) in
            HUD.hide(afterDelay: 0.1, completion: { (completed) in
                self.showAlert(message: "데이터가 삭제 실패했습니다. 잠시후 다시 시도해주세요.", actionMesage: "확인", actionStyle: .default, actionBlock: {
//                    self.navigationController?.popViewController(animated: true)
                })
            })
        }
    }
    func requestMyTransactionCredit(success : alertAction?, credit : Credit) {
        HUD.show(.labeledRotatingImage(image: UIImage(named: "mcc-loading"), title: nil, subtitle: nil))
        //        let userAddress = UserDefaults.standard.string(forKey: MCCDefault.kWalletAddress)
        
        var parameter : [String:String] = [:]
        parameter.append("transaction", forKey: "ccId")
        parameter.append("queryMyTransactionCredit", forKey: "ccFnc")
        parameter.append(" ", forKey: "param1")
        parameter.append(" ", forKey: "param2")
        parameter.append(credit.creditid, forKey: "param3")
        print(parameter)
        
        MCCRequest.Instance.requestQuery(parameter: parameter, success: { (resultArray) in
            //            print(resultArray)
            let userAddress = UserDefaults.standard.string(forKey: MCCDefault.kWalletAddress)
            self.transactionDataSource.removeAll()
            for r in (resultArray as? [Any])! {
                let transaction = Transaction.init(json: r as! Dictionary<String, Any>)
                if transaction.provideraddr == userAddress {
                    self.transactionDataSource.append(transaction)
                }
                print(transaction)
            }
            if self.transactionDataSource.isNotEmpty {
                self.transactionDataSource.sort(by: { $0.dateObject().compare($1.dateObject()) == .orderedDescending})
                //                self.reportBtn.badge = NSNumber(value: self.transactionDataSource.count).stringValue
                HUD.hide(afterDelay: 0.1, completion: { (completed) in
                    if success != nil {
                        success!()
                    }
                })
            } else {
                HUD.hide(afterDelay: 0.1, completion: { (completed) in
//                    self.showAlert(message: "내가 등록한 데이터가 없습니다.", actionMesage: "확인", actionStyle: .default, actionBlock: nil)
                    print("내가 등록한 데이터가 없네요.")
                })
            }
            
        }) { (error) in
            print(error)
            
            if self.transactionDataSource.isEmpty{
                HUD.hide(afterDelay: 0.1, completion: { (completed) in
//                    self.showAlert(message: "해당 요청건에 내가 등록한 데이터가 없습니다.", actionMesage: "확인", actionStyle: .default, actionBlock: nil)
                })
            }
            else {
                HUD.hide(afterDelay: 0.1, completion: { (completed) in
                    print(error)
                })
            }
        }
    }
    @IBAction func didTouchBackAction() {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func didTouchCloseAction() {
        self.navigationController?.dismiss(animated: true, completion: {
            
        })
    }
    @IBAction func didTouchRemoveMyDataAction() {
        if self.transactionDataSource.isEmpty {
            return;
        }
        let transaction = self.transactionDataSource.first
        self.requestDeleteMyIPFSData(transactionDataKey: (transaction?.transactionkey)!, providerAddress: (transaction?.provideraddr)!)
    }
    @IBAction func didTouchRegistRequestAction(){
        
        print(selectedSource)
        guard let data = try? JSONSerialization.data(withJSONObject: selectedSource, options: []) else {
            return;
        }
        
        DataCreate.Shared.createCreditModel.needdatatype =  String(data: data, encoding: String.Encoding.utf8)

        var creditList : [SCRData] = []
        var index : Int
        index = 0
        for r in self.selectedSource {
            if r == 1 {
                creditList.append(self.dataSource[index])
            }
            index += 1
        }
        self.readyScrapping(selectData: creditList,  actionBlock: {
            self.performSegue(withIdentifier: MCCSegueKeys.showScrappingVC, sender: creditList)
        })
        
//        showAlertWithBlock(okActionBlock: {
//            print("showAlert2 실행되었습니다.")
//            DispatchQueue.main.async {
//
////                HUD.show(.labeledRotatingImage(image: UIImage(named: "mcc-loading"), title: nil, subtitle: nil))
////                var list = [String]
//
//                var creditList : [SCRData] = []
//                var index : Int
//                index = 0
//                for r in self.selectedSource {
//                    if r == 1 {
//                        creditList.append(self.dataSource[index])
//                    }
//                    index += 1
//                }
//                self.readyScrapping(selectData: creditList,  actionBlock: {
//                    self.performSegue(withIdentifier: MCCSegueKeys.showScrappingVC, sender: creditList)
//                })
//
//            }
//        }) {
//            self.showAlert(message: "비밀번호 입력이 취소되었습니다.", actionMesage: "확인", actionStyle: UIAlertActionStyle.default, actionBlock: nil)
//        }
        
        
    }
    
    func readyScrapping(selectData : [SCRData],  actionBlock : alertAction?) {
        let omniDocMgr = OmniDocMgr.shared
        omniDocMgr.clearParams()
//        var mw24Login: Bool = false
//        let userDefault = UserDefaults.standard
        
        
        for r in selectData as [SCRData] {
            if r.type == SCRData.DATA.pay {
                omniDocMgr.addNTS(type: Int(OmniDoc.FH_NTS_SODEUK_BONGGUP),
                                  saupjaNum: "",
                                  usage: OmniDoc.FH_NTS_USAGE_LOAN,
                                  submit: OmniDoc.FH_NTS_SUBMIT_GUMYOONG,
                                  rrn: "N",
                                  address: "Y",
                                  contact: "N",
                                  lang: "N")
            } else if r.type == SCRData.DATA.workingyear {
                omniDocMgr.addParam(type: Int(OmniDoc.FH_NHIS_JAGEOK), op1: "", op2: "", op3: "", op4: "N", op5: "", op6: "", op7: "", op8: "", op9: "", op10: "", lang: "")
            } else if r.type == SCRData.DATA.bankhistory {
                omniDocMgr.addECAR(cNum: UserDefaults.standard.string(forKey: MCCDefault.kUserCarNum) ?? "", mNum: "")
            }  else if r.type == SCRData.DATA.insurance {
                omniDocMgr.addParam(type: Int(OmniDoc.FH_4INSU_GAIB), op1: "", op2: "", op3: "", op4: "N", op5: "", op6: "", op7: "", op8: "", op9: "", op10: "", lang: "")
            }
        }
        
        omniDocMgr.sortParams()
        omniDocMgr.npkiPath = UserDefaults.standard.string(forKey: MCCDefault.kUserNPKIPATH)
        omniDocMgr.name = UserDefaults.standard.string(forKey: MCCDefault.kUserName)
        omniDocMgr.rrn1 = UserDefaults.standard.string(forKey: MCCDefault.kUserRRN01)
        omniDocMgr.rrn2 = UserDefaults.standard.string(forKey: MCCDefault.kUserRRN02)
        
        if actionBlock != nil {
            actionBlock!()
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
        let alert: UIAlertController = UIAlertController(title: "MCC", message: "정보 제공에 동의하면 비밀번호를 입력하세요.", preferredStyle: UIAlertControllerStyle.alert)
        
        // Cancel action generation.
        let CancelAction = UIAlertAction(title: "취소", style: UIAlertActionStyle.destructive) { (action: UIAlertAction!) -> Void in
            print("취소")
            cancelActionBlock!()
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
            okActionBlock!()
        }
        alert.addTextField { (textField: UITextField!) -> Void in
            textField.isSecureTextEntry = true
            textField.keyboardType = .numberPad
        }
        alert.addAction(CancelAction)
        alert.addAction(OkAction)
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
        let data = self.dataSource[indexPath.row] as SCRData
        cell.titleLabel?.text = data.string()
        return cell;
    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        selectedSource[indexPath.row] = 1
//    }
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        selectedSource[indexPath.row] = 0
//    }
//
    
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        if  MCCSegueKeys.showScrappingVC == segue.identifier {
            let orderListDetailVC = segue.destination as! CreateScrapingVC
            orderListDetailVC.dataSource = (sender as? [SCRData])!
            orderListDetailVC.creditData = self.creditData
        }
     }
    
}
