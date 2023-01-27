//
//  JoinDetailVC.swift
//  mcc-mvp
//
//  Created by jakejeong on 2018. 9. 19..
//  Copyright © 2018년 jakejeong. All rights reserved.
//

import UIKit

import STPopup

class JoinDetailVC: UIViewController, SelectNPKIDelegate {

    @IBOutlet weak var nameBaseView : UIView!
    @IBOutlet weak var nameTF : UITextField!
    
    @IBOutlet weak var rrnFirstBaseView : UIView!
    @IBOutlet weak var rrnFirstTF : UITextField!
    
    @IBOutlet weak var rrnLastBaseView : UIView!
    @IBOutlet weak var rrnLastTF : UITextField!
    
    @IBOutlet weak var carNumBaseView : UIView!
    @IBOutlet weak var carNumTF : UITextField!
    
    @IBOutlet weak var certificateBtn : UIButton!
    @IBOutlet weak var doneBtn : UIButton!
    
    var certificatePath : String?
    var arrNPKI = Array<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let viewArray = [self.nameBaseView, self.rrnFirstBaseView, self.rrnLastBaseView, self.carNumBaseView]
        if UserDefaults.standard.object(forKey: MCCDefault.kUserAge) == nil  {
            UserDefaults.standard.set(35, forKey: MCCDefault.kUserAge)
        }
        
        if UserDefaults.standard.object(forKey: MCCDefault.kUserGender) == nil  {
            UserDefaults.standard.set(0, forKey: MCCDefault.kUserGender)
        }
        
        if UserDefaults.standard.object(forKey: MCCDefault.kUserLiveLocation) == nil  {
            UserDefaults.standard.set(0, forKey: MCCDefault.kUserLiveLocation)
        }
        
        let userRRN01 = UserDefaults.standard.string(forKey: MCCDefault.kUserRRN01)
        if userRRN01?.count != 0 { self.rrnFirstTF.text = userRRN01 }
        
        let userRRN02 = UserDefaults.standard.string(forKey: MCCDefault.kUserRRN02)
        if userRRN02?.count != 0 { self.rrnLastTF.text = userRRN02 }
        
        let userName = UserDefaults.standard.string(forKey: MCCDefault.kUserName)
        if userName?.count != 0 { self.nameTF.text = userName }
        
        let userCarNum = UserDefaults.standard.string(forKey: MCCDefault.kUserCarNum)
        if userCarNum?.count != 0 { self.carNumTF.text = userCarNum }
        
        let userNPKIPath = UserDefaults.standard.string(forKey: MCCDefault.kUserNPKIPATH)
        if userNPKIPath?.count != 0 { certificatePath = userNPKIPath; self.certificateBtn.setTitle(userNPKIPath, for: .normal) }
        
        for v in viewArray {
            v?.layer.cornerRadius = 10
            v?.clipsToBounds = true
            v?.borderWidth = 0.5
            v?.borderColor = UIColor.lightGray
        }
        
        getNPKIInfo()
        updateCertificateInfo()
        self.certificateBtn.titleLabel?.numberOfLines = 2
        self.certificateBtn.titleLabel?.textAlignment = .center
        
        self.navigationItem.hidesBackButton = true
        

        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func validateData() ->String? {
        if (nameTF.text?.count)!  < 2 {return "성명을 제대로 입력해야합니다."}
        if rrnFirstTF.text?.count != 6 {return "주민등록번호 앞 6자리를 입력해야합니다."}
        if rrnLastTF.text?.count != 7 {return "주민등록번호 뒷 7자리를 입력해야합니다."}
        if (carNumTF.text?.count)! <= 4 {return "차량번호를 입력해야합니다."}
        if certificatePath?.count == 0 {return "인증서 경로찾기를 클릭해주세요"}
        return nil
    }
    func updateCertificateInfo() {
        if certificatePath == nil {
            self.certificateBtn .setTitle("인증서 경로 찾기\n(선택된 공인인증서 없음)", for: .normal)
        } else {
            let fileMgr = FileManager.default
            let documentDir = try! fileMgr.url(for: .documentDirectory,
                                               in: .userDomainMask,
                                               appropriateFor: nil,
                                               create: true)
            let npkiDir = documentDir.appendingPathComponent(certificatePath!,
                                                             isDirectory: true)
            
            let signDer = npkiDir.appendingPathComponent("signCert.der")
            let signKey = npkiDir.appendingPathComponent("signPri.key")
            
            if fileMgr.fileExists(atPath: signDer.path) &&
                fileMgr.fileExists(atPath: signKey.path) {
                self.certificateBtn .setTitle("인증서 경로 찾기\n\(certificatePath ?? "")", for: .normal)
            } else {
                certificatePath = nil
                self.certificateBtn .setTitle("인증서 경로 찾기\n(선택된 공인인증서 없음)", for: .normal)
            }
        }
    }
    func getNPKIInfo() {
        arrNPKI.removeAll()
        let fileMgr = FileManager.default
        let documentDir = try! fileMgr.url(for: .documentDirectory,
                                           in: .userDomainMask,
                                           appropriateFor: nil,
                                           create: true)
        let npkiURL = documentDir.appendingPathComponent("NPKI",
                                                         isDirectory: true)
        if fileMgr.fileExists(atPath: npkiURL.path) {
            let certs = ["CrossCert/USER",
                         "KICA/USER",
                         "KISA/USER",
                         "NCASign/USER",
                         "SignKorea/USER",
                         "TradeSign/USER",
                         "yessign/USER"]
            for index in 0 ..< certs.count {
                let cert = certs[index]
                let certURL = npkiURL.appendingPathComponent(cert, isDirectory: true)
                if fileMgr.fileExists(atPath: certURL.path) {
                    do {
                        let dirList = try fileMgr.contentsOfDirectory(atPath: certURL.path)
                        for dir in dirList {
                            let finalURL = certURL.appendingPathComponent(dir, isDirectory: true)
                            
                            let signDer = finalURL.appendingPathComponent("signCert.der")
                            let signKey = finalURL.appendingPathComponent("signPri.key")
                            
                            if fileMgr.fileExists(atPath: signDer.path) &&
                                fileMgr.fileExists(atPath: signKey.path) {
                                let relPath: String = "NPKI/\(cert)/\(dir)"
                                arrNPKI.append(relPath)
                            }
                        }
                    } catch {
                        // do nothing...
                    }
                }
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
    
    @IBAction func didTouchFindNPKIPathAction() {
        getNPKIInfo()
        updateCertificateInfo()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if self.parent != nil{
                PopupHelper.showPopupFromStoryBoard(style: .bottomSheet, storyBoard: "Main", popupName: "SelectNPKIVC", viewController: self.parent!, delegate: self, blurBackground: true, size: CGSize(width: UIScreen.screenWidth, height: UIScreen.screenHeight/2), sender: ["list":self.arrNPKI])
            }
        }
        
        
//
//
//        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//        let selectNPKIViewController = storyboard.instantiateViewController(withIdentifier: "SelectNPKI") as! SelectNPKIViewController
////        selectNPKIViewController.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
//        selectNPKIViewController.arrNPKI = arrNPKI
//        selectNPKIViewController.delegate = self
//        self.present(selectNPKIViewController, animated: true, completion: nil)
    }
    
    
    @IBAction func didTouchSaveDoneAction() {
        let result = self.validateData()
        if  result != nil {
            self.showAlert(message: result!, actionMesage: "확인", actionStyle: .destructive, actionBlock: nil)
            return;
        }
        
        UserDefaults.standard.set(self.rrnFirstTF.text, forKey: MCCDefault.kUserRRN01)
        UserDefaults.standard.set(self.rrnLastTF.text, forKey: MCCDefault.kUserRRN02)
        UserDefaults.standard.set(self.nameTF.text, forKey: MCCDefault.kUserName)
        UserDefaults.standard.set(self.carNumTF.text, forKey: MCCDefault.kUserCarNum)
        
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func onSelectNPKI(selected: Int) {
        certificatePath = arrNPKI[selected]
        UserDefaults.standard.set(certificatePath, forKey: MCCDefault.kUserNPKIPATH)
        updateCertificateInfo()
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
