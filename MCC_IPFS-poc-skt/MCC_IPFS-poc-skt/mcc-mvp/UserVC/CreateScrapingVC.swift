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


public typealias successAction = (Any) -> Void
public typealias faildAction = (Any) -> Void

import Mcc


class CreateScrapingVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, CreateScrappingStepTVCellDelegate {
    
    
    
    let license: String = ""
    
    public var dataSource : [SCRData] = []
//    public  var selectedSource = [Int]()
    
    var convertDataSource = [Int]()
    
    
    @IBOutlet weak var tableView : UITableView!
    
    var creditData : Credit?
    var captcha: String?
    var firstTime: Bool = true
    var password: String = ""
    var mw24: Bool = false
    var ecar: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        OmniDocMgr.shared.progress[0] = 0
        OmniDocMgr.shared.stop[0] = 0
        OmniDocMgr.shared.rets = nil
        OmniDocMgr.shared.state = .STATE_PREPARING
        
        convertDataSource.removeAll()
        for _ in dataSource {
            convertDataSource.append(0)
        }
        
        
        self.navigationItem.hidesBackButton = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if firstTime {
            setCurrentProgress()
            firstTime = false
            DispatchQueue.main.async {
                let omniDocMgr = OmniDocMgr.shared
                omniDocMgr.CertRequestStructTermAndReset()
                let licenseRes: Int64 = Int64(omniDocMgr.CertRequestStructInit(count: Int32(omniDocMgr.params.count),
                                                                               
                                                                               license: self.license))
                if licenseRes == OmniDoc.FH_E_F_NO_LICENSE {
                    let alert = UIAlertController(title: "라이선스 오류",
                                                  message: "라이선스가 없습니다.",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인",
                                                  style: .default,
                                                  handler: { (action: UIAlertAction!) in
                                                    self.finish()
                    }))
                    self.present(alert, animated: true, completion: nil)
                } else if licenseRes == OmniDoc.FH_E_F_LICENSE_CHECK {
                    let alert = UIAlertController(title: "라이선스 오류",
                                                  message: "잘못된 라이선스 입니다.",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인",
                                                  style: .default,
                                                  handler: { (action: UIAlertAction!) in
                                                    self.finish()
                    }))
                    self.present(alert, animated: true, completion: nil)
                } else if licenseRes == OmniDoc.FH_E_F_LICENSE_EXPIRED {
                    let alert = UIAlertController(title: "만료된 라이선스",
                                                  message: "만료된 라이선스 입니다.",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인",
                                                  style: .default,
                                                  handler: { (action: UIAlertAction!) in
                                                    self.finish()
                    }))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.getNPKIPassword(retry: false)
                }
            }
        }
    }
    
    func getNPKIPassword(retry: Bool) {
        let alert = UIAlertController(title: "공인인증서 암호",
                                      message: retry ? "올바른 암호를 입력하여 주세요" : "공인인증서 암호를 입력하세요.",
                                      preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (textField) in
            textField.text = ""
            textField.isSecureTextEntry = true
        })
        alert.addAction(UIAlertAction(title: "확인",
                                      style: .default,
                                      handler: { (action: UIAlertAction!) in
                                        let input = alert.textFields![0].text!
                                        self.password = input
                                        
                                        let omniDocMgr = OmniDocMgr.shared
                                        let checkRes = omniDocMgr.CheckCertPassword(password: self.password)
                                        
                                        if checkRes == 0 {
                                            // 발급과정 진행
                                            self.mw24 = false
                                            self.ecar = false
                                            for index in 0 ..< omniDocMgr.params.count {
                                                
                                                if omniDocMgr.params[index].type == OmniDoc.FH_MW24_LOGIN {
                                                    self.mw24 = true
                                                    let ret = omniDocMgr.CertRequestStructSet(param: omniDocMgr.params[index])
                                                    if ret != 0 {
                                                        omniDocMgr.params[index].state = .ERROR
                                                        omniDocMgr.params[index].ret = Int(OmniDoc.FH_E_F_NO_LICENSE)
                                                    }
                                                } else if omniDocMgr.params[index].type == OmniDoc.FH_ECAR_DEUNGLOGWONBU {
                                                    self.ecar = true
                                                }
                                            }
                                            
                                            if self.mw24 {
                                                self.getCaptcha()
                                            } else {
                                                self.startIssue()
                                            }
                                        } else {
                                            self.getNPKIPassword(retry: true)
                                        }
        }))
        alert.addAction(UIAlertAction(title: "취소",
                                      style: .cancel,
                                      handler: { (action: UIAlertAction!) in
                                        self.finish()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func getCaptcha() {
        // Alert generation.
        let alert: UIAlertController = UIAlertController(title: "MCC", message: "공인인증서 비밀번호를 입력하세요.", preferredStyle: UIAlertControllerStyle.alert)
        
        // Cancel action generation.
        let CancelAction = UIAlertAction(title: "취소", style: UIAlertActionStyle.destructive) { (action: UIAlertAction!) -> Void in
            print("취소")
            DispatchQueue.main.async {
                self.finish()
            }
        }
        
        // OK action generation.
        let OkAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) { (action: UIAlertAction!) -> Void in
            print("확인")
            
            let tf1 : UITextField = alert.textFields![0]
            
            if tf1.text?.count == 0 {
                self.getCaptcha()
                return
            }
            self.captcha = tf1.text
            DispatchQueue.main.async {
                self.startIssue()
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
    
    func setCurrentProgress() {
        var progress = Float(OmniDocMgr.shared.GetProgress())
        if progress > 100 {
            progress = 100
        }
        
        if progress < 100 {
            let temp = String(format: "%02d%%", Int(progress))
            //            labelPercentage.text = temp
        } else {
            //            labelPercentage.text = "100%"
        }
    }
    
    func startIssue() {
        
        OmniDocMgr.shared.state = .STATE_ISSUING
        OmniDocMgr.shared.progress[0] = 0
        OmniDocMgr.shared.stop[0] = 0
        OmniDocMgr.shared.rets = nil
        
        let omniDocMgr = OmniDocMgr.shared
        for index in 0 ..< omniDocMgr.params.count {
            if omniDocMgr.params[index].type != OmniDoc.FH_MW24_LOGIN {
                let ret = omniDocMgr.CertRequestStructSet(param: omniDocMgr.params[index])
                if ret != 0 {
                    omniDocMgr.params[index].state = OmniDocParam.STATE.ERROR
                    omniDocMgr.params[index].ret = Int(OmniDoc.FH_E_F_NO_LICENSE)
                }
            }
        }
        
        tableView.reloadData()
        
        DispatchQueue.global().async {
            OmniDocMgr.shared.rets = OmniDocMgr.shared.CertIssue(password: self.password)
            if OmniDocMgr.shared.rets != nil {
                for i in 0 ..< OmniDocMgr.shared.rets!.count {
                    print("\(i) : \(OmniDocMgr.shared.rets![i])")
                }
            } else {
                print("res is nil")
            }
        }
        updateProgress()
    }
    
    func updateProgress() {
        setCurrentProgress()
        
        let omniDocMgr = OmniDocMgr.shared
        let paramsForTV = omniDocMgr.paramsForTableView
        
        for index in 0 ..< paramsForTV.count {
            if paramsForTV[index].state != .COMPLETED {
                let data = omniDocMgr.CertRequestStructGetCert(type: Int(paramsForTV[index].type))
                if data == nil {
                    let err: Int = omniDocMgr.CertRequestStructGetErr(type: Int(paramsForTV[index].type))
                    let temp: Int64 = Int64(err & 0x00ffffff)
                    if temp != 0 {
                        
                        var realErr: Bool = false
                        switch temp {
                        case OmniDoc.FH_E_N_SERVER_CONNECT: fallthrough
                        case OmniDoc.FH_E_N_AUTH_FAIL: fallthrough
                        case OmniDoc.FH_E_N_SERVICE_TIME: fallthrough
                        case OmniDoc.FH_E_N_APPLIED: fallthrough
                        case OmniDoc.FH_E_N_INFO_EXTRACT: fallthrough
                        case OmniDoc.FH_E_N_ESSENTIAL_INFO: fallthrough
                        case OmniDoc.FH_E_F_DECOMPRESS: fallthrough
                        case OmniDoc.FH_E_F_DECRYPT: fallthrough
                        case OmniDoc.FH_E_F_SM_CONNECT: fallthrough
                        case OmniDoc.FH_E_F_SSO: fallthrough
                        case OmniDoc.FH_E_F_PROTOCOL: fallthrough
                        case OmniDoc.FH_E_F_ENCRYPT: fallthrough
                        case OmniDoc.FH_E_F_MALFORMAT: fallthrough
                        case OmniDoc.FH_E_F_REGISTRATION: fallthrough
                        case OmniDoc.FH_E_F_ROLE_CHANGE: fallthrough
                        case OmniDoc.FH_E_F_TIME_OVER: fallthrough
                        case OmniDoc.FH_E_F_MEM_ALLOC: fallthrough
                        case OmniDoc.FH_E_F_CONNECT_INIT_FAIL: fallthrough
                        case OmniDoc.FH_E_F_CERTTYPE_MISMATCH: fallthrough
                        case OmniDoc.FH_E_F_CERT_NOT_EXIST: fallthrough
                        case OmniDoc.FH_E_F_WRONG_ADDRESS: fallthrough
                        case OmniDoc.FH_E_F_LICENSE_CHECK: fallthrough
                        case OmniDoc.FH_E_F_NO_LICENSE: fallthrough
                        case OmniDoc.FH_E_F_LICENSE_EXPIRED:
                            realErr = true
                        default:
                            realErr = false
                        }
                        
                        if realErr {
                            if  OmniDocMgr.shared.state == .STATE_ISSUING &&
                                (paramsForTV[index].type & 0xff000000 == OmniDoc.FH_4INSU ||
                                    paramsForTV[index].type & 0xff000000 == OmniDoc.FH_SCF) {
                                // do nothing
                            } else {
                                paramsForTV[index].ret = err
                                paramsForTV[index].state = .ERROR
                                paramsForTV[index].issue = ""
                                
                                DispatchQueue.main.async {
                                    self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)],
                                                              with: UITableViewRowAnimation.none)
                                }
                            }
                        }
                    }
                } else {
                    var issue = String(data: data!,
                                       encoding: .utf8)
                    if issue == nil {
                        issue = String(data: data!,
                                       encoding: String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(0x0422)))
                    }
                    
                    if issue != nil && issue != "" {
                        paramsForTV[index].state = .COMPLETED
                        paramsForTV[index].issue = issue ?? ""
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)],
                                                      with: UITableViewRowAnimation.none)
                        }
                    }
                }
            }
        }
        
        
        if OmniDocMgr.shared.rets == nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.updateProgress()
            }
        } else {
            //            labelPercentage.text = "100%"
            omniDocMgr.state = .STATE_END
            
            if omniDocMgr.stop[0] == 0 {
                for index in 0 ..< paramsForTV.count {
                    if paramsForTV[index].state != .COMPLETED {
                        let data = omniDocMgr.CertRequestStructGetCert(type: Int(paramsForTV[index].type))
                        if data == nil {
                            let err: Int = omniDocMgr.CertRequestStructGetErr(type: Int(paramsForTV[index].type))
                            paramsForTV[index].ret = err
                            paramsForTV[index].state = .ERROR
                            paramsForTV[index].issue = ""
                        } else {
                            var issue = String(data: data!, encoding: .utf8)
                            if issue == nil {
                                issue = String(data: data!, encoding: String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(0x0422)))
                            }
                            
                            if issue != nil && issue != "" {
                                paramsForTV[index].state = .COMPLETED
                                paramsForTV[index].issue = issue!
                            } else {
                                paramsForTV[index].ret = Int(Int64(OmniDoc.FH_E_N_INFO_EXTRACT))
                                paramsForTV[index].state = .ERROR
                                paramsForTV[index].issue = ""
                            }
                        }
                        DispatchQueue.main.async {
                            self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)],
                                                      with: UITableViewRowAnimation.none)
                        }
                    }
                }
                

                self.uploadIPFS()
                
//                self.convertFinc()
                
//                let alert = UIAlertController(title: "문서 발급 완료",
//                                              message: "문서 발급이 완료 되었습니다.",
//                                              preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "확인",
//                                              style: .default,
//                                              handler: nil))
//                self.present(alert, animated: true, completion: nil)
                
            } else {
                for index in 0 ..< paramsForTV.count {
                    paramsForTV[index].state = .STOP
                }
                self.tableView.reloadData()
                
                let alert = UIAlertController(title: "문서 발급 취소",
                                              message: "문서 발급이 취소 되었습니다.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인",
                                              style: .default,
                                              handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
            //            self.buttonCancel.setTitle("나가기", for: .normal)
            //            self.buttonCancelSmall.setTitle("나가기", for: .normal)
        }
    }
    
    func getDocName(param: OmniDocParam) -> String {
        switch param.type {
        case OmniDoc.FH_MW24_JUMIND:
            return "민원24 주민등록등본"
        case OmniDoc.FH_MW24_JUMINC:
            return "민원24 주민등록초본"
        case OmniDoc.FH_SCF_GIBON:
            return "대법원 전자가족관계 기본증명서"
        case OmniDoc.FH_SCF_GAJOK:
            return "대법원 전자가족관계 가족관계증명서"
        case OmniDoc.FH_SCF_HONIN:
            return "대법원 전자가족관계 혼인증명서"
        case OmniDoc.FH_NTS_SODEUK:
            return "국세청 소득증명서"
        case OmniDoc.FH_NTS_SAUPJA:
            return "국세청 사업자등록증명원"
        case OmniDoc.FH_NTS_SODEUK_BONGGUP:
            return "국세청 소득금액증명서(봉급생활자)"
        case OmniDoc.FH_NTS_SODEUK_SAUP:
            return "국세청 소득금액증명서(사업자)"
        case OmniDoc.FH_NTS_SODEUK_JONGHAP:
            return "국세청 소득금액증명서(종합소득)"
        case OmniDoc.FH_NTS_VAT_GWASE:
            return "국세청 부가가치세 과세표준증명"
        case OmniDoc.FH_NPS_PENSION:
            return "국민연금 연금지급내역증명서"
        case OmniDoc.FH_NHIS_JAGEOK:
            return "국민건강보험 자격득실확인서"
        case OmniDoc.FH_NHIS_NABBU:
            return "국민건강보험 납부확인서"
        case OmniDoc.FH_NHIS_WANNAB:
            return "국민건강보험 완납확인서"
        case OmniDoc.FH_4INSU_GAIB:
            return "4대보험 가입내역확인서"
        case OmniDoc.FH_ECAR_DEUNGLOGWONBU:
            return "국토교통부 자동차등록원부"
        default:
            return "알수없음"
        }
    }
    
    func getAuthName(param: OmniDocParam) -> String {
        let auth: Int64 = param.type & 0xff000000
        switch auth {
        case OmniDoc.FH_SCF:
            return "대법원"
        case OmniDoc.FH_MW24:
            return "민원24"
        case OmniDoc.FH_NTS:
            return "국세청"
        case OmniDoc.FH_NPS:
            return "국민연금"
        case OmniDoc.FH_NHIS:
            return "국민건강보험"
        case OmniDoc.FH_4INSU:
            return "4대보험"
        case OmniDoc.FH_ECAR:
            return "국토교통부"
        default:
            return "알수없음"
        }
    }
    
    @IBAction func onTouchUpInsideCancel(_ sender: Any) {
        checkToFinish()
    }
    
    func checkToFinish() {
        if OmniDocMgr.shared.state == .STATE_END  || OmniDocMgr.shared.stop[0] != 0 {
            if OmniDocMgr.shared.state == .STATE_END {
                self.finish()
            } else {
                // stopped 이지만 finished 되지 않은 상태에선 좀더 기다린다.
            }
        } else {
            let alert = UIAlertController(title: "문서 발급 중단",
                                          message: "진행 중인 발급을 중단하시겠습니까?",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인",
                                          style: .default,
                                          handler: { (action: UIAlertAction!) in
                                            OmniDocMgr.shared.CertStop()
                                            //                                            self.buttonCancel.setTitle("나가기", for: .normal)
                                            //                                            self.buttonCancelSmall.setTitle("나가기", for: .normal)
            }))
            alert.addAction(UIAlertAction(title: "취소",
                                          style: .cancel,
                                          handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func finish() {
        OmniDocMgr.shared.state = .STATE_END
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTouchBackAction() {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func didTouchCloseAction() {
        self.navigationController?.dismiss(animated: true, completion: {
            
        })
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreateScrappingStepTVCell", for: indexPath) as! CreateScrappingStepTVCell
        cell.selectedBackgroundView = UIView.init(frame: CGRect(x: 0, y: 0, width: 10, height: 10), backgroundColor: UIColor.clear)
        let data = self.dataSource[indexPath.row] as SCRData
        cell.titleLabel?.text = data.string()
        cell.delegate = self
        
        let param: OmniDocParam = OmniDocMgr.shared.paramsForTableView[indexPath.item]
        
        switch param.state {
        case .PROCESSING:
            //            cell.normalStat()
            cell.runningScrapping()
            break
        case .ERROR:
            cell.normalStat()
            break
        case .COMPLETED:
            cell.scrappingComplete()
            break
        case .STOP:
            cell.stopScrapping()
            break
        }
        //
        //
        //        let index = selectedSource[indexPath.row]
        //        if index == 0 {
        //            cell.normalStat()
        //        } else if index == 1 {
        //            cell.runningScrapping()
        //        } else if index == 2 {
        //            cell.scrappingComplete()
        //        }
        return cell;
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        if selectedSource[indexPath.row] == 0 {
//            selectedSource[indexPath.row] = 1
//        } else if selectedSource[indexPath.row] == 1 {
//            selectedSource[indexPath.row] = 2
//        } else if selectedSource[indexPath.row] == 2 {
//            selectedSource[indexPath.row] = 0
//        }
//        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    
    func CreateScrappingStepTVCellDidSelectDetail(cell: CreateScrappingStepTVCell) {
        let indexPath = self.tableView.indexPath(for: cell)
        
        let param: OmniDocParam = OmniDocMgr.shared.paramsForTableView[indexPath!.item]
        //        print(param.op1)
        //        print(param.op2)
        //        print(param.op3)
        //        print(param.op4)
        //        print(param.op5)
        //        print(param.op6)
        //        print(param.op7)
        //        print(param.op8)
        //        print(param.op9)
        //        print(param.op10)
        print(param.lang)
        print(param.issue)
    }
    func convertFinc() {
        
        let index = 0
        
//        for r in convertDataSource as [Int] {
//            if r == 0 {
//                index += 1;
//                break;
//            }
//            index += 1;
//        }
        
        let param: OmniDocParam = OmniDocMgr.shared.paramsForTableView[index]
        let scrDATA = self.dataSource[index]
        self.requestFinc(requetIndex: 0, docId: scrDATA.docId(), omniDocParam: param, successAction: nil, failedAction: nil)
    }
    func requestFinc(requetIndex : Int, docId : String,omniDocParam : OmniDocParam,successAction : successAction? , failedAction : faildAction?) {
        HUD.show(.labeledRotatingImage(image: UIImage(named: "mcc-loading"), title: nil, subtitle: nil))
        
        
        var listparameter = [String:Any]()
        
        var drmDataParameter = [String:Any]()
        
        var parameter : [String:String] = [:]
        
        var errorCode : String
        var errorMessage : String
        if omniDocParam.issue.isEmpty == false && omniDocParam.issue.count != 0 {
            errorCode = "000"
            errorMessage = "정상처리"
        } else {
            errorCode = "001"
            errorMessage = "에러"
        }
  
        print("omniDocParam.issue[\(omniDocParam.issue)]")
        
        parameter.append(docId, forKey: "doc")
        parameter.append(omniDocParam.issue.urlEncoded!, forKey: "data")
        parameter.append("1", forKey: "line")
        
        listparameter.append([parameter], forKey: "list")
        listparameter.append(errorCode, forKey: "errCode")
        listparameter.append(errorMessage, forKey: "errMsg")
        listparameter.append("momnidoc", forKey: "txCode")
        listparameter.append("1", forKey: "list_cnt")
        
        
        
        drmDataParameter.append(listparameter, forKey: "drmData")
//        MCCRequest.Instance.requestFinc(parameter: listparameter, success: { (json) in
        
//        let jsonData = try? JSONSerialization.data(withJSONObject: listparameter, options: [])
//        let jsonString = String(data: jsonData!, encoding: .utf8)
        
        MCCRequest.Instance.requestFinc(parameters: drmDataParameter, success: { (json) in
            
            self.convertDataSource[requetIndex] = 1
            
            var completedCount = 0
            for r in self.convertDataSource {
                if r != 0 {
                    completedCount += 1;
                }
            }
            
            if self.convertDataSource.count == completedCount {
                DispatchQueue.main.async {
                    HUD.hide(afterDelay: 0.1, completion: { (completed) in
                        self.showAlert(message: "데이터 등록이 완료되었습니다.", actionMesage: "확인", actionStyle: UIAlertActionStyle.default, actionBlock: {
                            self.navigationController?.dismiss(animated: true, completion: {});
                        })
                    })
                }
            }
            else{
                self.convertFinc()
            }
        }) { (error) in
            HUD.hide(afterDelay: 0.1, completion: { (completed) in
                HUD.hide(afterDelay: 0.1, completion: { (completed) in
                    self.showAlert(message: "데이터가 등록에 실패 했습니다. 다시 시도하려면 확인을 눌러주세요.", actionMesage: "확인", actionStyle: UIAlertActionStyle.default, actionBlock: {
                        self.uploadIPFS()
                    })
                    return
                })
            })
        }
    }
    func uploadIPFS() {
        
        var parameters = [String:String]()
        var index = 0
        for data in dataSource {
            let param: OmniDocParam = OmniDocMgr.shared.paramsForTableView[index]
            if param.state == .COMPLETED {
                parameters.append(param.issue, forKey: data.docId())
            }
            index += 1
        }
        let jsonData = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        
        let error: NSErrorPointer = nil
        let string2 =  MccEncrypt(creditData?.owneraddress, jsonString?.urlEncoded, error)
        
        
        if string2 == nil || (string2?.count == 0)  {
            return;
        }
        
        if error != nil {
            return;
        }
        
        HUD.show(.labeledRotatingImage(image: UIImage(named: "mcc-loading"), title: nil, subtitle: nil))
        
        let date:Date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        let dateString = dateFormatter.string(from: date)
        
        
        var parameter : [String:String] = [:]
        parameter.append("transaction", forKey: "ccId")
        parameter.append("transactionCreditIPFS", forKey: "ccFnc")
        parameter.append((creditData?.owneraddress)!, forKey: "param1")
        parameter.append(UserDefaults.standard.string(forKey: MCCDefault.kWalletAddress)!, forKey: "param2")
        parameter.append(string2!, forKey: "param3")
        parameter.append(dateString, forKey: "param4")
        parameter.append((creditData?.creditid)!, forKey: "param5")
        
        
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
                DispatchQueue.main.async {
                    self.showAlert(message: "데이터가 등록에 실패 했습니다. 다시 시도하려면 확인을 눌러주세요.", actionMesage: "확인", actionStyle: UIAlertActionStyle.default, actionBlock: {
                        self.uploadIPFS()
                    })
                    return
                }
            })
        }
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
