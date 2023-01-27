//
//  MainV2VC.swift
//  mcc-mvp
//
//  Created by JIK on 2018. 5. 23..
//  Copyright © 2018년 jakejeong. All rights reserved.
//

import UIKit
import SwiftIpfsApi
import SwiftMultihash
import SwiftMultiaddr

import Alamofire
import PKHUD
import BFKit
import STPopup
import SWXMLHash

struct Transaction : Decodable {
    let owneraddress : String
    let provideraddr : String
    let datakey : String
    let date : String
    let creditid : String
    let transactionkey : String
    let providerusername : String
    
    init(json : Dictionary<String,Any>) {
        self.owneraddress = (json["owneraddress"] as? String)!
        self.provideraddr = (json["provideraddr"] as? String)!
        self.date = (json["date"] as? String)!
        self.datakey = (json["datakey"] as? String)!
        self.creditid = (json["creditid"] as? String)!
        self.transactionkey = (json["transactionkey"] as? String)!
        self.providerusername = (json["providerusername"] as? String)!
    }
    
    func dateObject()-> Date {
        if self.date.count <= 10 {
            return Date(parse: self.date, format: "yyyy-MM-dd", locale: "ko_KR")!
        }
        return Date(parse: self.date, format: "yyyy-MM-dd hh:mm a", locale: "ko_KR")!
    }
    
}

class ReportDetailVC: UIViewController, UITableViewDelegate, UITableViewDataSource, JoinVCVCDelegate{
    
    var refreshControl : UIRefreshControl!
    
    var dataSource = [Transaction]()
    
    var credit : Credit!
    
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var topTitleLabel : UILabel!
    @IBOutlet weak var creditTitle1Label : UILabel!
    @IBOutlet weak var creditTitle2Label : UILabel!
    @IBOutlet weak var creditTitle3Label : UILabel!
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "MainCreditTVCell", for: indexPath) as! MainCreditTVCell
        let transactionModel = self.dataSource[indexPath.row]
        cell.mainTitleLabel.text = "\(transactionModel.providerusername)"
//        cell.subTitleLabel.text = "요청 아이디 : \(transactionModel.creditid)"
        cell.dateLabel.text = "\(transactionModel.date)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let transactionModel = self.dataSource[indexPath.row]
        self.performSegue(withIdentifier: MCCSegueKeys.showReportVC, sender: transactionModel)
    }
    
    @IBAction func didTouchAddCreditInfo(sender : UIButton!) {
        self.performSegue(withIdentifier: MCCSegueKeys.modalToOrderStepNavi, sender: nil)
    }
    
    @IBAction func didTouchMyInfo(sender : UIButton) {
        self.performSegue(withIdentifier: MCCSegueKeys.modalToJoinDetail, sender: nil)
    }
    
    
    
    func JoinVCDidCompleted() {
        self.refreshControl.beginRefreshing()
        self.refresh(refreshControl!)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func applicationDidBecomeActive(notification: NSNotification) {
        self.refresh(refreshControl!)
        
    }
    @objc func refresh(_ sender: UIRefreshControl) {
        self.dataSource.removeAll()
        self.tableView.reloadData()
        self.requestMyTransactionCredit()
    }
    func requestMyTransactionCredit() {
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
            
            if self.refreshControl.isRefreshing {
                self.dataSource.removeAll()
                self.refreshControl.endRefreshing()
            }
            
            for r in (resultArray as? [Any])! {
                let transaction = Transaction.init(json: r as! Dictionary<String, Any>)
                self.dataSource.append(transaction)
                print(transaction)
            }
            if self.dataSource.isNotEmpty {
                self.dataSource.sort(by: { $0.dateObject().compare($1.dateObject()) == .orderedDescending})
            }
            self.updateTopTitleInfo();
            HUD.hide(afterDelay: 0.1, completion: { (completed) in
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            })
        }) { (error) in
            self.updateTopTitleInfo();
            HUD.hide(afterDelay: 0.1, completion: { (completed) in
                print(error)
            })
        }
    }
    func showAlert(alertActionBlock : alertAction?) {
        
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
                self.showAlert(alertActionBlock: alertActionBlock)
                return
            }
            
            if tf1.text != tf2.text {
                self.showAlert(alertActionBlock: alertActionBlock)
                return;
            }
            UserDefaults.standard.set(tf1.text, forKey: MCCDefault.kUserLocalPassword)
            alertActionBlock!()
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
    @IBAction func didTouchCloseAction() {
        self.navigationController?.dismiss(animated: true, completion: {
//            DataCreate.Shared.createCreditModel.clearAll()
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        refreshControl?.tintColor = UIColor.init(red: 255/255, green: 187/255, blue: 66/255, alpha: 1)
        self.tableView!.addSubview(refreshControl)
        
//        self.requestMyTransactionCredit()
        let leftBarButton = UIBarButtonItem(image: UIImage(named: "img-close"), style: UIBarButtonItemStyle.done, target: self, action: #selector(didTouchCloseAction))
        //        let leftBarButton = UIBarButtonItem(title: "╳", style: UIBarButtonItemStyle.done, target: self, action: #selector(didTouchCloseAction))
        leftBarButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        if self.credit != nil {
            self.creditTitle1Label.text = self.credit.mainTitle()
            self.creditTitle2Label.text = self.credit.dataType(typeString: self.credit.needdatatype)
            self.creditTitle3Label.attributedText = self.credit.attributedString()
        }

        self.updateTopTitleInfo()
//        self.requestMyTransactionCredit()
        
    }
    func updateTopTitleInfo() {
        
        let defaultAttributes: [NSAttributedStringKey : Any] = [
            .foregroundColor : UIColor.darkGray,
            .font : UIFont.systemFont(ofSize: 16.0)
        ]
        let blueAttributes: [NSAttributedStringKey : Any] = [
            .foregroundColor : UIColor.init(red: 21/255, green: 35/255, blue: 189/255, alpha: 1),
            .font : UIFont.boldSystemFont(ofSize: 16.0)
        ]
        
        let mutableAttributeString = NSMutableAttributedString(string: "MCC 에코시스템에서\n", attributes: defaultAttributes)
        mutableAttributeString.append(NSAttributedString(string: "총 \(self.dataSource.count)명", attributes: blueAttributes))
        mutableAttributeString.append(NSAttributedString(string: "의 대상자를 찾았습니다.", attributes: defaultAttributes))
        self.topTitleLabel.attributedText = mutableAttributeString
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 21/255, green: 35/255, blue: 189/255, alpha: 1)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if MCCSegueKeys.showReportVC == segue.identifier {
            let reportVc = segue.destination as! ReportVC
            reportVc.transaction = sender as! Transaction
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
    
}

