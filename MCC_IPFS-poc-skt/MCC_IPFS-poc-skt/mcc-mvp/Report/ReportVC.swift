//
//  ReportVC.swift
//  mcc-mvp
//
//  Created by JIK on 2018. 9. 30..
//  Copyright © 2018년 jakejeong. All rights reserved.
//

import UIKit

import Mcc

import Alamofire
import PKHUD
import BFKit
import STPopup
import SWXMLHash

struct Report : Decodable {
    let key : String
    let value : String
    init(json : Dictionary<String,Any>) {
        self.key = (json["key"] as? String)!
        self.value = (json["value"] as? String)!
    }
    init(key : String, value : String) {
        self.key = key
        self.value = value
    }
}

class ReportVC: MCCDefaultVC, UITableViewDelegate, UITableViewDataSource {

    var dataSource = [Report]()
    var transactionData : String!
    var transaction : Transaction!
    
    var typeList = ["NTS_SODEUK_BONGGUP", "NHIS_JAGEOK", "ECAR_WONBU", "INS4_GAIB"]
    
    @IBOutlet weak var tableView : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let leftBarButton = UIBarButtonItem(image: UIImage(named: "img-back"), style: UIBarButtonItemStyle.done, target: self, action: #selector(didTouchBackAction))
        leftBarButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        // Do any additional setup after loading the view.
//        print( "transactionData : " + transactionData )
        
        if transaction.datakey.count > 50 {
            self.decryptParsing(targetString: transaction.datakey)
        } else if transaction != nil {
            self.requestGetIPFSData(success: {
                self.tableView.reloadData()
            }, transaction: transaction)
        }
    }

    func decryptParsing(targetString : String) {
        let password : String = UserDefaults.standard.string(forKey: MCCDefault.kWalletPassword)!
        if !password.isEmpty {
            print("MCCDefault.kWalletPassword - \(password)")
        }
        
        let error3: NSErrorPointer = nil
        let decryptString = MccDecrypt(password, targetString, error3)
        
        print("decryptString :  - \(String(describing: decryptString))")
        
        if decryptString != nil{
            var findIndex = 0
            for str in typeList {
                if (decryptString?.contains(str))! {
                    findIndex += 1
                }
            }
            if findIndex == 0 && (decryptString?.contains("xml"))! {
                if (decryptString?.contains("소득금액증명"))! {
                    self.parsing소득(souceData: decryptString!)
                    self.tableView.reloadData()
                }
                else if (decryptString?.contains("</dataset></root>"))! {
                    self.parsing건강(souceData: decryptString!)
                    self.tableView.reloadData()
                }
            }
            else if findIndex == 0  && (decryptString?.contains("</CdocAppl>\n</list>"))! {
                self.parsing4대보험(souceData:decryptString!)
                self.tableView.reloadData()
            }
            else if findIndex == 0  && (decryptString?.contains("<basic_info name='basic_info'>"))! {
                self.parsingCar(souceData: decryptString!)
                self.tableView.reloadData()
            }
            else if findIndex != 0 {
                let decodeString = decryptString?.removingPercentEncoding
                let data = decodeString?.data(using: .utf8)
                do{
                    let json =  try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                    print(json)
                    let jsonDic = json as! Dictionary<String,Any>
                    for strKey in jsonDic.keys {
                        let values = jsonDic[strKey] as! String
                        if values.contains("<basic_info name='basic_info'>") {
                            self.parsingCar(souceData: jsonDic[strKey] as! String)
                        } else if (values.contains("xml")) {
                            if (values.contains("소득금액증명")) {
                                self.parsing소득(souceData: values)
                            }
                            else if (values.contains("</dataset></root>")) {
                                self.parsing건강(souceData: values)
                            }
                        } else if (values.contains("</CdocAppl>\n</list>")) {
                            self.parsing4대보험(souceData:values)
                        }
                    }
                }
                catch let error{
                    print(error.localizedDescription)
                }
                self.tableView.reloadData()
            }
        }
    }
    func parsing소득(souceData : String) {
        self.dataSource.append(Report(key: "▶︎ 소득금액증명", value: ""))
        let xml2 = SWXMLHash.parse(souceData)
        let companyNameEng : String? = xml2["root"]["incAmtCerDVOList"]["rows"][0]["lvyRperEnglTnmNm"].element?.text
        let sdAmount : String? = xml2["root"]["incAmtCerDVOList"]["rows"][0]["txtnTrgtSnwAmt"].element?.text
        let companyNameKor : String? = xml2["root"]["incAmtCerDVOList"]["rows"][0]["lvyRperTnmNm"].element?.text
        let attrYr : String? = xml2["root"]["incAmtCerDVOList"]["rows"][0]["attrYr"].element?.text
        let lvyRperNo : String? = xml2["root"]["incAmtCerDVOList"]["rows"][0]["lvyRperNo"].element?.text
        
        let cvaKndNm = xml2["root"]["cerpBscInfrDVO"]["cvaChrgOgzEnglNm"]["cvaChrgOgzEnglNm"]["cvaKndNm"].element?.text
        let cvarLdAdr = xml2["root"]["cerpBscInfrDVO"]["cvaChrgOgzEnglNm"]["cvaChrgOgzEnglNm"]["cvarLdAdr"].element?.text
        
        self.dataSource.append(Report(key: "  - 회사명(한글)", value: companyNameKor ?? ""))
        self.dataSource.append(Report(key: "  - 회사명(영어)", value: companyNameEng ?? ""))
        self.dataSource.append(Report(key: "  - 사업자등록번호", value: lvyRperNo ?? ""))
//        self.dataSource.append(Report(key: "  - 문서 종류", value: cvaKndNm ?? ""))
        self.dataSource.append(Report(key: "  - 대상년도", value: attrYr ?? ""))
//        self.dataSource.append(Report(key: "  - 소득금액", value: sdAmount ?? ""))
        self.dataSource.append(Report(key: "  - 주소지", value: cvarLdAdr ?? ""))
    }
    func parsingCar(souceData : String) {
        self.dataSource.append(Report(key: "▶︎ 자동차보유현황", value: ""))
        let xml4 = SWXMLHash.parse(souceData)
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
        

        self.dataSource.append(Report(key: "  - 자동차등록번호", value: doc_cnfirm_no!))
        self.dataSource.append(Report(key: "  - 차량번호", value: VHRNO!))
        self.dataSource.append(Report(key: "  - 차량 사이즈", value: VHCTY_ASORT_NM!))
        self.dataSource.append(Report(key: "  - 차량 이름", value: CNM!))
        self.dataSource.append(Report(key: "  - 차량 색상", value: COLOR_NM!))
        self.dataSource.append(Report(key: "  - 차량 목적", value: PRPOS_SE_NM!))
        self.dataSource.append(Report(key: "  - 차량 구매날짜", value: FRST_REGIST_DE!))
        self.dataSource.append(Report(key: "  - 차량 현재주소", value: ADRES!))
        self.dataSource.append(Report(key: "  - 소유자", value: MBER_NM!))
        self.dataSource.append(Report(key: "  - 소유자 주민번호", value: MBER_SE_NO!))
    }
    func parsing4대보험(souceData : String) {
        let xml3 = SWXMLHash.parse(souceData)
        
        self.dataSource.append(Report(key: "▶︎ 4대보험가입확인", value: ""))
        for record in xml3["list"]["CdocAppl"].all {
            
            let joinRrno : String? = record["joinRrno"].element?.text
            let bslcName : String? = record["bslcName"].element?.text
            let name : String? = record["name"].element?.text
            let issuNo : String? = record["issuNo"].element?.text
            let joinKind : String? = record["joinKind"].element?.text
            let procOrgCd : String? = record["procOrgCd"].element?.text
            
            
            self.dataSource.append(Report(key: " ⦿\(self.typeToString(text: procOrgCd!))", value: ""))
            self.dataSource.append(Report(key: "  - 회사이름", value: bslcName!))
            self.dataSource.append(Report(key: "  - 사업자번호", value: issuNo!))
            self.dataSource.append(Report(key: "  - 가입형태", value: joinKind!))
            self.dataSource.append(Report(key: "  - 본인성명", value: name!))
            self.dataSource.append(Report(key: "  - 주민등록번호", value: joinRrno!))
            
        }
    }
    func parsing건강(souceData : String) {
        let xml = SWXMLHash.parse(souceData)
        //        let count = xml["root"]["dataset"]["record"].all.count
        let today = Date()
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "YYYYMMdd"
        //        print(dateFormatterPrint.string(from: today))
        var company = ""
        var userName = ""
        var joinType = ""
        var startDate = ""
        var daysum = 0
        var dayThisCompany = 0
        var flag = false
        self.dataSource.append(Report(key: "▶︎ 건강보험자격확인", value: ""))
        for record in xml["root"]["dataset"]["record"].all {
            guard let type = record["OUT03"].element?.text, type == "직장가입자" else {
                continue
            }
            let dateOut5 = record["OUT05"].element?.text ?? nil
            var dateOut6 = record["OUT06"].element?.text ?? nil
            if dateOut6 == "" {
                flag = true
                dateOut6 = dateFormatterPrint.string(from: today)
                if company.count == 0 {
                    company = (record["OUT04"].element?.text ?? nil)!
                }
                if joinType.count == 0 {
                    joinType = (record["OUT03"].element?.text ?? nil)!
                }
                if userName.count == 0 {
                    userName = (record["OUT01"].element?.text ?? nil)!
                }
                if startDate.count == 0 {
                    startDate = (record["OUT05"].element?.text ?? nil)!
                }
            }
            let betweendate = (Date(parse: dateOut5!, format: "YYYYMMdd", locale: "ko_KR")?.daysBetween(Date(parse: dateOut6!, format: "YYYYMMdd", locale: "ko_KR")!))!
            if flag {
                flag = false
                dayThisCompany = betweendate
            }
            daysum = daysum + betweendate
            
        }
        let dayOffset = DateComponents(day: daysum)
        if userName.count != 0 {
            self.dataSource.append(Report(key: "  - 이름", value: userName))
        }
        if company.count != 0 {
            self.dataSource.append(Report(key: "  - 회사", value: company))
        }
        if joinType.count != 0 {
            self.dataSource.append(Report(key: "  - 가입구분", value: joinType))
        }
        
        if startDate.count != 0 {
            self.dataSource.append(Report(key: "  - 가입일", value: startDate))
        }
        let dayOffsetThisCompany = DateComponents(day: dayThisCompany)
        if let d0 = Calendar.current.date(byAdding: dayOffsetThisCompany, to: today) {
            //            print("result - !!" , dateFormatterPrint.string(from: d100))
            do {
                let formatter = DateComponentsFormatter()
                formatter.allowedUnits = [.year, .month, .day]
                formatter.unitsStyle = .full   // 이유는 모르겠으나 꼭 필요하다!
                formatter.calendar?.locale = Locale(identifier:"ko_KR")
                //                    .locale = Locale(identifier:"ko_KR")
                if let daysString = formatter.string(from: today, to: d0) {
                    //                                print("\(daysString) 근무하셨습니다.") // 2년 4개월 14일
                    self.dataSource.append(Report(key: "  현재근무회사 재직기간", value: daysString))
                }
            }
        }
        if let d100 = Calendar.current.date(byAdding: dayOffset, to: today) {
            //            print("result - !!" , dateFormatterPrint.string(from: d100))
            do {
                let formatter = DateComponentsFormatter()
                formatter.allowedUnits = [.year, .month, .day]
                formatter.unitsStyle = .full   // 이유는 모르겠으나 꼭 필요하다!
                formatter.calendar?.locale = Locale(identifier:"ko_KR")
                //                    .locale = Locale(identifier:"ko_KR")
                if let daysString = formatter.string(from: today, to: d100) {
                    //                                print("\(daysString) 근무하셨습니다.") // 2년 4개월 14일
                    self.dataSource.append(Report(key: "  총 사회경력(근무기간)", value: daysString))
                }
            }
        }
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
    
    func requestGetIPFSData(success : alertAction?, transaction : Transaction) {
        HUD.show(.labeledRotatingImage(image: UIImage(named: "mcc-loading"), title: nil, subtitle: nil))
//        let userAddress = UserDefaults.standard.string(forKey: MCCDefault.kWalletAddress)
        
        var parameter : [String:String] = [:]
        parameter.append("transaction", forKey: "ccId")
        parameter.append("queryCreditIPFS", forKey: "ccFnc")
        parameter.append(transaction.transactionkey, forKey: "param1")
        
        print(parameter)
        
        MCCRequest.Instance.requestQueryString(parameter: parameter, success: { (result) in
            print(result as Any)
            HUD.hide()
            self.decryptParsing(targetString: result as! String)
            
        }) { (error) in
            HUD.hide(afterDelay: 0.1, completion: { (completed) in
                print(error)
                self.showAlert(message: "데이터제공자의 의해 데이터가 삭제되었거나, 기간이 만료된것 같습니다. 데이터를 확인할수 없습니다.", actionMesage: "닫기", actionStyle: .default, actionBlock: {
                    self.navigationController?.popViewController(animated: true)
                })
            })
        }
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
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "ReportTVCell", for: indexPath) as! ReportTVCell
        let data = self.dataSource[indexPath.row]
        cell.titleLabel.text = data.key
        cell.valueLabel.text = data.value
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
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
