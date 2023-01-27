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

struct Credit : Decodable {
    let creditid : String
    let gender : Int
    let livelocation : Int
    let maxage : Int
    let minage : Int
    let needdatatype : String
    let owneraddress : String
    let ownername : String
    let creditdate : String
    
    var datatype : String?
    var dateString : String?
    var startDateString : String?
    
    init(json : Dictionary<String,Any>) {
        self.gender = json["gender"] as! Int
        self.maxage = json["maxage"] as! Int
        self.minage = json["minage"] as! Int
        self.needdatatype = (json["needdatatype"] as? String)!
        self.owneraddress = (json["owneraddress"] as? String)!
        self.creditid = (json["creditid"] as? String)!
        self.livelocation = json["livelocation"] as! Int
        self.ownername = (json["ownername"] as? String)!
        self.creditdate = (json["creditdate"] as? String)!
    }
    
    func mainTitle()->String{
        var string = ""
        string.append(self.gender == 0 ? "남성" : "여성")
        string.append(",")
        //            string.append("\(ageRang(index: self.minage))~\(ageRang(index: self.maxage))대")
        string.append("\(ageRang(index: self.maxage))대")
        string.append(",")
        string.append(self.live(index: self.livelocation))
        string.append(" 거주자")
        return string
    }
    func live(index : Int)->String{
        switch index {
        case 0:
            return "서울"
        case 1:
            return "인천"
        case 2:
            return "경기도"
        case 3:
            return "그외지역"
        default:
            return "서울(!)"
        }
    }
    func ageRang(index : Int)->String{
        switch index {
        case 0:
            return "20"
        case 1:
            return "30"
        case 2:
            return "40"
        case 3:
            return "50"
        case 4:
            return "60"
        default:
            return "서울(!)"
        }
    }
    
    mutating func dataType(typeString : String)-> String?{
        if self.datatype == nil {
            do{
                let json =  try JSONSerialization.jsonObject(with: typeString.data(using: .utf8)!, options: .allowFragments)
                if let jsonArray =  json as?  [Int] {
                    self.datatype = String()
                    var stringArray = [String]()
                    for r in jsonArray as [Int] {
                        stringArray.append(SCRData.init(type: SCRData.DATA(rawValue: r)!).string())
                    }
                    self.datatype = stringArray.joined(separator: ",")
                }
            }catch {
                self.datatype = ""
            }
        }
        return self.datatype
    }
    
    mutating func dateStr()-> String?{
        if self.dateString == nil {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
            let date:Date = dateFormatter.date(from: self.creditdate)!
            
            let convertDateFormatter = DateFormatter();
            convertDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss a"
            convertDateFormatter.timeZone = TimeZone(abbreviation: "KST")
            
            let startDate : Date = convertDateFormatter.date(from: convertDateFormatter.string(from: date))!;
            let dateResult = startDate.addingDays(30)
            self.dateString = convertDateFormatter.string(from: dateResult!)
        }
        return self.dateString
    }
    
    mutating func startDateStr()-> String?{
        if self.startDateString == nil {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
            let date:Date = dateFormatter.date(from: self.creditdate)!
            
            let convertDateFormatter = DateFormatter();
            convertDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss a"
            convertDateFormatter.timeZone = TimeZone(abbreviation: "KST")
            
            self.startDateString = convertDateFormatter.string(from: date);
        }
        return self.startDateString
    }
    
    
    mutating func attributedString()-> NSAttributedString?{
        let defaultAttributes: [NSAttributedStringKey : Any] = [
            .foregroundColor : UIColor.darkGray,
            .font : UIFont.systemFont(ofSize: 16.0)
        ]
        let redAttributes: [NSAttributedStringKey : Any] = [
            .foregroundColor : UIColor.init(red: 235/255, green: 64/255, blue: 77/255, alpha: 1),
            .font : UIFont.systemFont(ofSize: 16.0)
        ]
        
        let mutableAttributeString = NSMutableAttributedString(string: "요청일 : \(self.startDateStr()! as String) /\n", attributes: defaultAttributes)
        mutableAttributeString.append(NSAttributedString(string: "만료일 : \(self.dateStr()! as String)", attributes: redAttributes))
        return mutableAttributeString
    }
    
    func date()-> Date {
        
        return Date(parse: self.creditdate, format: "YYYY-MM-dd", locale: "ko_KR")!
    }
    
    
    
    func subTitle()->String{
        return self.owneraddress
    }
}

extension Notification.Name {
    static let reloadFiles = Notification.Name("reloadFiles")
}

class MainV2VC: UIViewController, UITableViewDelegate, UITableViewDataSource, JoinVCVCDelegate{
    
    var refreshControl : UIRefreshControl!
   
    var dataSource = [Credit]()
    var transactionDataSource = [Transaction]()
    
    var isNeedRefresh = false
    
    
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var addCreditBtn : UIButton!
    @IBOutlet weak var reportBtn : MCCButton!
    @IBOutlet weak var topTitleLabel : UILabel!
    
    
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
        var creditModel = self.dataSource[indexPath.row]
        
        let isCompany = UserDefaults.standard.bool(forKey: MCCDefault.kUserIsCompany)
        if isCompany {
            cell.mainTitleLabel.text = creditModel.mainTitle()
            cell.subTitleLabel.text = creditModel.dataType(typeString: creditModel.needdatatype)
            cell.subTitleLabel.textColor = UIColor.init(red: 0/255, green: 150/255, blue: 255/255, alpha: 1)
            cell.dateLabel.attributedText = creditModel.attributedString()
        } else {
            cell.mainTitleLabel.text = creditModel.ownername
            cell.subTitleLabel.text = creditModel.dataType(typeString: creditModel.needdatatype)
            cell.subTitleLabel.textColor = UIColor.init(red: 184/255, green: 41/255, blue: 54/255, alpha: 1)
            cell.dateLabel.text = creditModel.creditdate
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let isCompany = UserDefaults.standard.bool(forKey: MCCDefault.kUserIsCompany)
        if isCompany == false {
            let creditModel = self.dataSource[indexPath.row]
            var creditList : [SCRData] = []
            do{
                let json =  try JSONSerialization.jsonObject(with: (creditModel.needdatatype.data(using: .utf8)!), options: .allowFragments)
                if let jsonArray =  json as?  [Int] {
                    for r in jsonArray as [Int] {
                        creditList.append(SCRData(type: SCRData.DATA(rawValue: r)!))
                    }
                }
            } catch {}
            self.performSegue(withIdentifier: MCCSegueKeys.modalToCreditDetailNavi, sender: [creditList,creditModel])
        } else {
            self.transactionDataSource.removeAll()
            self.isNeedRefresh = true
            let creditModel : Credit = self.dataSource[indexPath.row]
            self.requestMyTransactionCredit(success: {
                self.performSegue(withIdentifier: MCCSegueKeys.modalToReportDetailVC, sender: creditModel)
            }, credit: creditModel)
        }
    }
    
    @IBAction func didTouchAddCreditInfo(sender : UIButton!) {
        self.isNeedRefresh = true
        self.performSegue(withIdentifier: MCCSegueKeys.modalToOrderStepNavi, sender: nil)
    }
    @IBAction func didTouchReportAction(sender : UIButton) {
        self.isNeedRefresh = true
        self.performSegue(withIdentifier: MCCSegueKeys.modalToReportListVC, sender: self.transactionDataSource)
    }
    
    @IBAction func didTouchMyInfo(sender : UIButton) {
        self.performSegue(withIdentifier: MCCSegueKeys.modalToJoinDetail, sender: nil)
    }
    
    func JoinVCDidCompleted() {
        self.refreshControl.beginRefreshing()
        self.refresh(refreshControl!)
        
        let isCompany = UserDefaults.standard.bool(forKey: MCCDefault.kUserIsCompany)
        if isCompany {
            self.topTitleLabel.text = "요청한 데이터 리스트"
            self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 21/255, green: 35/255, blue: 189/255, alpha: 1)
            let rightBarButton = UIBarButtonItem(image: UIImage(named: "img-add"), style: UIBarButtonItemStyle.done, target: self, action: #selector(didTouchAddCreditInfo(sender:)))
            rightBarButton.tintColor = UIColor.white
            self.navigationItem.rightBarButtonItem = rightBarButton
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func applicationDidBecomeActive(notification: NSNotification) {
        self.refresh(refreshControl!)
        
    }
    @objc func refresh(_ sender: UIRefreshControl) {
         let isCompany = UserDefaults.standard.bool(forKey: MCCDefault.kUserIsCompany)
        self.dataSource.removeAll()
        self.tableView.reloadData()
        if isCompany == true {
            self.requestMyCreditList()
        }
        else {
            self.requestMyCreditListDetail()
        }
    }
    func requestMyCreditListDetail() {
        
        
//        let userAddress = UserDefaults.standard.string(forKey: MCCDefault.kWalletAddress)
        let age = UserDefaults.standard.object(forKey: MCCDefault.kUserAge)
        if age == nil  {
            UserDefaults.standard.set(35, forKey: MCCDefault.kUserAge)
            return;
        }
        let gender = UserDefaults.standard.object(forKey: MCCDefault.kUserGender)
        if gender == nil  {
            UserDefaults.standard.set(0, forKey: MCCDefault.kUserGender)
            return;
        }
        let location = UserDefaults.standard.object(forKey: MCCDefault.kUserLiveLocation)
        if location == nil  {
            UserDefaults.standard.set(0, forKey: MCCDefault.kUserLiveLocation)
            return;
        }
        HUD.show(.labeledRotatingImage(image: UIImage(named: "mcc-loading"), title: nil, subtitle: nil))
        /*
         case 0:
         return "20"
         case 1:
         return "30"
         case 2:
         return "40"
         case 3:
         return "50"
         case 4:
         return "60"
         default:
 */
        var rangeAge = 0
        let tAge = age as! Int
        if tAge >= 20 &&  tAge < 30 {
            rangeAge = 0
        } else if tAge >= 30 &&  tAge < 40 {
            rangeAge = 1
        } else if tAge >= 40 &&  tAge < 50 {
            rangeAge = 2
        } else if tAge >= 50 &&  tAge < 60 {
            rangeAge = 3
        } else if tAge  >= 60 &&  tAge < 70 {
            rangeAge = 4
        }
        
        var parameter : [String:String] = [:]
        parameter.append("credit", forKey: "ccId")
        parameter.append("queryCreditMyStyleJobList", forKey: "ccFnc")
        parameter.append(NSNumber(value: gender as! Int).stringValue, forKey: "param1")
        parameter.append(NSNumber(value: rangeAge).stringValue, forKey: "param2")
        parameter.append(NSNumber(value: location as! Int).stringValue, forKey: "param3")
        
        MCCRequest.Instance.requestQuery(parameter: parameter, success: { (resultArray) in
            //            print(resultArray)
            if self.refreshControl.isRefreshing {
                self.dataSource.removeAll()
                self.refreshControl.endRefreshing()
            }
            
            for r in (resultArray as? [Any])! {
                let credit = Credit.init(json: r as! Dictionary<String, Any>)
                self.dataSource.append(credit)
            }
            
            self.dataSource.sort(by: { $0.date().compare($1.date()) == .orderedDescending})
            
            HUD.hide(afterDelay: 0.1, completion: { (completed) in
                self.tableView.reloadData()
            })
            
        }) { (error) in
            HUD.hide(afterDelay: 0.1, completion: { (completed) in
                print(error)
            })
        }
    }
    func requestMyCreditList() {
        HUD.show(.labeledRotatingImage(image: UIImage(named: "mcc-loading"), title: nil, subtitle: nil))
        
        let userAddress = UserDefaults.standard.string(forKey: MCCDefault.kWalletAddress)
        
        var parameter : [String:String] = [:]
        parameter.append("credit", forKey: "ccId")
        parameter.append("queryCreditJobList", forKey: "ccFnc")
        
        MCCRequest.Instance.requestQuery(parameter: parameter, success: { (resultArray) in
            //            print(resultArray)
            if self.refreshControl.isRefreshing {
                self.dataSource.removeAll()
                self.refreshControl.endRefreshing()
            }
            let isCompany = UserDefaults.standard.bool(forKey: MCCDefault.kUserIsCompany)
            
            
//            var ready = convertedArray.sorted(by: { $0.compare($1) == .orderedDescending })
            
            for r in (resultArray as? [Any])! {
                let credit = Credit.init(json: r as! Dictionary<String, Any>)
                if credit.owneraddress == userAddress {
                    self.dataSource.append(credit)
                }
                else if isCompany == false {
                    self.dataSource.append(credit)
                }
                print(credit)
            }
            
            self.dataSource.sort(by: { $0.date().compare($1.date()) == .orderedDescending})
            
            HUD.hide(afterDelay: 0.1, completion: { (completed) in
                self.tableView.reloadData()
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                    self.requestMyTransactionCredit()
//                }
            })
            
        }) { (error) in
            HUD.hide(afterDelay: 0.1, completion: { (completed) in
                print(error)
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
            self.transactionDataSource.removeAll()
            for r in (resultArray as? [Any])! {
                let transaction = Transaction.init(json: r as! Dictionary<String, Any>)
//                if transaction.datakey.count < 50 {
                    self.transactionDataSource.append(transaction)
//                }
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
                    self.showAlert(message: "해당 데이터가 없습니다.", actionMesage: "확인", actionStyle: .default, actionBlock: nil)
                })
            }

        }) { (error) in
            if self.transactionDataSource.isEmpty{
                HUD.hide(afterDelay: 0.1, completion: { (completed) in
                    self.showAlert(message: "해당 요청건에 응답한 데이터가 없습니다.", actionMesage: "확인", actionStyle: .default, actionBlock: nil)
                })
            }
            else {
                HUD.hide(afterDelay: 0.1, completion: { (completed) in
                    print(error)
                })
            }
        }
    }
    func showAlert(alertActionBlock : alertAction?) {
        
        var message = ""
        
        let isCompany = UserDefaults.standard.bool(forKey: MCCDefault.kUserIsCompany)
        
        message = isCompany == true ? "데이터 의뢰신청전에 확인할 비밀번호를 입력하세요." : "데이터 의뢰 동의에 확이할 비밀번호를 입력하세요"
        
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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if targetEnvironment(simulator)
        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path {
            print("Documents Directory: \(documentsPath)")
        }
        #endif
        

        let date:Date = Date()
        //        let dateFormatter = DateFormatter()
        //        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
        //        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        //        let dateString = dateFormatter.string(from: date)
        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
//        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
//        //        let date:Date = dateFormatter.date(from: dateString)!
//
//        let dateString = dateFormatter.string(from: date)
//        print(dateFormatter.string(from: date))
//        print(dateFormatter.string(from: date))
//
////        let dateString:String = "2018-10-25T08:04:32+0000"//"2018-10-25T07:59:00+0000"
////
////        let dateFormatter = DateFormatter()
////        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
////        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
////        let date:Date = dateFormatter.date(from: dateString)!
////
////        print(dateFormatter.string(from: date))
////        print(dateFormatter.string(from: NSDate() as Date))
////
//        let convertDateFormatter = DateFormatter();
//        convertDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss a"
//        convertDateFormatter.timeZone = TimeZone(abbreviation: "KST")
//
//        print(convertDateFormatter.string(from: date))
//        print(convertDateFormatter.string(from: date))
        
//        let frame = self.reportBtn.titleLabel?.textRect(forBounds: self.reportBtn.bounds, limitedToNumberOfLines: 1)
//
//        self.reportBtn.badgeEdgeInsets = UIEdgeInsetsMake(10, -(self.reportBtn.frame.size.width/2)+((frame?.width)!/2), 0, 0)
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        refreshControl?.tintColor = UIColor.init(red: 255/255, green: 187/255, blue: 66/255, alpha: 1)
        self.tableView!.addSubview(refreshControl)
        
//        let isCompany = UserDefaults.standard.bool(forKey: MCCDefault.kUserIsCompany)
        
        
        guard UserDefaults.standard.string(forKey: MCCDefault.kWalletAddress) != nil else {
            HUD.hide()
            self.performSegue(withIdentifier: MCCSegueKeys.modalToJoinNavi, sender: nil)
            return
        }
        
        
        let address : String = UserDefaults.standard.string(forKey: MCCDefault.kWalletAddress)!
        if !address.isEmpty {
            print("MCCDefault.kWalletAddress - \(address)")
        }
        
        let password : String = UserDefaults.standard.string(forKey: MCCDefault.kWalletPassword)!
        if !password.isEmpty {
            print("MCCDefault.kWalletPassword - \(password)")
        }
        
//        let localpassword = UserDefaults.standard.string(forKey: MCCDefault.kUserLocalPassword)
//        if localpassword == nil {
//            print("MCCDefault.kUserLocalPassword - \(String(describing: localpassword))")
//            self.showAlert {
//                self.requestMyCreditList()
//            }
//            return;
//        }
        let isCompany = UserDefaults.standard.bool(forKey: MCCDefault.kUserIsCompany)
        if isCompany == true {
            self.requestMyCreditList()
        }
        else {
            self.requestMyCreditListDetail()
        }
        
        
//        self.showAlert(message: "test", actionMesage: "확인", actionStyle: .default) {
//            self.testFincRequest()
//        }
//        var json = [String:Any]()
//        json["creditid"] = "2018-09-20"
//        json["gender"] = 0
//        json["maxage"] = 0
//        json["minage"] = 0
//        json["needdatatype"] = "[1,2,3,4]"
//        json["owneraddress"] = "123123"
//        json["livelocation"] = 0
//        json["creditdate"] = "2018-09-20"
//        json["ownername"] = "zzz"
//
//        var credit = Credit.init(json: json)
//        print("date to start : " + credit.creditdate)
//
//        print("date to max : " + credit.dateStr()!)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let isCompany = UserDefaults.standard.bool(forKey: MCCDefault.kUserIsCompany)
        if isCompany {
            self.topTitleLabel.text = "요청한 데이터 리스트"
//            self.addCreditBtn.isHidden = false
//            self.reportBtn.isHidden = false
            self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 21/255, green: 35/255, blue: 189/255, alpha: 1)
//            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 45, 0)
//            self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 45, 0)
            
            
            if self.navigationItem.rightBarButtonItem == nil {
                let rightBarButton = UIBarButtonItem(image: UIImage(named: "img-add"), style: UIBarButtonItemStyle.done, target: self, action: #selector(didTouchAddCreditInfo(sender:)))
                rightBarButton.tintColor = UIColor.white
                self.navigationItem.rightBarButtonItem = rightBarButton
            }
        }
        else{
            self.topTitleLabel.text = "정보 요청 리스트"
//            self.addCreditBtn.isHidden = true
//            self.reportBtn.isHidden = true
            self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 235/255, green: 64/255, blue: 77/255, alpha: 1)
//            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
//            self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0)
            
            if self.navigationItem.rightBarButtonItem == nil {
                let rightBarButton = UIBarButtonItem(image: UIImage(named: "img-myinfo"), style: UIBarButtonItemStyle.done, target: self, action: #selector(didTouchMyInfo))
                rightBarButton.tintColor = UIColor.white
                self.navigationItem.rightBarButtonItem = rightBarButton
            }
        }
//        self.reportBtn?.backgroundColor = isCompany == true ?  UIColor.init(red: 21/255, green: 35/255, blue: 189/255, alpha: 1) : UIColor.init(red: 235/255, green: 64/255, blue: 77/255, alpha: 1)
//        self.addCreditBtn?.backgroundColor = isCompany == true ?  UIColor.init(red: 21/255, green: 35/255, blue: 189/255, alpha: 1) : UIColor.init(red: 235/255, green: 64/255, blue: 77/255, alpha: 1)
        if self.isNeedRefresh {
            self.isNeedRefresh = false
            self.refreshControl.beginRefreshing()
            self.refresh(self.refreshControl)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if MCCSegueKeys.modalToJoinNavi ==  segue.identifier {
            let navigationController = segue.destination as! UINavigationController
            let joinVC = navigationController.topViewController as! JoinVC
            joinVC.delegate = self as JoinVCVCDelegate;
        } else if MCCSegueKeys.modalToCreditDetailNavi == segue.identifier {
            let navigationController = segue.destination as! UINavigationController
            let detailVC = navigationController.topViewController as! CreditDetailVC
            let argument = sender as! [Any]
            detailVC.dataSource = argument.first as! [SCRData]
            detailVC.creditData = argument.last as? Credit
        } else if MCCSegueKeys.modalToReportDetailVC == segue.identifier {
            let navigationController = segue.destination as! UINavigationController
            let reportListVC = navigationController.topViewController as! ReportDetailVC
            reportListVC.credit = sender as! Credit
            if self.transactionDataSource.isNotEmpty {
                reportListVC.dataSource = self.transactionDataSource
            }
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
    func testFincRequest() {
        testFincRequest2()
//        self.requestFinc(successAction: nil, failedAction: nil)
    }
    
//    func requestFinc(successAction : successAction? , failedAction : faildAction?) {
//        //        HUD.show(.labeledRotatingImage(image: UIImage(named: "mcc-loading"), title: nil, subtitle: nil))
//
//
//        var listparameter = [String:Any]()
//
//        var parameter : [String:String] = [:]
//
//        var errorCode : String
//        var errorMessage : String
//        errorCode = "000"
//        errorMessage = "정상처리"
//
//
//        var drmDataParameter = [String:String]()
//
//        parameter.append("NHIS_JAGEOK", forKey: "docId")
//        parameter.append(issue2(), forKey: "data")
//        parameter.append("0", forKey: "line")
//
//        print("omniDocParam.issue[\(issue2())]")
//
//        listparameter.append([parameter], forKey: "list")
//        listparameter.append(errorCode, forKey: "errCode")
//        listparameter.append(errorMessage, forKey: "errMsg")
//        listparameter.append("momnidoc", forKey: "txCode")
//        listparameter.append("1", forKey: "list_cnt")
//
//        let jsonData = try? JSONSerialization.data(withJSONObject: listparameter, options: [])
//        let jsonString = String(data: jsonData!, encoding: .utf8)
//
//        drmDataParameter.append((jsonString)!, forKey: "drmData")
//
//
//
//        MCCRequest.Instance.requestFinc(parameters:drmDataParameter, success: { (json) in
//            print("--------------result---------------")
//            print(json as Any)
//            print("--------------end---------------")
//        }) { (error) in
//            print("--------------result-error--------------")
//            print(error)
//            print("--------------end---------------")
//        }
//    }
    
    func issue소득() -> String {
        return "<?xml version='1.0' encoding='utf-8'?><root><prnNb/><mobAplnYn/><erinYn/><cvaId/><incRqsuSffYn/><incRqsuSffYn2/><cvaDcumSbmsOrgnClCd/><incAmtCerDVOList><rows><pblcPnsnIncDdcAmt/><intgMateBrkdSn>8</intgMateBrkdSn><sbizIncDdcAmt/><pnsnIncAmt/><attrYr>2017</attrYr><lvyRperEnglTnmNm><![CDATA[MoneyTag Inc.]]></lvyRperEnglTnmNm><lvyRperCnt>1</lvyRperCnt><hthrMateYn><![CDATA[Y]]></hthrMateYn><bsYeYn/><inctxDcsTxamt>0</inctxDcsTxamt><pnsnAccIncTxamtDdcAmt/><txtnTrgtIncAmt>27803525</txtnTrgtIncAmt><txtnTrgtSnwAmt>38886500</txtnTrgtSnwAmt><lvyRperTnmNm><![CDATA[주식회사 머니택]]></lvyRperTnmNm><pnsnYeYn/><lvyRperNo>7838700178</lvyRperNo><mateKndCd><![CDATA[A0051]]></mateKndCd><statusValue></statusValue><lvyRperTin>100000000016400373</lvyRperTin></rows></incAmtCerDVOList><cerpBscInfrDVO><jntRprsEnglTxprNm/><cvaChrgDprtEnglNm><![CDATA[Taxpayer Service Center]]></cvaChrgDprtEnglNm><rcatNo>501145872209</rcatNo><cvaChrgOgzEnglNm><![CDATA[GIHEUNG]]><cvaChrgOgzEnglNm><cvarHofcRoadNmAdr/><cvaId>201809510000001149188695</cvaId><rptPkgPth/><cvarBldSnoAdr>0</cvarBldSnoAdr><cvarEnglBanAdr/><cvarEnglSubItmNm/><cvaChrgDprtNm><![CDATA[민원봉사실]]></cvaChrgDprtNm><cvarTin>000000153602519114</cvarTin><cvaChrgOgzNm><![CDATA[기흥]]></cvaChrgOgzNm><rcatDtm>20180919180421</rcatDtm><cvarFaxno/><aplcResno><![CDATA[830315-*******]]></aplcResno><cvarEnglBldDnadr/><rcatOptrTxhfOgzCd>236</rcatOptrTxhfOgzCd><cvarRprsResno/><cvaDcumGranMthdNm><![CDATA[인터넷출력]]></cvaDcumGranMthdNm><cvarHmpgAdrUrl/><cvarFnm><![CDATA[정인규]]></cvarFnm><cvarEnglRdstNm/><adrOpYn><![CDATA[Y]]></adrOpYn><cvarEnglRprsLdAdr/><englCvaAplnYn><![CDATA[N]]></englCvaAplnYn><cerCvaIsnNo><![CDATA[2099-467-1664-274]]></cerCvaIsnNo><cvarTxprClsfCd>01</cvarTxprClsfCd><cvarBrncRoadNmAdr/><rptFleNm/><txnrmEndYm>201712</txnrmEndYm><cvaDcumGranDt/><jntBmanResnoOpYn><![CDATA[N]]></jntBmanResnoOpYn><cvaChrgTelno><![CDATA[031-8007-1221]]></cvaChrgTelno><cvaDcumIsnStatCd/><englMpbBldBlckAdr/><cvaChrgDutsCd><![CDATA[AS00]]></cvaChrgDutsCd><cvarCvaAgnRltCd>01</cvarCvaAgnRltCd><cvarHofcYn/><cvarEml><![CDATA[******************]]></cvarEml><cvarEnglHofcLdAdr/><cdlGranNo/><cvarRprsMpno/><pbTin/><cfbDt/><mdlTxprYn><![CDATA[N]]></mdlTxprYn><cvaDcumGranRsn/><cvaKndNm><![CDATA[소득금액증명(근로소득)]]></cvaKndNm><cvarEnglBcNm/><cvarEnglBldBlckAdr/><cvarMpbSn>0</cvarMpbSn><txaaEnglCntn/><cerpIsnActlQty/><cvaChrgTxhfOgzCd>236</cvaChrgTxhfOgzCd><aplcCvaAgnRltNm><![CDATA[본인]]></aplcCvaAgnRltNm><cvarEnglHofcRoadNmAdr/><txnrmStrtYm>201701</txnrmStrtYm><cvarBunjAdr>1139</cvarBunjAdr><rctCerCvaIsnSn/><cvarEnglBldHoAdr/><cerpIsnRqsQty>1</cerpIsnRqsQty><cvaDcumUseUsgCd>04</cvaDcumUseUsgCd><plsbNm/><cvarRprsRoadNmAdr/><aplcTnm></aplcTnm><cvarEnglBrncRoadNmAdr/><sfbTerm/><cvarItmNm/><cvarEnglSggNm><![CDATA[Giheung-gu, Yongin-si]]></cvarEnglSggNm><cvarEnglTnm/><cerIsnMateClCd/><cvarBmanClCd/><mdlTxprEnglCntn/><cvaDcumSbmsOrgnClCd>01</cvaDcumSbmsOrgnClCd><cvarBrncLdAdr/><cvarEnglSubBcNm/><cvaChrgEnglFnm><![CDATA[YIM HAN GEEL]]></cvaChrgEnglFnm><cvaDcumIsnStatNm/><cvarLdAdr><![CDATA[경기도 용인시 기흥구 중동 1139 신동백서해그랑블2차아파트 207동 1605호]]></cvarLdAdr><rcatOptrDutsCd><![CDATA[CA06]]></rcatOptrDutsCd><cvarRprsHmTelno/><jntRprsTxprNm/><ovrsMvnPrmsDt/><jntRprsTxprNo/><cvarTelno><![CDATA[010-2905-****]]></cvarTelno><tin/><cvarCvaAgnRltNm><![CDATA[본인]]></cvarCvaAgnRltNm><cvarBldPmnoAdr>31</cvarBldPmnoAdr><sfbEndDt/><statusValue></statusValue><mdlTxprCntn/><sfbStrtDt/><cvarCprno/><cvarHoAdr>0</cvarHoAdr><cvarSubItmNm/><cvaCerIsnDcnt/><cvarMpno><![CDATA[010-2905-****]]></cvarMpno><cvarEnglYmdgNm><![CDATA[Jung-dong]]></cvarEnglYmdgNm><cvarRoadNmAdr><![CDATA[경기도 용인시 기흥구 언동로217번길 31]]></cvarRoadNmAdr><cvarTnm/><cerpResnRqsQty/><cvaChrgOgzFrmyNm><![CDATA[기흥세무서]]></cvaChrgOgzFrmyNm><aplcEnglFnm/><englMpbBldDnadr/><cvarSubBcNm/><cvarEnglFnmJnt/><cvaChrgFnm><![CDATA[임한길]]></cvaChrgFnm><cvaTxprDscmDt>19830315</cvaTxprDscmDt><amtOpYn><![CDATA[Y]]></amtOpYn><cvarEnglRprsRoadNmAdr/><jntBmanCnt>0</jntBmanCnt><cerCvaIsnSn>1</cerCvaIsnSn><cvaDcumGranMthdCd>06</cvaDcumGranMthdCd><ntplInfrPtusAgrClCd><![CDATA[ZZ]]></ntplInfrPtusAgrClCd><lstYn/><rctCerCvaIsnNo/><ovrsMvnPrmsNo/><cvaDcumUseUsgNm><![CDATA[대출용]]></cvaDcumUseUsgNm><cvarTxprDscmNoClCd>111</cvarTxprDscmNoClCd><txprDscmDt/><cvarFnmJnt><![CDATA[정인규]]></cvarFnmJnt><cvarEnglItmNm/><rcatOptrMemNo><![CDATA[A043767]]></rcatOptrMemNo><aplcTin>000000153602519114</aplcTin><cvarRprsLdAdr/><cvarBsno/><resnoOpYn><![CDATA[N]]></resnoOpYn><mpbSn/><cvarResno><![CDATA[830315-*******]]></cvarResno><aplcFnm><![CDATA[정인규]]></aplcFnm><cvarEnglBrncLdAdr/><englMpbTnmNm/><cvarBcNm/><txprNm/><cvarEnglLdAdr/><cvarYmdgClCd>02</cvarYmdgClCd><rcatMthdCd>06</rcatMthdCd><txaaCntn/><cvarEnglTongAdr/><cvaDcumSbmsOrgnClNm><![CDATA[금융기관]]></cvaDcumSbmsOrgnClNm><cvarHofcLdAdr/><cvarEnglRoadNm><![CDATA[Eondong-ro 217beon-gil]]></cvarEnglRoadNm><cvarEnglSidoNm><![CDATA[Gyeonggi-do]]></cvarEnglSidoNm><cvarEnglFnm/><cvaKndCd><![CDATA[B1013]]></cvaKndCd><mpbRprsTin/><aplcCvaAgnRltCd>01</aplcCvaAgnRltCd><cvarCrpNm/><cvarEnglRoadNmAdr/><txprDscmNoEncCntn/><englMpbBldHoAdr/></cerpBscInfrDVO><cvaDcumIsnStatRsn/><txnrmStrtYm/><ieTin/><mdlTxprClCd/><adrOpYn/><englCvaAplnYn/><mdlTxprMsg/><cerCvaIsnNo/><cvaDcumUseUsgCd/><txnrmEndYm/><bsPnsnYeYn/><bsYeYn/><incRqsuSffYnNd2/><cvaKndCd/><cvaDcumIsnStatCd/><mdlTxprEnglMsg/><pnsnYeYn/><agitxYn/><cvaAplnDtm/></root>"
    }
    
    func issue자격() ->String{
        //자격득실 확인서
        return "<?xml version='1.0' encoding='UTF-8' ?><root>    <dataset id='rd_jgeb400_r3'>            <record>            <ISSUE_NO>G2018092001381271</ISSUE_NO>            <SYSDATE>20180920</SYSDATE>            <OUT01>정인규</OUT01>            <OUT02>8303151******</OUT02>            <OUT03>직장가입자</OUT03>            <OUT04>주식회사 마이크레딧체인</OUT04>            <OUT05>20180409</OUT05>            <OUT06/>        </record>            <record>            <ISSUE_NO>G2018092001381271</ISSUE_NO>            <SYSDATE>20180920</SYSDATE>            <OUT01>정인규</OUT01>            <OUT02>8303151******</OUT02>            <OUT03>지역세대주</OUT03>            <OUT04/>            <OUT05>20180401</OUT05>            <OUT06>20180409</OUT06>        </record>            <record>            <ISSUE_NO>G2018092001381271</ISSUE_NO>            <SYSDATE>20180920</SYSDATE>            <OUT01>정인규</OUT01>            <OUT02>8303151******</OUT02>            <OUT03>직장가입자</OUT03>            <OUT04>(주)핑거</OUT04>            <OUT05>20180101</OUT05>            <OUT06>20180401</OUT06>        </record>            <record>            <ISSUE_NO>G2018092001381271</ISSUE_NO>            <SYSDATE>20180920</SYSDATE>            <OUT01>정인규</OUT01>            <OUT02>8303151******</OUT02>            <OUT03>직장가입자</OUT03>            <OUT04>(주)머니택</OUT04>            <OUT05>20170601</OUT05>            <OUT06>20180101</OUT06>        </record>            <record>            <ISSUE_NO>G2018092001381271</ISSUE_NO>            <SYSDATE>20180920</SYSDATE>            <OUT01>정인규</OUT01>            <OUT02>8303151******</OUT02>            <OUT03>직장가입자</OUT03>            <OUT04>(주)핑거</OUT04>            <OUT05>20160414</OUT05>            <OUT06>20170601</OUT06>        </record>            <record>            <ISSUE_NO>G2018092001381271</ISSUE_NO>            <SYSDATE>20180920</SYSDATE>            <OUT01>정인규</OUT01>            <OUT02>8303151******</OUT02>            <OUT03>지역세대주</OUT03>            <OUT04/>            <OUT05>20160401</OUT05>            <OUT06>20160414</OUT06>        </record>            <record>            <ISSUE_NO>G2018092001381271</ISSUE_NO>            <SYSDATE>20180920</SYSDATE>            <OUT01>정인규</OUT01>            <OUT02>8303151******</OUT02>            <OUT03>직장가입자</OUT03>            <OUT04>（주）베이비프렌즈</OUT04>            <OUT05>20150701</OUT05>            <OUT06>20160401</OUT06>        </record>            <record>            <ISSUE_NO>G2018092001381271</ISSUE_NO>            <SYSDATE>20180920</SYSDATE>            <OUT01>정인규</OUT01>            <OUT02>8303151******</OUT02>            <OUT03>직장가입자</OUT03>            <OUT04>주식회사솔트룩스</OUT04>            <OUT05>20120401</OUT05>            <OUT06>20150701</OUT06>        </record>            <record>            <ISSUE_NO>G2018092001381271</ISSUE_NO>            <SYSDATE>20180920</SYSDATE>            <OUT01>정인규</OUT01>            <OUT02>8303151******</OUT02>            <OUT03>지역세대주</OUT03>            <OUT04/>            <OUT05>20111112</OUT05>            <OUT06>20120401</OUT06>        </record>            <record>            <ISSUE_NO>G2018092001381271</ISSUE_NO>            <SYSDATE>20180920</SYSDATE>            <OUT01>정인규</OUT01>            <OUT02>8303151******</OUT02>            <OUT03>직장피부양자</OUT03>            <OUT04>송임석세무회계사무소</OUT04>            <OUT05>20111010</OUT05>            <OUT06>20111112</OUT06>        </record>            <record>            <ISSUE_NO>G2018092001381271</ISSUE_NO>            <SYSDATE>20180920</SYSDATE>            <OUT01>정인규</OUT01>            <OUT02>8303151******</OUT02>            <OUT03>지역세대주</OUT03>            <OUT04/>            <OUT05>20110623</OUT05>            <OUT06>20111010</OUT06>        </record>            <record>            <ISSUE_NO>G2018092001381271</ISSUE_NO>            <SYSDATE>20180920</SYSDATE>            <OUT01>정인규</OUT01>            <OUT02>8303151******</OUT02>            <OUT03>직장가입자</OUT03>            <OUT04>엠에쓰테크</OUT04>            <OUT05>20090914</OUT05>            <OUT06>20110623</OUT06>        </record>            <record>            <ISSUE_NO>G2018092001381271</ISSUE_NO>            <SYSDATE>20180920</SYSDATE>            <OUT01>정인규</OUT01>            <OUT02>8303151******</OUT02>            <OUT03>직장피부양자</OUT03>            <OUT04>제일산업</OUT04>            <OUT05>20090423</OUT05>            <OUT06>20090914</OUT06>        </record>            <record>            <ISSUE_NO>G2018092001381271</ISSUE_NO>            <SYSDATE>20180920</SYSDATE>            <OUT01>정인규</OUT01>            <OUT02>8303151******</OUT02>            <OUT03>직장가입자</OUT03>            <OUT04>엠에쓰테크</OUT04>            <OUT05>20051202</OUT05>            <OUT06>20090423</OUT06>        </record>            <record>            <ISSUE_NO>G2018092001381271</ISSUE_NO>            <SYSDATE>20180920</SYSDATE>            <OUT01>정인규</OUT01>            <OUT02>8303151******</OUT02>            <OUT03>직장피부양자</OUT03>            <OUT04>제일산업</OUT04>            <OUT05>20051101</OUT05>            <OUT06>20051202</OUT06>        </record>            <record>            <ISSUE_NO>G2018092001381271</ISSUE_NO>            <SYSDATE>20180920</SYSDATE>            <OUT01>정인규</OUT01>            <OUT02>8303151******</OUT02>            <OUT03>직장가입자</OUT03>            <OUT04>오리온씨엔아이(주)</OUT04>            <OUT05>20050718</OUT05>            <OUT06>20051101</OUT06>        </record>            <record>            <ISSUE_NO>G2018092001381271</ISSUE_NO>            <SYSDATE>20180920</SYSDATE>            <OUT01>정인규</OUT01>            <OUT02>8303151******</OUT02>            <OUT03>직장피부양자</OUT03>            <OUT04>제일산업</OUT04>            <OUT05>19991101</OUT05>            <OUT06>20050718</OUT06>        </record>            <record>            <ISSUE_NO>G2018092001381271</ISSUE_NO>            <SYSDATE>20180920</SYSDATE>            <OUT01>정인규</OUT01>            <OUT02>8303151******</OUT02>            <OUT03>지역세대원</OUT03>            <OUT04/>            <OUT05>19971101</OUT05>            <OUT06>19991101</OUT06>        </record>            <record>            <ISSUE_NO>G2018092001381271</ISSUE_NO>            <SYSDATE>20180920</SYSDATE>            <OUT01>정인규</OUT01>            <OUT02>8303151******</OUT02>            <OUT03>직장피부양자</OUT03>            <OUT04>정우엘라텍</OUT04>            <OUT05>19970503</OUT05>            <OUT06>19971101</OUT06>        </record>            <record>            <ISSUE_NO>G2018092001381271</ISSUE_NO>            <SYSDATE>20180920</SYSDATE>            <OUT01>정인규</OUT01>            <OUT02>8303151******</OUT02>            <OUT03>지역세대원</OUT03>            <OUT04/>            <OUT05>19930603</OUT05>            <OUT06>19970504</OUT06>        </record>    </dataset></root>"
    }
    func jsonString() -> String {
        return "{\"list\": [{\"data\": \"<?xml version='1.0' encoding='UTF-8' ?><root>    <dataset id='rd_jgeb400_r3'>            <record>            <ISSUE_NO>G2018092001381271</ISSUE_NO>            <SYSDATE>20180920</SYSDATE>            <OUT01>정인규</OUT01>            <OUT02>8303151******</OUT02>            <OUT03>직장가입자</OUT03>            <OUT04>주식회사 마이크레딧체인</OUT04>            <OUT05>20180409</OUT05>            <OUT06/>        </record>            <record>            <ISSUE_NO>G2018092001381271</ISSUE_NO>            <SYSDATE>20180920</SYSDATE>            <OUT01>정인규</OUT01>            <OUT02>8303151******</OUT02>            <OUT03>지역세대주</OUT03>            <OUT04/>            <OUT05>20180401</OUT05>            <OUT06>20180409</OUT06>        </record>            <record>            <ISSUE_NO>G2018092001381271</ISSUE_NO>            <SYSDATE>20180920</SYSDATE>            <OUT01>정인규</OUT01>            <OUT02>8303151******</OUT02>            <OUT03>직장가입자</OUT03>            <OUT04>(주)핑거</OUT04>            <OUT05>20180101</OUT05>            <OUT06>20180401</OUT06>        </record>            <record>            <ISSUE_NO>G2018092001381271</ISSUE_NO>            <SYSDATE>20180920</SYSDATE>            <OUT01>정인규</OUT01>            <OUT02>8303151******</OUT02>            <OUT03>직장가입자</OUT03>            <OUT04>(주)머니택</OUT04>            <OUT05>20170601</OUT05>            <OUT06>20180101</OUT06>        </record>            <record>            <ISSUE_NO>G2018092001381271</ISSUE_NO>            <SYSDATE>20180920</SYSDATE>            <OUT01>정인규</OUT01>            <OUT02>8303151******</OUT02>            <OUT03>직장가입자</OUT03>            <OUT04>(주)핑거</OUT04>            <OUT05>20160414</OUT05>            <OUT06>20170601</OUT06>        </record>            <record>            <ISSUE_NO>G2018092001381271</ISSUE_NO>            <SYSDATE>20180920</SYSDATE>            <OUT01>정인규</OUT01>            <OUT02>8303151******</OUT02>            <OUT03>지역세대주</OUT03>            <OUT04/>            <OUT05>20160401</OUT05>            <OUT06>20160414</OUT06>        </record>            <record>            <ISSUE_NO>G2018092001381271</ISSUE_NO>            <SYSDATE>20180920</SYSDATE>            <OUT01>정인규</OUT01>            <OUT02>8303151******</OUT02>            <OUT03>직장가입자</OUT03>            <OUT04>（주）베이비프렌즈</OUT04>            <OUT05>20150701</OUT05>            <OUT06>20160401</OUT06>        </record>            <record>            <ISSUE_NO>G2018092001381271</ISSUE_NO>            <SYSDATE>20180920</SYSDATE>            <OUT01>정인규</OUT01>            <OUT02>8303151******</OUT02>            <OUT03>직장가입자</OUT03>            <OUT04>주식회사솔트룩스</OUT04>            <OUT05>20120401</OUT05>            <OUT06>20150701</OUT06>        </record>            <record>            <ISSUE_NO>G2018092001381271</ISSUE_NO>            <SYSDATE>20180920</SYSDATE>            <OUT01>정인규</OUT01>            <OUT02>8303151******</OUT02>            <OUT03>지역세대주</OUT03>            <OUT04/>            <OUT05>20111112</OUT05>            <OUT06>20120401</OUT06>        </record>            <record>            <ISSUE_NO>G2018092001381271</ISSUE_NO>            <SYSDATE>20180920</SYSDATE>            <OUT01>정인규</OUT01>            <OUT02>8303151******</OUT02>            <OUT03>직장피부양자</OUT03>            <OUT04>송임석세무회계사무소</OUT04>            <OUT05>20111010</OUT05>            <OUT06>20111112</OUT06>        </record>            <record>            <ISSUE_NO>G2018092001381271</ISSUE_NO>            <SYSDATE>20180920</SYSDATE>            <OUT01>정인규</OUT01>            <OUT02>8303151******</OUT02>            <OUT03>지역세대주</OUT03>            <OUT04/>            <OUT05>20110623</OUT05>            <OUT06>20111010</OUT06>        </record>            <record>            <ISSUE_NO>G2018092001381271</ISSUE_NO>            <SYSDATE>20180920</SYSDATE>            <OUT01>정인규</OUT01>            <OUT02>8303151******</OUT02>            <OUT03>직장가입자</OUT03>            <OUT04>엠에쓰테크</OUT04>            <OUT05>20090914</OUT05>            <OUT06>20110623</OUT06>        </record>            <record>            <ISSUE_NO>G2018092001381271</ISSUE_NO>            <SYSDATE>20180920</SYSDATE>            <OUT01>정인규</OUT01>            <OUT02>8303151******</OUT02>            <OUT03>직장피부양자</OUT03>            <OUT04>제일산업</OUT04>            <OUT05>20090423</OUT05>            <OUT06>20090914</OUT06>        </record>            <record>            <ISSUE_NO>G2018092001381271</ISSUE_NO>            <SYSDATE>20180920</SYSDATE>            <OUT01>정인규</OUT01>            <OUT02>8303151******</OUT02>            <OUT03>직장가입자</OUT03>            <OUT04>엠에쓰테크</OUT04>            <OUT05>20051202</OUT05>            <OUT06>20090423</OUT06>        </record>            <record>            <ISSUE_NO>G2018092001381271</ISSUE_NO>            <SYSDATE>20180920</SYSDATE>            <OUT01>정인규</OUT01>            <OUT02>8303151******</OUT02>            <OUT03>직장피부양자</OUT03>            <OUT04>제일산업</OUT04>            <OUT05>20051101</OUT05>            <OUT06>20051202</OUT06>        </record>            <record>            <ISSUE_NO>G2018092001381271</ISSUE_NO>            <SYSDATE>20180920</SYSDATE>            <OUT01>정인규</OUT01>            <OUT02>8303151******</OUT02>            <OUT03>직장가입자</OUT03>            <OUT04>오리온씨엔아이(주)</OUT04>            <OUT05>20050718</OUT05>            <OUT06>20051101</OUT06>        </record>            <record>            <ISSUE_NO>G2018092001381271</ISSUE_NO>            <SYSDATE>20180920</SYSDATE>            <OUT01>정인규</OUT01>            <OUT02>8303151******</OUT02>            <OUT03>직장피부양자</OUT03>            <OUT04>제일산업</OUT04>            <OUT05>19991101</OUT05>            <OUT06>20050718</OUT06>        </record>            <record>            <ISSUE_NO>G2018092001381271</ISSUE_NO>            <SYSDATE>20180920</SYSDATE>            <OUT01>정인규</OUT01>            <OUT02>8303151******</OUT02>            <OUT03>지역세대원</OUT03>            <OUT04/>            <OUT05>19971101</OUT05>            <OUT06>19991101</OUT06>        </record>            <record>            <ISSUE_NO>G2018092001381271</ISSUE_NO>            <SYSDATE>20180920</SYSDATE>            <OUT01>정인규</OUT01>            <OUT02>8303151******</OUT02>            <OUT03>직장피부양자</OUT03>            <OUT04>정우엘라텍</OUT04>            <OUT05>19970503</OUT05>            <OUT06>19971101</OUT06>        </record>            <record>            <ISSUE_NO>G2018092001381271</ISSUE_NO>            <SYSDATE>20180920</SYSDATE>            <OUT01>정인규</OUT01>            <OUT02>8303151******</OUT02>            <OUT03>지역세대원</OUT03>            <OUT04/>            <OUT05>19930603</OUT05>            <OUT06>19970504</OUT06>        </record>    </dataset></root>\",\"doc\": \"NHIS_JAGEOK\",\"line\": \"1\"}],\"errCode\": \"000\",\"errMsg\": \"\",\"txCode\": \"momnidoc\",\"list_cnt\": \"1\"}"
    }
    func issue4대() -> String{
        return "<?xml version='1.0' encoding='utf-8'?><list><CdocAppl><dir>ASC</dir><start>0</start><limit>10</limit><pageNo>1</pageNo><log class=\"org.apache.commons.logging.impl.Log4JLogger\"><name>egovframework.ins4.pub.cdoc.cdoc.service.CdocAppl</name></log><rrnoPrtYn></rrnoPrtYn><issuNo>20180921488878</issuNo><issuDttm></issuDttm><issuLimitedYn></issuLimitedYn><issuYn></issuYn><joinRrno>830315-1******</joinRrno><bslcName>주식회사 마이크레딧체인</bslcName><ygBslcName></ygBslcName><ggBslcName></ggBslcName><gyBslcName></gyBslcName><sjBslcName></sjBslcName><bsmnRegno></bsmnRegno><ygBslcBsmnRegno></ygBslcBsmnRegno><ggBslcBsmnRegno></ggBslcBsmnRegno><gyBslcBsmnRegno></gyBslcBsmnRegno><sjBslcBsmnRegno></sjBslcBsmnRegno><bslcMgntNo></bslcMgntNo><rrno></rrno><name>정인규</name><ygJoinDt></ygJoinDt><ggJoinDt></ggJoinDt><gyJoinDt></gyJoinDt><sjJoinDt></sjJoinDt><pubapAcptNo></pubapAcptNo><acptOrgCd></acptOrgCd><acptBrofCd></acptBrofCd><acptBrofNm></acptBrofNm><pubapAcptPrsnId></pubapAcptPrsnId><stylEntrPrsnname></stylEntrPrsnname><acptDttm>2018.09.21</acptDttm><acptDttm1>2018.09.21</acptDttm1><acptDttm2>2018.09.21</acptDttm2><cnfmObjtPrsnName></cnfmObjtPrsnName><cnfmObjtPrsnRrno></cnfmObjtPrsnRrno><cnfmObjtPrsnRrno1></cnfmObjtPrsnRrno1><cnfmObjtPrsnRrno2></cnfmObjtPrsnRrno2><cnfmObjtPrsnTelno1></cnfmObjtPrsnTelno1><cnfmObjtPrsnTelno2></cnfmObjtPrsnTelno2><cnfmObjtPrsnTelno3></cnfmObjtPrsnTelno3><cnfmObjtPrsnPsno></cnfmObjtPrsnPsno><cnfmObjtPrsnPsno1></cnfmObjtPrsnPsno1><cnfmObjtPrsnPsno2></cnfmObjtPrsnPsno2><cnfmObjtPrsnAddr></cnfmObjtPrsnAddr><cnfmObjtPrsnBaseAddr></cnfmObjtPrsnBaseAddr><cnfmObjtPrsnDetailAddr></cnfmObjtPrsnDetailAddr><cnfmObjtPrsnNewAddr></cnfmObjtPrsnNewAddr><cnfmObjtPrsnNewBaseAddr></cnfmObjtPrsnNewBaseAddr><cnfmObjtPrsnNewDetailAddr></cnfmObjtPrsnNewDetailAddr><workBslcName></workBslcName><workBslcBsmnRegno></workBslcBsmnRegno><workBslcMgmtNo>25181010040</workBslcMgmtNo><issuUsgType></issuUsgType><propOrgName></propOrgName><issuUsgTypeName></issuUsgTypeName><joinCnfmKind></joinCnfmKind><joinCnfmKindNm></joinCnfmKindNm><rqstPrsnName></rqstPrsnName><rqstPrsnRrno></rqstPrsnRrno><rqstPrsnRrno1></rqstPrsnRrno1><rqstPrsnRrno2></rqstPrsnRrno2><rqstPrsnRelt></rqstPrsnRelt><rqstPrsnTelno1></rqstPrsnTelno1><rqstPrsnTelno2></rqstPrsnTelno2><rqstPrsnTelno3></rqstPrsnTelno3><rqstPrsnPsno></rqstPrsnPsno><rqstPrsnPsno1></rqstPrsnPsno1><rqstPrsnPsno2></rqstPrsnPsno2><rqstPrsnAddr></rqstPrsnAddr><rqstPrsnBaseAddr></rqstPrsnBaseAddr><rqstPrsnDetailAddr></rqstPrsnDetailAddr><rqstPrsnNewAddr></rqstPrsnNewAddr><rqstPrsnNewBaseAddr></rqstPrsnNewBaseAddr><rqstPrsnNewDetailAddr></rqstPrsnNewDetailAddr><acptMethCd></acptMethCd><procDttm>2018.09.21</procDttm><procDttm1>2018.09.21</procDttm1><procDttm2>2018.09.21</procDttm2><procStusType></procStusType><procStusMsg></procStusMsg><insId></insId><insDtm>2018.09.21</insDtm><insDtm1>2018.09.21</insDtm1><insDtm2>2018.09.21</insDtm2><updId></updId><updDtm>2018.09.21</updDtm><updDtm1>2018.09.21</updDtm1><updDtm2>2018.09.21</updDtm2><prsnNo></prsnNo><cnfmObjtPrsnNo></cnfmObjtPrsnNo><rqstPrsnNo></rqstPrsnNo><juminType></juminType><joinStus></joinStus><frmtDt></frmtDt><reppsName></reppsName><blscPlcAddr></blscPlcAddr><blscPlcNewAddr></blscPlcNewAddr><procOrgCd>YG</procOrgCd><joinKind>사업장가입자</joinKind><crtfObtnDt>2018.04.09</crtfObtnDt><acptStartDt></acptStartDt><acptEndDt></acptEndDt><crtfAcptDt>(2018.04.09)</crtfAcptDt><ygProcStusType></ygProcStusType><ggProcStusType></ggProcStusType><gyProcStusType></gyProcStusType><sjProcStusType></sjProcStusType><ygProcStusTypeMsg></ygProcStusTypeMsg><ggProcStusTypeMsg></ggProcStusTypeMsg><gyProcStusTypeMsg></gyProcStusTypeMsg><sjProcStusTypeMsg></sjProcStusTypeMsg><ygJisaCd></ygJisaCd><ggJisaCd></ggJisaCd><gyJisaName></gyJisaName><gyJisaCd></gyJisaCd><sjJisaName></sjJisaName><sjJisaCd></sjJisaCd><comboSearchCd></comboSearchCd><searchDivCd></searchDivCd><cnt>0</cnt><seqPrt>0</seqPrt><acptRrnoType></acptRrnoType><ptlGubun></ptlGubun><ygEaiTrstTypeCount></ygEaiTrstTypeCount><ggEaiTrstTypeCount></ggEaiTrstTypeCount><gyEaiTrstTypeCount></gyEaiTrstTypeCount><sjEaiTrstTypeCount></sjEaiTrstTypeCount><ygEaiTrstTypeAllcount></ygEaiTrstTypeAllcount><ggEaiTrstTypeAllcount></ggEaiTrstTypeAllcount><gyEaiTrstTypeAllcount></gyEaiTrstTypeAllcount><sjEaiTrstTypeAllcount></sjEaiTrstTypeAllcount><eaiTrstType></eaiTrstType><bslcMemberCount></bslcMemberCount><sortMeth></sortMeth></CdocAppl><CdocAppl><dir>ASC</dir><start>0</start><limit>10</limit><pageNo>1</pageNo><log class=\"org.apache.commons.logging.impl.Log4JLogger\" reference=\"../../CdocAppl/log\"/><rrnoPrtYn></rrnoPrtYn><issuNo>20180921488878</issuNo><issuDttm></issuDttm><issuLimitedYn></issuLimitedYn><issuYn></issuYn><joinRrno>830315-1******</joinRrno><bslcName>주식회사 마이크레딧체인</bslcName><ygBslcName></ygBslcName><ggBslcName></ggBslcName><gyBslcName></gyBslcName><sjBslcName></sjBslcName><bsmnRegno></bsmnRegno><ygBslcBsmnRegno></ygBslcBsmnRegno><ggBslcBsmnRegno></ggBslcBsmnRegno><gyBslcBsmnRegno></gyBslcBsmnRegno><sjBslcBsmnRegno></sjBslcBsmnRegno><bslcMgntNo></bslcMgntNo><rrno></rrno><name>정인규</name><ygJoinDt></ygJoinDt><ggJoinDt></ggJoinDt><gyJoinDt></gyJoinDt><sjJoinDt></sjJoinDt><pubapAcptNo></pubapAcptNo><acptOrgCd></acptOrgCd><acptBrofCd></acptBrofCd><acptBrofNm></acptBrofNm><pubapAcptPrsnId></pubapAcptPrsnId><stylEntrPrsnname></stylEntrPrsnname><acptDttm>2018.09.21</acptDttm><acptDttm1>2018.09.21</acptDttm1><acptDttm2>2018.09.21</acptDttm2><cnfmObjtPrsnName></cnfmObjtPrsnName><cnfmObjtPrsnRrno></cnfmObjtPrsnRrno><cnfmObjtPrsnRrno1></cnfmObjtPrsnRrno1><cnfmObjtPrsnRrno2></cnfmObjtPrsnRrno2><cnfmObjtPrsnTelno1></cnfmObjtPrsnTelno1><cnfmObjtPrsnTelno2></cnfmObjtPrsnTelno2><cnfmObjtPrsnTelno3></cnfmObjtPrsnTelno3><cnfmObjtPrsnPsno></cnfmObjtPrsnPsno><cnfmObjtPrsnPsno1></cnfmObjtPrsnPsno1><cnfmObjtPrsnPsno2></cnfmObjtPrsnPsno2><cnfmObjtPrsnAddr></cnfmObjtPrsnAddr><cnfmObjtPrsnBaseAddr></cnfmObjtPrsnBaseAddr><cnfmObjtPrsnDetailAddr></cnfmObjtPrsnDetailAddr><cnfmObjtPrsnNewAddr></cnfmObjtPrsnNewAddr><cnfmObjtPrsnNewBaseAddr></cnfmObjtPrsnNewBaseAddr><cnfmObjtPrsnNewDetailAddr></cnfmObjtPrsnNewDetailAddr><workBslcName></workBslcName><workBslcBsmnRegno></workBslcBsmnRegno><workBslcMgmtNo>25181010040</workBslcMgmtNo><issuUsgType></issuUsgType><propOrgName></propOrgName><issuUsgTypeName></issuUsgTypeName><joinCnfmKind></joinCnfmKind><joinCnfmKindNm></joinCnfmKindNm><rqstPrsnName></rqstPrsnName><rqstPrsnRrno></rqstPrsnRrno><rqstPrsnRrno1></rqstPrsnRrno1><rqstPrsnRrno2></rqstPrsnRrno2><rqstPrsnRelt></rqstPrsnRelt><rqstPrsnTelno1></rqstPrsnTelno1><rqstPrsnTelno2></rqstPrsnTelno2><rqstPrsnTelno3></rqstPrsnTelno3><rqstPrsnPsno></rqstPrsnPsno><rqstPrsnPsno1></rqstPrsnPsno1><rqstPrsnPsno2></rqstPrsnPsno2><rqstPrsnAddr></rqstPrsnAddr><rqstPrsnBaseAddr></rqstPrsnBaseAddr><rqstPrsnDetailAddr></rqstPrsnDetailAddr><rqstPrsnNewAddr></rqstPrsnNewAddr><rqstPrsnNewBaseAddr></rqstPrsnNewBaseAddr><rqstPrsnNewDetailAddr></rqstPrsnNewDetailAddr><acptMethCd></acptMethCd><procDttm>2018.09.21</procDttm><procDttm1>2018.09.21</procDttm1><procDttm2>2018.09.21</procDttm2><procStusType></procStusType><procStusMsg></procStusMsg><insId></insId><insDtm>2018.09.21</insDtm><insDtm1>2018.09.21</insDtm1><insDtm2>2018.09.21</insDtm2><updId></updId><updDtm>2018.09.21</updDtm><updDtm1>2018.09.21</updDtm1><updDtm2>2018.09.21</updDtm2><prsnNo></prsnNo><cnfmObjtPrsnNo></cnfmObjtPrsnNo><rqstPrsnNo></rqstPrsnNo><juminType></juminType><joinStus></joinStus><frmtDt></frmtDt><reppsName></reppsName><blscPlcAddr></blscPlcAddr><blscPlcNewAddr></blscPlcNewAddr><procOrgCd>GG</procOrgCd><joinKind>직장가입자</joinKind><crtfObtnDt>2018.04.09</crtfObtnDt><acptStartDt></acptStartDt><acptEndDt></acptEndDt><crtfAcptDt>(2018.04.09)</crtfAcptDt><ygProcStusType></ygProcStusType><ggProcStusType></ggProcStusType><gyProcStusType></gyProcStusType><sjProcStusType></sjProcStusType><ygProcStusTypeMsg></ygProcStusTypeMsg><ggProcStusTypeMsg></ggProcStusTypeMsg><gyProcStusTypeMsg></gyProcStusTypeMsg><sjProcStusTypeMsg></sjProcStusTypeMsg><ygJisaCd></ygJisaCd><ggJisaCd></ggJisaCd><gyJisaName></gyJisaName><gyJisaCd></gyJisaCd><sjJisaName></sjJisaName><sjJisaCd></sjJisaCd><comboSearchCd></comboSearchCd><searchDivCd></searchDivCd><cnt>0</cnt><seqPrt>0</seqPrt><acptRrnoType></acptRrnoType><ptlGubun></ptlGubun><ygEaiTrstTypeCount></ygEaiTrstTypeCount><ggEaiTrstTypeCount></ggEaiTrstTypeCount><gyEaiTrstTypeCount></gyEaiTrstTypeCount><sjEaiTrstTypeCount></sjEaiTrstTypeCount><ygEaiTrstTypeAllcount></ygEaiTrstTypeAllcount><ggEaiTrstTypeAllcount></ggEaiTrstTypeAllcount><gyEaiTrstTypeAllcount></gyEaiTrstTypeAllcount><sjEaiTrstTypeAllcount></sjEaiTrstTypeAllcount><eaiTrstType></eaiTrstType><bslcMemberCount></bslcMemberCount><sortMeth></sortMeth></CdocAppl><CdocAppl><dir>ASC</dir><start>0</start><limit>10</limit><pageNo>1</pageNo><log class=\"org.apache.commons.logging.impl.Log4JLogger\" reference=\"../../CdocAppl/log\"/><rrnoPrtYn></rrnoPrtYn><issuNo>20180921488878</issuNo><issuDttm></issuDttm><issuLimitedYn></issuLimitedYn><issuYn></issuYn><joinRrno>830315-1******</joinRrno><bslcName>주식회사 마이크레딧체인</bslcName><ygBslcName></ygBslcName><ggBslcName></ggBslcName><gyBslcName></gyBslcName><sjBslcName></sjBslcName><bsmnRegno></bsmnRegno><ygBslcBsmnRegno></ygBslcBsmnRegno><ggBslcBsmnRegno></ggBslcBsmnRegno><gyBslcBsmnRegno></gyBslcBsmnRegno><sjBslcBsmnRegno></sjBslcBsmnRegno><bslcMgntNo></bslcMgntNo><rrno></rrno><name>정인규</name><ygJoinDt></ygJoinDt><ggJoinDt></ggJoinDt><gyJoinDt></gyJoinDt><sjJoinDt></sjJoinDt><pubapAcptNo></pubapAcptNo><acptOrgCd></acptOrgCd><acptBrofCd></acptBrofCd><acptBrofNm></acptBrofNm><pubapAcptPrsnId></pubapAcptPrsnId><stylEntrPrsnname></stylEntrPrsnname><acptDttm>2018.09.21</acptDttm><acptDttm1>2018.09.21</acptDttm1><acptDttm2>2018.09.21</acptDttm2><cnfmObjtPrsnName></cnfmObjtPrsnName><cnfmObjtPrsnRrno></cnfmObjtPrsnRrno><cnfmObjtPrsnRrno1></cnfmObjtPrsnRrno1><cnfmObjtPrsnRrno2></cnfmObjtPrsnRrno2><cnfmObjtPrsnTelno1></cnfmObjtPrsnTelno1><cnfmObjtPrsnTelno2></cnfmObjtPrsnTelno2><cnfmObjtPrsnTelno3></cnfmObjtPrsnTelno3><cnfmObjtPrsnPsno></cnfmObjtPrsnPsno><cnfmObjtPrsnPsno1></cnfmObjtPrsnPsno1><cnfmObjtPrsnPsno2></cnfmObjtPrsnPsno2><cnfmObjtPrsnAddr></cnfmObjtPrsnAddr><cnfmObjtPrsnBaseAddr></cnfmObjtPrsnBaseAddr><cnfmObjtPrsnDetailAddr></cnfmObjtPrsnDetailAddr><cnfmObjtPrsnNewAddr></cnfmObjtPrsnNewAddr><cnfmObjtPrsnNewBaseAddr></cnfmObjtPrsnNewBaseAddr><cnfmObjtPrsnNewDetailAddr></cnfmObjtPrsnNewDetailAddr><workBslcName></workBslcName><workBslcBsmnRegno></workBslcBsmnRegno><workBslcMgmtNo>25181010040</workBslcMgmtNo><issuUsgType></issuUsgType><propOrgName></propOrgName><issuUsgTypeName></issuUsgTypeName><joinCnfmKind></joinCnfmKind><joinCnfmKindNm></joinCnfmKindNm><rqstPrsnName></rqstPrsnName><rqstPrsnRrno></rqstPrsnRrno><rqstPrsnRrno1></rqstPrsnRrno1><rqstPrsnRrno2></rqstPrsnRrno2><rqstPrsnRelt></rqstPrsnRelt><rqstPrsnTelno1></rqstPrsnTelno1><rqstPrsnTelno2></rqstPrsnTelno2><rqstPrsnTelno3></rqstPrsnTelno3><rqstPrsnPsno></rqstPrsnPsno><rqstPrsnPsno1></rqstPrsnPsno1><rqstPrsnPsno2></rqstPrsnPsno2><rqstPrsnAddr></rqstPrsnAddr><rqstPrsnBaseAddr></rqstPrsnBaseAddr><rqstPrsnDetailAddr></rqstPrsnDetailAddr><rqstPrsnNewAddr></rqstPrsnNewAddr><rqstPrsnNewBaseAddr></rqstPrsnNewBaseAddr><rqstPrsnNewDetailAddr></rqstPrsnNewDetailAddr><acptMethCd></acptMethCd><procDttm>2018.09.21</procDttm><procDttm1>2018.09.21</procDttm1><procDttm2>2018.09.21</procDttm2><procStusType></procStusType><procStusMsg></procStusMsg><insId></insId><insDtm>2018.09.21</insDtm><insDtm1>2018.09.21</insDtm1><insDtm2>2018.09.21</insDtm2><updId></updId><updDtm>2018.09.21</updDtm><updDtm1>2018.09.21</updDtm1><updDtm2>2018.09.21</updDtm2><prsnNo></prsnNo><cnfmObjtPrsnNo></cnfmObjtPrsnNo><rqstPrsnNo></rqstPrsnNo><juminType></juminType><joinStus></joinStus><frmtDt></frmtDt><reppsName></reppsName><blscPlcAddr></blscPlcAddr><blscPlcNewAddr></blscPlcNewAddr><procOrgCd>SJ</procOrgCd><joinKind>사업장가입자</joinKind><crtfObtnDt>2018.04.09</crtfObtnDt><acptStartDt></acptStartDt><acptEndDt></acptEndDt><crtfAcptDt>(2018.04.09)</crtfAcptDt><ygProcStusType></ygProcStusType><ggProcStusType></ggProcStusType><gyProcStusType></gyProcStusType><sjProcStusType></sjProcStusType><ygProcStusTypeMsg></ygProcStusTypeMsg><ggProcStusTypeMsg></ggProcStusTypeMsg><gyProcStusTypeMsg></gyProcStusTypeMsg><sjProcStusTypeMsg></sjProcStusTypeMsg><ygJisaCd></ygJisaCd><ggJisaCd></ggJisaCd><gyJisaName></gyJisaName><gyJisaCd></gyJisaCd><sjJisaName></sjJisaName><sjJisaCd></sjJisaCd><comboSearchCd></comboSearchCd><searchDivCd></searchDivCd><cnt>0</cnt><seqPrt>0</seqPrt><acptRrnoType></acptRrnoType><ptlGubun></ptlGubun><ygEaiTrstTypeCount></ygEaiTrstTypeCount><ggEaiTrstTypeCount></ggEaiTrstTypeCount><gyEaiTrstTypeCount></gyEaiTrstTypeCount><sjEaiTrstTypeCount></sjEaiTrstTypeCount><ygEaiTrstTypeAllcount></ygEaiTrstTypeAllcount><ggEaiTrstTypeAllcount></ggEaiTrstTypeAllcount><gyEaiTrstTypeAllcount></gyEaiTrstTypeAllcount><sjEaiTrstTypeAllcount></sjEaiTrstTypeAllcount><eaiTrstType></eaiTrstType><bslcMemberCount></bslcMemberCount><sortMeth></sortMeth></CdocAppl><CdocAppl><dir>ASC</dir><start>0</start><limit>10</limit><pageNo>1</pageNo><log class=\"org.apache.commons.logging.impl.Log4JLogger\" reference=\"../../CdocAppl/log\"/><rrnoPrtYn></rrnoPrtYn><issuNo>20180921488878</issuNo><issuDttm></issuDttm><issuLimitedYn></issuLimitedYn><issuYn></issuYn><joinRrno>830315-1******</joinRrno><bslcName>주식회사마이크레딧체인</bslcName><ygBslcName></ygBslcName><ggBslcName></ggBslcName><gyBslcName></gyBslcName><sjBslcName></sjBslcName><bsmnRegno></bsmnRegno><ygBslcBsmnRegno></ygBslcBsmnRegno><ggBslcBsmnRegno></ggBslcBsmnRegno><gyBslcBsmnRegno></gyBslcBsmnRegno><sjBslcBsmnRegno></sjBslcBsmnRegno><bslcMgntNo></bslcMgntNo><rrno></rrno><name>정인규</name><ygJoinDt></ygJoinDt><ggJoinDt></ggJoinDt><gyJoinDt></gyJoinDt><sjJoinDt></sjJoinDt><pubapAcptNo></pubapAcptNo><acptOrgCd></acptOrgCd><acptBrofCd></acptBrofCd><acptBrofNm></acptBrofNm><pubapAcptPrsnId></pubapAcptPrsnId><stylEntrPrsnname></stylEntrPrsnname><acptDttm>2018.09.21</acptDttm><acptDttm1>2018.09.21</acptDttm1><acptDttm2>2018.09.21</acptDttm2><cnfmObjtPrsnName></cnfmObjtPrsnName><cnfmObjtPrsnRrno></cnfmObjtPrsnRrno><cnfmObjtPrsnRrno1></cnfmObjtPrsnRrno1><cnfmObjtPrsnRrno2></cnfmObjtPrsnRrno2><cnfmObjtPrsnTelno1></cnfmObjtPrsnTelno1><cnfmObjtPrsnTelno2></cnfmObjtPrsnTelno2><cnfmObjtPrsnTelno3></cnfmObjtPrsnTelno3><cnfmObjtPrsnPsno></cnfmObjtPrsnPsno><cnfmObjtPrsnPsno1></cnfmObjtPrsnPsno1><cnfmObjtPrsnPsno2></cnfmObjtPrsnPsno2><cnfmObjtPrsnAddr></cnfmObjtPrsnAddr><cnfmObjtPrsnBaseAddr></cnfmObjtPrsnBaseAddr><cnfmObjtPrsnDetailAddr></cnfmObjtPrsnDetailAddr><cnfmObjtPrsnNewAddr></cnfmObjtPrsnNewAddr><cnfmObjtPrsnNewBaseAddr></cnfmObjtPrsnNewBaseAddr><cnfmObjtPrsnNewDetailAddr></cnfmObjtPrsnNewDetailAddr><workBslcName></workBslcName><workBslcBsmnRegno></workBslcBsmnRegno><workBslcMgmtNo>25181010040</workBslcMgmtNo><issuUsgType></issuUsgType><propOrgName></propOrgName><issuUsgTypeName></issuUsgTypeName><joinCnfmKind></joinCnfmKind><joinCnfmKindNm></joinCnfmKindNm><rqstPrsnName></rqstPrsnName><rqstPrsnRrno></rqstPrsnRrno><rqstPrsnRrno1></rqstPrsnRrno1><rqstPrsnRrno2></rqstPrsnRrno2><rqstPrsnRelt></rqstPrsnRelt><rqstPrsnTelno1></rqstPrsnTelno1><rqstPrsnTelno2></rqstPrsnTelno2><rqstPrsnTelno3></rqstPrsnTelno3><rqstPrsnPsno></rqstPrsnPsno><rqstPrsnPsno1></rqstPrsnPsno1><rqstPrsnPsno2></rqstPrsnPsno2><rqstPrsnAddr></rqstPrsnAddr><rqstPrsnBaseAddr></rqstPrsnBaseAddr><rqstPrsnDetailAddr></rqstPrsnDetailAddr><rqstPrsnNewAddr></rqstPrsnNewAddr><rqstPrsnNewBaseAddr></rqstPrsnNewBaseAddr><rqstPrsnNewDetailAddr></rqstPrsnNewDetailAddr><acptMethCd></acptMethCd><procDttm>2018.09.21</procDttm><procDttm1>2018.09.21</procDttm1><procDttm2>2018.09.21</procDttm2><procStusType></procStusType><procStusMsg></procStusMsg><insId></insId><insDtm>2018.09.21</insDtm><insDtm1>2018.09.21</insDtm1><insDtm2>2018.09.21</insDtm2><updId></updId><updDtm>2018.09.21</updDtm><updDtm1>2018.09.21</updDtm1><updDtm2>2018.09.21</updDtm2><prsnNo></prsnNo><cnfmObjtPrsnNo></cnfmObjtPrsnNo><rqstPrsnNo></rqstPrsnNo><juminType></juminType><joinStus></joinStus><frmtDt></frmtDt><reppsName></reppsName><blscPlcAddr></blscPlcAddr><blscPlcNewAddr></blscPlcNewAddr><procOrgCd>GY</procOrgCd><joinKind>사업장가입자</joinKind><crtfObtnDt>2018.04.09</crtfObtnDt><acptStartDt></acptStartDt><acptEndDt></acptEndDt><crtfAcptDt>(2018.04.09)</crtfAcptDt><ygProcStusType></ygProcStusType><ggProcStusType></ggProcStusType><gyProcStusType></gyProcStusType><sjProcStusType></sjProcStusType><ygProcStusTypeMsg></ygProcStusTypeMsg><ggProcStusTypeMsg></ggProcStusTypeMsg><gyProcStusTypeMsg></gyProcStusTypeMsg><sjProcStusTypeMsg></sjProcStusTypeMsg><ygJisaCd></ygJisaCd><ggJisaCd></ggJisaCd><gyJisaName></gyJisaName><gyJisaCd></gyJisaCd><sjJisaName></sjJisaName><sjJisaCd></sjJisaCd><comboSearchCd></comboSearchCd><searchDivCd></searchDivCd><cnt>0</cnt><seqPrt>0</seqPrt><acptRrnoType></acptRrnoType><ptlGubun></ptlGubun><ygEaiTrstTypeCount></ygEaiTrstTypeCount><ggEaiTrstTypeCount></ggEaiTrstTypeCount><gyEaiTrstTypeCount></gyEaiTrstTypeCount><sjEaiTrstTypeCount></sjEaiTrstTypeCount><ygEaiTrstTypeAllcount></ygEaiTrstTypeAllcount><ggEaiTrstTypeAllcount></ggEaiTrstTypeAllcount><gyEaiTrstTypeAllcount></gyEaiTrstTypeAllcount><sjEaiTrstTypeAllcount></sjEaiTrstTypeAllcount><eaiTrstType></eaiTrstType><bslcMemberCount></bslcMemberCount><sortMeth></sortMeth></CdocAppl></list>"
    }
    func issueCar() -> String {
        return "<?xml version=\"1.0\" encoding=\"UTF-8\"?><database version=\'3.0.0.0\'><doc_info name=\'doc_info\'><doc_cnfirm_no><![CDATA[5299-2531-5931-9058]]></doc_cnfirm_no><num><![CDATA[004730]]></num><make_date><![CDATA[20180921135729]]></make_date></doc_info><basic_info name=\'basic_info\'><datatable name=\'\'><rexrow><VHRNO><![CDATA[36조8458]]></VHRNO><PROCESS_IMPRTY_RESN_CODE><![CDATA[00]]></PROCESS_IMPRTY_RESN_CODE><PROCESS_IMPRTY_RESN_DTLS><![CDATA[정상]]></PROCESS_IMPRTY_RESN_DTLS><LEDGER_GROUP_NO><![CDATA[1]]></LEDGER_GROUP_NO><LEDGER_INDVDLZ_NO><![CDATA[1]]></LEDGER_INDVDLZ_NO><VHMNO><![CDATA[KLAYA75YDEK593908-01]]></VHMNO><VIN><![CDATA[KLAYA75YDEK593908]]></VIN><VHCTY_ASORT_CODE><![CDATA[1]]></VHCTY_ASORT_CODE><VHCTY_ASORT_NM><![CDATA[승용 중형]]></VHCTY_ASORT_NM><CNM><![CDATA[올란도 2.0 디젤]]></CNM><COLOR_CODE><![CDATA[01]]></COLOR_CODE><COLOR_NM><![CDATA[검정]]></COLOR_NM><NMPL_STNDRD_CODE><![CDATA[2]]></NMPL_STNDRD_CODE><NMPL_STNDRD_NM><![CDATA[긴번호판]]></NMPL_STNDRD_NM><PRPOS_SE_CODE><![CDATA[2]]></PRPOS_SE_CODE><PRPOS_SE_NM><![CDATA[자가용]]></PRPOS_SE_NM><MTRS_FOM_NM><![CDATA[Z20D1]]></MTRS_FOM_NM><FOM_NM><![CDATA[YA75Y]]></FOM_NM><ACQS_AMOUNT><![CDATA[24,969,091]]></ACQS_AMOUNT><REGIST_DETAIL_CODE><![CDATA[100]]></REGIST_DETAIL_CODE><REGIST_DETAIL_NM><![CDATA[일반소유용]]></REGIST_DETAIL_NM><FRST_REGIST_DE><![CDATA[2014-05-27]]></FRST_REGIST_DE><CAAG_ENDDE><![CDATA[]]></CAAG_ENDDE><PRYE><![CDATA[2014]]></PRYE><SPMNNO><![CDATA[A07-1-00016-0011-1213]]></SPMNNO><YBL_MD><![CDATA[2014-04-08]]></YBL_MD><INSPT_VALID_PD_DATE><![CDATA[2018-05-27 ~ 2020-05-26             주행거리 : 51599]]></INSPT_VALID_PD_DATE><CHCK_VALID_PD_DATE><![CDATA[]]></CHCK_VALID_PD_DATE><REGIST_REQST_SE_NM><![CDATA[신조차]]></REGIST_REQST_SE_NM><FRST_REGIST_RQRCNO><![CDATA[]]></FRST_REGIST_RQRCNO><NMPL_CSDY_REMNR_DE><![CDATA[]]></NMPL_CSDY_REMNR_DE><NMPL_CSDY_AT><![CDATA[N]]></NMPL_CSDY_AT><BSS_USE_PD><![CDATA[]]></BSS_USE_PD><OCTHT_ERSR_PRVNTC_NTICE_DE><![CDATA[]]></OCTHT_ERSR_PRVNTC_NTICE_DE><ERSR_REGIST_DE><![CDATA[]]></ERSR_REGIST_DE><ERSR_REGIST_SE_CODE><![CDATA[]]></ERSR_REGIST_SE_CODE><ERSR_REGIST_SE_NM><![CDATA[]]></ERSR_REGIST_SE_NM><MRTGCNT><![CDATA[0]]></MRTGCNT><VHCLECNT><![CDATA[0]]></VHCLECNT><STMDCNT><![CDATA[]]></STMDCNT><ADRES1><![CDATA[경기도 용인시 기흥구 언동로217번길 **-******]]></ADRES1><ADRES_NM1><![CDATA[****]]></ADRES_NM1><ADRES><![CDATA[경기도 용인시 기흥구 언동로217번길 **-**]]></ADRES><ADRES_NM><![CDATA[****]]></ADRES_NM><INDVDL_BSNM_AT><![CDATA[]]></INDVDL_BSNM_AT><TELNO><![CDATA[]]></TELNO><MBER_NM><![CDATA[정인규]]></MBER_NM><MBER_SE_CODE><![CDATA[11]]></MBER_SE_CODE><MBER_SE_NO><![CDATA[830315-1******]]></MBER_SE_NO><MBER_NM1><![CDATA[]]></MBER_NM1><IHIDNUM1><![CDATA[]]></IHIDNUM1><TAXXMPT_TRGTER_SE_CODE><![CDATA[0]]></TAXXMPT_TRGTER_SE_CODE><TAXXMPT_TRGTER_SE_CODE_NM><![CDATA[미적용]]></TAXXMPT_TRGTER_SE_CODE_NM><CNT_MATTER><![CDATA[0]]></CNT_MATTER><EMD_NM><![CDATA[동백동]]></EMD_NM><PRVNTCCNT><![CDATA[0]]></PRVNTCCNT><XPORT_FLFL_AT_STTEMNT_DE><![CDATA[]]></XPORT_FLFL_AT_STTEMNT_DE><PARTN_RQRCNO><![CDATA[011042]]></PARTN_RQRCNO><FRST_TRNSFR_DE><![CDATA[]]></FRST_TRNSFR_DE></rexrow></datatable></basic_info><detail_info name=\'detail_info\'><datatable name=\'\'><rexrow><MAINCHK><![CDATA[1]]></MAINCHK><CHANGE_JOB_SE_CODE><![CDATA[01]]></CHANGE_JOB_SE_CODE><MAINNO><![CDATA[1-1]]></MAINNO><SUBNO><![CDATA[]]></SUBNO><DTLS><![CDATA[성명(상호) : 정**  830315-1******주소 : 경기도 성남시 중원구 둔촌대로 **-**, ****]]></DTLS><HSHLDR_MBER_NM><![CDATA[]]></HSHLDR_MBER_NM><HSHLDR_MBER_NUM><![CDATA[830315-1******]]></HSHLDR_MBER_NUM><RQRCNO><![CDATA[032674]]></RQRCNO><VHMNO><![CDATA[KLAYA75YDEK593908-01]]></VHMNO><LEDGER_GROUP_NO><![CDATA[1]]></LEDGER_GROUP_NO><LEDGER_INDVDLZ_NO><![CDATA[1]]></LEDGER_INDVDLZ_NO><GUBUN_NM><![CDATA[신규등록(신조차)]]></GUBUN_NM><CHANGE_DE><![CDATA[2014-05-27]]></CHANGE_DE><DETAIL_SN><![CDATA[1]]></DETAIL_SN><FLAG><![CDATA[]]></FLAG></rexrow><rexrow><MAINCHK><![CDATA[1]]></MAINCHK><CHANGE_JOB_SE_CODE><![CDATA[21]]></CHANGE_JOB_SE_CODE><MAINNO><![CDATA[1-2]]></MAINNO><SUBNO><![CDATA[]]></SUBNO><DTLS><![CDATA[주소 : 경기도 용인시 기흥구 동백8로 **-**, ****  ]]></DTLS><HSHLDR_MBER_NM><![CDATA[]]></HSHLDR_MBER_NM><HSHLDR_MBER_NUM><![CDATA[]]></HSHLDR_MBER_NUM><RQRCNO><![CDATA[053698]]></RQRCNO><VHMNO><![CDATA[KLAYA75YDEK593908-01]]></VHMNO><LEDGER_GROUP_NO><![CDATA[1]]></LEDGER_GROUP_NO><LEDGER_INDVDLZ_NO><![CDATA[1]]></LEDGER_INDVDLZ_NO><GUBUN_NM><![CDATA[변경등록]]></GUBUN_NM><CHANGE_DE><![CDATA[2015-01-21]]></CHANGE_DE><DETAIL_SN><![CDATA[2]]></DETAIL_SN><FLAG><![CDATA[]]></FLAG></rexrow><rexrow><MAINCHK><![CDATA[1]]></MAINCHK><CHANGE_JOB_SE_CODE><![CDATA[21]]></CHANGE_JOB_SE_CODE><MAINNO><![CDATA[1-3]]></MAINNO><SUBNO><![CDATA[]]></SUBNO><DTLS><![CDATA[주소 : 경기도 고양시 덕양구 서정마을로 **-**, ****  ]]></DTLS><HSHLDR_MBER_NM><![CDATA[]]></HSHLDR_MBER_NM><HSHLDR_MBER_NUM><![CDATA[]]></HSHLDR_MBER_NUM><RQRCNO><![CDATA[008295]]></RQRCNO><VHMNO><![CDATA[KLAYA75YDEK593908-01]]></VHMNO><LEDGER_GROUP_NO><![CDATA[1]]></LEDGER_GROUP_NO><LEDGER_INDVDLZ_NO><![CDATA[1]]></LEDGER_INDVDLZ_NO><GUBUN_NM><![CDATA[변경등록]]></GUBUN_NM><CHANGE_DE><![CDATA[2016-09-01]]></CHANGE_DE><DETAIL_SN><![CDATA[3]]></DETAIL_SN><FLAG><![CDATA[]]></FLAG></rexrow><rexrow><MAINCHK><![CDATA[1]]></MAINCHK><CHANGE_JOB_SE_CODE><![CDATA[31]]></CHANGE_JOB_SE_CODE><MAINNO><![CDATA[1-4]]></MAINNO><SUBNO><![CDATA[]]></SUBNO><DTLS><![CDATA[행신지정서비스주식회사 검사구분 : 정기검사 주행거리 : 51599 ]]></DTLS><HSHLDR_MBER_NM><![CDATA[]]></HSHLDR_MBER_NM><HSHLDR_MBER_NUM><![CDATA[]]></HSHLDR_MBER_NUM><RQRCNO><![CDATA[0006-1]]></RQRCNO><VHMNO><![CDATA[KLAYA75YDEK593908-01]]></VHMNO><LEDGER_GROUP_NO><![CDATA[1]]></LEDGER_GROUP_NO><LEDGER_INDVDLZ_NO><![CDATA[1]]></LEDGER_INDVDLZ_NO><GUBUN_NM><![CDATA[자동차검사]]></GUBUN_NM><CHANGE_DE><![CDATA[2018-05-29]]></CHANGE_DE><DETAIL_SN><![CDATA[4]]></DETAIL_SN><FLAG><![CDATA[]]></FLAG></rexrow><rexrow><MAINCHK><![CDATA[1]]></MAINCHK><CHANGE_JOB_SE_CODE><![CDATA[21]]></CHANGE_JOB_SE_CODE><MAINNO><![CDATA[1-5]]></MAINNO><SUBNO><![CDATA[]]></SUBNO><DTLS><![CDATA[주소 : 경기도 용인시 기흥구 언동로217번길 **-**, ****  ]]></DTLS><HSHLDR_MBER_NM><![CDATA[]]></HSHLDR_MBER_NM><HSHLDR_MBER_NUM><![CDATA[]]></HSHLDR_MBER_NUM><RQRCNO><![CDATA[038846]]></RQRCNO><VHMNO><![CDATA[KLAYA75YDEK593908-01]]></VHMNO><LEDGER_GROUP_NO><![CDATA[1]]></LEDGER_GROUP_NO><LEDGER_INDVDLZ_NO><![CDATA[1]]></LEDGER_INDVDLZ_NO><GUBUN_NM><![CDATA[변경등록]]></GUBUN_NM><CHANGE_DE><![CDATA[2018-09-07]]></CHANGE_DE><DETAIL_SN><![CDATA[5]]></DETAIL_SN><FLAG><![CDATA[]]></FLAG></rexrow></datatable></detail_info></database>"
    }
    func testFincRequest2() {
        
//        let string = jsonString()
//
//        let result = convertToDictionary(text: string)
//        print(result as Any)
        
        //        self.requestFinc(successAction: nil, failedAction: nil)
        
        print("=====================자격==========================");
        let xml = SWXMLHash.parse(self.issue자격())
//        let count = xml["root"]["dataset"]["record"].all.count
        let today = Date()
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "YYYYMMdd"
//        print(dateFormatterPrint.string(from: today))
        var daysum = 0
        for record in xml["root"]["dataset"]["record"].all {
            guard let type = record["OUT03"].element?.text, type == "직장가입자" else {
                continue
            }
            let dateOut5 = record["OUT05"].element?.text ?? nil
            var dateOut6 = record["OUT06"].element?.text ?? nil
            if dateOut6 == "" {
                dateOut6 = dateFormatterPrint.string(from: today)
            }
            let betweendate = (Date(parse: dateOut5!, format: "YYYYMMdd", locale: "ko_KR")?.daysBetween(Date(parse: dateOut6!, format: "YYYYMMdd", locale: "ko_KR")!))!
            daysum = daysum + betweendate
        }
        let dayOffset = DateComponents(day: daysum)
        if let d100 = Calendar.current.date(byAdding: dayOffset, to: today) {
//            print("result - !!" , dateFormatterPrint.string(from: d100))
            do {
                let formatter = DateComponentsFormatter()
                formatter.allowedUnits = [.year, .month, .day]
                formatter.unitsStyle = .full   // 이유는 모르겠으나 꼭 필요하다!
                formatter.calendar?.locale = Locale(identifier:"ko_KR")
//                    .locale = Locale(identifier:"ko_KR")
                if let daysString = formatter.string(from: today, to: d100) {
                    print("\(daysString) 근무하셨습니다.") // 2년 4개월 14일
                }
            }
        }
        
        print("==================================================");
        
        print("=====================소득==========================");
        
        
        
        let xml2 = SWXMLHash.parse(self.issue소득())
        let companyNameEng : String? = xml2["root"]["incAmtCerDVOList"]["rows"][0]["lvyRperEnglTnmNm"].element?.text
        let sdAmount : String? = xml2["root"]["incAmtCerDVOList"]["rows"][0]["txtnTrgtSnwAmt"].element?.text
        let companyNameKor : String? = xml2["root"]["incAmtCerDVOList"]["rows"][0]["lvyRperTnmNm"].element?.text
        let attrYr : String? = xml2["root"]["incAmtCerDVOList"]["rows"][0]["attrYr"].element?.text
        let lvyRperNo : String? = xml2["root"]["incAmtCerDVOList"]["rows"][0]["lvyRperNo"].element?.text
        
        let cvaKndNm = xml2["root"]["cerpBscInfrDVO"]["cvaChrgOgzEnglNm"]["cvaChrgOgzEnglNm"]["cvaKndNm"].element?.text
        let cvarLdAdr = xml2["root"]["cerpBscInfrDVO"]["cvaChrgOgzEnglNm"]["cvaChrgOgzEnglNm"]["cvarLdAdr"].element?.text
        
       
        print("회사명(한글) :", companyNameKor ?? "");
        print("회사명(영어) : ", companyNameEng ?? "");
        print("소득금액 : ", sdAmount ?? "");
        print("대상년도 : ", attrYr ?? "");
        print("사업자등록번호 : ", lvyRperNo ?? "");
        print("문서 종류 : ", cvaKndNm ?? "");
        print("주소지 : ", cvarLdAdr ?? "");
        
        
        print("==================================================");
        print("=====================4대보험==========================");
        
        let xml3 = SWXMLHash.parse(self.issue4대())
        
        for record in xml3["list"]["CdocAppl"].all {
            
            let joinRrno : String? = record["joinRrno"].element?.text
            let bslcName : String? = record["bslcName"].element?.text
            let name : String? = record["name"].element?.text
            let issuNo : String? = record["issuNo"].element?.text
            let joinKind : String? = record["joinKind"].element?.text
            let procOrgCd : String? = record["procOrgCd"].element?.text
            
        
            print("==start");
            print("주민등록번호 :", joinRrno ?? "");
            print("회사이름 :", bslcName ?? "");
            print("본인성명 :", name ?? "");
            print("사업자번호 :", issuNo ?? "");
            print("가입형태 :", joinKind ?? "");
            print("가입형태(XX) :", self.typeToString(text: procOrgCd!));
            print("==end");
        }
        
        let xml4 = SWXMLHash.parse(self.issueCar())
        let doc_cnfirm_no : String? = xml4["database"]["doc_info"]["doc_cnfirm_no"].element?.text
        let VHRNO : String? = xml4["database"]["basic_info"]["datatable"]["rexrow"]["VHRNO"].element?.text
        let VHCTY_ASORT_NM : String? = xml4["database"]["basic_info"]["datatable"]["rexrow"]["VHCTY_ASORT_NM"].element?.text
        let CNM : String? = xml4["database"]["basic_info"]["datatable"]["rexrow"]["CNM"].element?.text
        let COLOR_NM : String? = xml4["database"]["basic_info"]["datatable"]["rexrow"]["COLOR_NM"].element?.text
        let PRPOS_SE_NM : String? = xml4["database"]["basic_info"]["datatable"]["rexrow"]["PRPOS_SE_NM"].element?.text
        let FRST_REGIST_DE : String? = xml4["database"]["basic_info"]["datatable"]["rexrow"]["FRST_REGIST_DE"].element?.text
        let ADRES : String? = xml4["database"]["basic_info"]["datatable"]["rexrow"]["ADRES"].element?.text
        let MBER_NM : String? = xml4["database"]["basic_info"]["datatable"]["rexrow"]["MBER_NM"].element?.text
        let MBER_SE_NO : String? = xml4["database"]["basic_info"]["datatable"]["rexrow"]["MBER_SE_NO"].element?.text
        
        print("==start");
        print("자동차등록번호 :", doc_cnfirm_no ?? "");
        print("차량번호 :", VHRNO ?? "");
        print("차량 사이즈 :", VHCTY_ASORT_NM ?? "");
        print("차량 이름 :", CNM ?? "");
        print("차량 색상 :", COLOR_NM ?? "");
        print("차량 목적 :", PRPOS_SE_NM ?? "");
        print("차량 구매날짜 :", FRST_REGIST_DE ?? "");
        print("차량 현재주소 :", ADRES ?? "");
        print("소유자 :", MBER_NM ?? "");
        print("소유자 주민번호 :", MBER_SE_NO ?? "");
        
//        print("가입형태(XX) :", self.typeToString(text: procOrgCd!));
        print("==end");
        
    }
    func typeToString(text : String) -> String {
        if text == "YG" {
            return "국민연금"
        }
        else if text == "GG" {
            return "건강보험"
        }
        else if text == "SJ" {
            return "산재보험"
        }
        else if text == "GY" {
            return "고용보험"
        }
        return ""
    }
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
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

