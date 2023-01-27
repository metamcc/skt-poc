
//
//  MainRootViewController.swift
//  mcc-mvp
//
//  Created by JIK on 2018. 5. 16..
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

extension Notification.Name {
    static let reloadFiles = Notification.Name("reloadFiles")
}


let kUser_id = "kUserID"
let app_title = "MCC"

let credit_for_me = "29EAD71A44"
let credit_for_other = "E2433D5173"

let customer_list = "E2433D5173"

let KEY : String = "C8F2610A0EF5B6B"

let clist_key = "246B86ADF8E3"
let clist : [String:String] = ["2BEFDFFD20DD" : "A", "0994B9986BCE" : "B", "542FC6B23424" : "C"]

class MainVC: UITableViewController, InputEmailVCDelegate, TopHeaderViewDelegate {
    
    
    
    @IBOutlet weak var emailLabel : UILabel!
    @IBOutlet weak var userImageView : UIImageView!
    @IBOutlet weak var addNewCreditInfoBtn : UIButton!
    
    @IBOutlet weak var topHeaderView : TopHeaderView!
    
    var isSelectedHeader = false
    
    var isCheckedNodes : Bool = false
    
    var nodeStatus = [
        false,
        false,
        false
    ]
    
    var nodeIds : [String:String] = [:]
    var myCreditFiles : [NSDictionary] = []
    
    struct nodeStatusResult {
        var nodeMain = false
        var node = 1
        var month = 1
        var day = 1
    }
    
    var request: Alamofire.Request? {
        didSet {
            oldValue?.cancel()
            headers.removeAll()
            body = nil
            elapsedTime = nil
        }
    }
    
    var headers: [String: String] = [:]
    var body: String? 
    var elapsedTime: TimeInterval?
    var segueIdentifier: String?
    
    var hostString_Nod = ["13.125.127.185","13.125.49.171","13.124.97.93"]
    let hostPort        = 5001
    
    var userid : String?
    
    func getIds(hostString : String!, nodeIndex : Int) {
        do {
            let api = try IpfsApi(host: hostString, port: self.hostPort)
            try api.id() {
                result in
                //                print(result);
                if let nodeid = result.object?["ID"]?.string {
                    self.nodeIds[hostString] = nodeid
                }
                print(self.nodeIds[hostString] as Any);
            }
        }
        catch {
            print("\(error)")
        }
    }
    
    @IBAction func didTouchAddCreditInfo(sender : UIButton!) {
        
        if self.isCheckedNodes == false {
            HUD.show(.labeledRotatingImage(image: UIImage(named: "mcc-loading"), title: app_title , subtitle: "IPFS 노드 확인중"))
            
            // 그룹 생성
            let g = DispatchGroup()
            
            var index = 0
            for nodeHost in hostString_Nod {
                let q1 = DispatchQueue(label: nodeHost)
                q1.async(group: g) {
                    self.getIds(hostString: nodeHost, nodeIndex: index)
                }
                print(" node : \(nodeHost)\"[\(index)]")
                index += 1
            }
            g.notify(queue: DispatchQueue.main) {
                print("전체 작업완료")
                HUD.hide(afterDelay: 1.5, completion: { (completed) in
                    if self.parent != nil{
                        PopupHelper.showPopupFromStoryBoard(storyBoard: "Main", popupName: "NodesVC", viewController: self.parent!, blurBackground: true, size: CGSize(width: 300, height: 280), sender: self.nodeIds)
                    }
                })
                print("nodeIds : \(self.nodeIds)")
            }
            
            return;
        }
        
        HUD.show(.labeledRotatingImage(image: UIImage(named: "mcc-loading"), title: nil, subtitle: nil))
        if let path = Bundle.main.path(forResource: "jsondata", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                do{
                    let json =  try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    let jsonDictionary =  json as! Dictionary<String,Any>
                    print("\(jsonDictionary)")
                    HUD.hide(afterDelay: 1.0)
                    
                    
                }catch let error{
                    print(error.localizedDescription)
                }
            } catch let error {
                print(error.localizedDescription)
            }
        } else {
            print("Invalid filename/path.")
        }
    }
    func topHeaderViewFilesDidSelectedCell(_ fileInfo: NSDictionary) {
        if self.isCheckedNodes {
            if self.parent != nil{
                PopupHelper.showPopupFromStoryBoard(storyBoard: "Main", popupName: "selectNodesVC", viewController: self.parent!, blurBackground: true, size: CGSize(width: 300, height: 280), sender: ["nodes":self.nodeIds,"file":fileInfo])
            }
            return
        }
        
        if self.isCheckedNodes == false {
            HUD.show(.labeledRotatingImage(image: UIImage(named: "mcc-loading"), title: app_title , subtitle: "IPFS 노드 확인중"))
            
            // 그룹 생성
            let g = DispatchGroup()
            
            var index = 0
            for nodeHost in hostString_Nod {
                let q1 = DispatchQueue(label: nodeHost)
                q1.async(group: g) {
                    self.getIds(hostString: nodeHost, nodeIndex: index)
                }
                print(" node : \(nodeHost)\"[\(index)]")
                index += 1
            }
            g.notify(queue: DispatchQueue.main) {
                print("전체 작업완료")
                HUD.hide(afterDelay: 1.5, completion: { (completed) in
                    if self.parent != nil{
                        PopupHelper.showPopupFromStoryBoard(storyBoard: "Main", popupName: "selectNodesVC", viewController: self.parent!, blurBackground: true, size: CGSize(width: 300, height: 280), sender: ["nodes":self.nodeIds,"file":fileInfo])
                    }
                })
                print("nodeIds : \(self.nodeIds)")
            }
            
            return;
        }
        HUD.show(.labeledRotatingImage(image: UIImage(named: "mcc-loading"), title: nil, subtitle: nil))
        if let path = Bundle.main.path(forResource: "jsondata", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                do{
                    let json =  try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    let jsonDictionary =  json as! Dictionary<String,Any>
                    print("\(jsonDictionary)")
                    HUD.hide(afterDelay: 1.0)
                    
                    
                }catch let error{
                    print(error.localizedDescription)
                }
            } catch let error {
                print(error.localizedDescription)
            }
        } else {
            print("Invalid filename/path.")
        }
        
    }
    
    
    func inputEmailVCDidInputEmail(_ email: String) {
        self.topHeaderView.emailLabel.text = email
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func reloadFiles(notification: NSNotification) {
        if notification.object != nil {
            self.myCreditFiles = notification.object! as! [NSDictionary];
        }
        self.topHeaderView.dataSource = self.myCreditFiles
        self.topHeaderView.collectionView.reloadData()
    }
    
    @objc func applicationDidBecomeActive(notification: NSNotification) {
        self.refresh(refreshControl!)
        
    }
    @objc func refresh(_ sender: UIRefreshControl) {
        guard let userid = UserDefaults.standard.string(forKey: kUser_id) else {
            HUD.hide()
            self.performSegue(withIdentifier: MCCSegueKeys.modalToInputEmailVC, sender: nil)
            return
        }
        MCCRequest.Instance.requestGet(userid: userid, requestType: credit_for_me, success: { (json : NSDictionary) in
            let requestQuery = "\(userid as String)_\(credit_for_me as String)"
            HUD.hide(afterDelay: 1.5)
            let resultKey = json.value(forKey: "key") as! String?
            let resultValue = json.value(forKey: "value") as? String
            
            if resultKey != requestQuery {
                return;
            }
            let decryptresult = try? MCCCrypto.Instance.decryptMessage(encryptedMessage: resultValue!, encryptionKey: KEY)
            
            guard let jdata = decryptresult?.data(using: .utf8) else {
                self.myCreditFiles = []
                self.topHeaderView.dataSource = self.myCreditFiles
                self.topHeaderView.collectionView.reloadData()
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
                return;
            }
            let dictionary = try? JSONSerialization.jsonObject(with: jdata, options: .mutableLeaves)
            
            if dictionary != nil {
                self.myCreditFiles = dictionary! as! [NSDictionary];
            }
            self.topHeaderView.dataSource = self.myCreditFiles
            self.topHeaderView.collectionView.reloadData()
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
            
        }) { (error) in
            self.refreshControl?.endRefreshing()
            HUD.hide(afterDelay: 1.5)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadFiles(notification:)), name: .reloadFiles, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(notification:)), name: .UIApplicationDidBecomeActive, object: nil)
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        refreshControl?.tintColor = UIColor.init(red: 255/255, green: 187/255, blue: 66/255, alpha: 1)
        
        self.topHeaderView.delegate = self;
        
        HUD.show(.labeledRotatingImage(image: UIImage(named: "mcc-loading"), title: app_title, subtitle: "Init.."))
        guard let userid = UserDefaults.standard.string(forKey: kUser_id) else {
            HUD.hide()
            self.performSegue(withIdentifier: MCCSegueKeys.modalToInputEmailVC, sender: nil)
            return
        }
        
        //        let jsonData = try? JSONSerialization.data(withJSONObject: clist, options: [])
        //        let jsonString = String(data: jsonData!, encoding: .utf8)
        //        let result = try? MCCCrypto.Instance.encryptMessage(message: jsonString!, encryptionKey: KEY)
        //
        //        MCCRequest.Instance.requestPost(parameter: [ "key" : customer_list, "value": result!], success: { (json : NSDictionary) in
        //            print(json)
        //            let value = json.value(forKey: "value");
        //            let decryptresult = try? MCCCrypto.Instance.decryptMessage(encryptedMessage: value as! String, encryptionKey: KEY)
        //            print(decryptresult as Any)
        //        }) { (error) in
        //            print(error)
        //        }
        
        
        print(userid)
        self.topHeaderView.emailLabel.text = userid
        if myCreditFiles.count == 0 {
            MCCRequest.Instance.requestGet(userid: userid, requestType: credit_for_me, success: { (json : NSDictionary) in
                let requestQuery = "\(userid as String)_\(credit_for_me as String)"
                HUD.hide(afterDelay: 1.5)
                let resultKey = json.value(forKey: "key") as! String?
                let resultValue = json.value(forKey: "value") as? String
                
                if resultKey != requestQuery {
                    return;
                }
                let decryptresult = try? MCCCrypto.Instance.decryptMessage(encryptedMessage: resultValue!, encryptionKey: KEY)
                
                guard let jdata = decryptresult?.data(using: .utf8) else {
                    self.myCreditFiles = []
                    self.topHeaderView.dataSource = self.myCreditFiles
                    self.topHeaderView.collectionView.reloadData()
                    self.tableView.reloadData()
                    return;
                }
                let dictionary = try? JSONSerialization.jsonObject(with: jdata, options: .mutableLeaves)
                
                if dictionary != nil {
                    self.myCreditFiles = dictionary! as! [NSDictionary];
                }
                self.topHeaderView.dataSource = self.myCreditFiles
                self.topHeaderView.collectionView.reloadData()
                self.tableView.reloadData()
                
            }) { (error) in
                HUD.hide(afterDelay: 1.5)
            }
        }
        else{
            HUD.hide(afterDelay: 1.5)
        }
    }
    func alertView(mesage : String, placeholderMesage : String) {
        let alert = UIAlertController(title: mesage, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = placeholderMesage
            textField.keyboardType = .emailAddress
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
            if let name = alert.textFields?.first?.text {
                print("Your name: \(name)")
            }
        }))
        
        self.present(alert, animated: true)
    }
    func alertWithMesage(mesage : String) {
        let alert = UIAlertController(title: "Did you bring your towel?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if MCCSegueKeys.modalToInputEmailVC ==  segue.identifier {
            let inputEmailVC = segue.destination as! InputEmailVC
            inputEmailVC.delegate = self;
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0;
    }
    
    
    
}
