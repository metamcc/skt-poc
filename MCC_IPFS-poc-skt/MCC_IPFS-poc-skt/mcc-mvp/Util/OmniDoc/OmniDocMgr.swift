//
//  OmniDocMgr.swift
//  OmniDocPT
//
//  Created by Jinryul.Kim on 2017. 5. 2..
//  Copyright © 2017년 FlyHigh. All rights reserved.
//  Updated by Jinryul.Kim on 2018. 08. 17.. ver 0.1.7
//

import Foundation


final class OmniDocMgr {
    
    private init() {
        initialize()
    }
    static let shared = OmniDocMgr()
    
    var handle: UnsafeMutableRawPointer? = nil
    var count: Int32 = -1
    var progress = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
    var stop = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
    
    var omniDoc: FHOmniDoc? = nil
    
    var params = Array<OmniDocParam>()
    var paramsForTableView = Array<OmniDocParam>()
    var rets: [Int]?
    var npkiPath: String?
    var name: String?
    var rrn1: String?
    var rrn2: String?
    
    enum IssueState: Int {
        case STATE_PREPARING = 0,
        STATE_ISSUING,
        STATE_SENDING,
        STATE_END,
        STATE_ERROR
    }
    
    var state: IssueState = .STATE_END
    
    func getOmniDoc() -> FHOmniDoc {
        if omniDoc == nil {
            omniDoc = FHOmniDoc()
        }
        return omniDoc!
    }
    
    func getNPKIPath() -> String? {
        if npkiPath != nil {
            let fileMgr = FileManager.default
            let documentDir = try! fileMgr.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let npkiURL = documentDir.appendingPathComponent(npkiPath!, isDirectory: true)
            return npkiURL.path
        } else {
            return nil
        }
    }
    
    func clearParams() {
        params.removeAll()
        paramsForTableView.removeAll()
        rets = nil
    }
    
    func clearParamsWithoutTableView() {
        params.removeAll()
    }
    
    func sortParams() {
        paramsForTableView.sort { (lhs, rhs) -> Bool in
            let lAuth = lhs.type & 0xff000000
            let rAuth = rhs.type & 0xff000000
            
            if lAuth == rAuth {
                return true
            } else {
                if lAuth == FH_NTS {
                    return true
                } else if rAuth == FH_NTS {
                    return false
                } else if lAuth == FH_4INSU {
                    return true
                } else if rAuth == FH_4INSU {
                    return false
                } else if lAuth == FH_NHIS {
                    return true
                } else if rAuth == FH_NHIS {
                    return false
                } else if lAuth == FH_SCF {
                    return true
                } else if rAuth == FH_SCF {
                    return false
                } else if lAuth == FH_ECAR {
                    return true
                } else if rAuth == FH_ECAR {
                    return false
                } else if lAuth == FH_NPS {
                    return true
                } else if rAuth == FH_NPS {
                    return false
                }
            }
            return true
        }
    }
    
    /**
     * 발급할 문서 정보 입력
     * type : 발급 문서 타입
     * op1 ~ op10 : 발급 문서 옵션
     * lang : 언어설정
     * 각 문서 타입 / 옵션 등은
     * <package>/document/omnidoc_spec.xlsx 문서 확인
     * 일부 문서 타입은 아래 맵핑된 함수 사용 가능
     
    */
    func addParam(type: Int, op1: String, op2: String, op3: String, op4: String, op5: String, op6: String, op7: String, op8: String, op9: String, op10: String, lang: String) {
        let newParam = OmniDocParam(type: Int64(type), op1: op1, op2: op2, op3: op3, op4: op4, op5: op5, op6: op6, op7: op7, op8: op8, op9: op9, op10: op10, lang: lang)
        params.append(newParam)
        if type != FH_MW24_LOGIN {
            paramsForTableView.append(newParam)
        }
    }
    
    /**
     * 모든 옵션은 Default로 하여 문서 발급
     * type: 발급 문서 타입
     * 모든 옵션등은 Default 설정으로 발급진행
     * Default 설정값은 <package>/document/omnidoc_spec.xlsx 문서 확인
     */
    func addDefaultParam(type: Int) {
        addParam(type: type, op1: "", op2: "", op3: "", op4: "", op5: "", op6: "", op7: "", op8: "", op9: "", op10: "", lang: "")
    }
    
    /**
     * 국세청 각종 소득증명서, 사업자등록원
     * @param type      발급받을 종류 : FH_NTS_SODEUK_ + [BONGGUP, SAUP, JONGHAP], FH_NTS_SAUPJA
     * @param usage     용도 : FH_NTS_USAGE_ + [CONTRACT, SUGUM, GWAN, LOAN, VISA, GUNBO, GUMYOONG, CARD, ETC]
     * @param submit    제출처 : FH_NTS_SUBMIT_ + [GUMYOONG, GWAN, JOHAP, GEURAE, SCHOOL, ETC]
     * @param rrn       주민번호 표시 : Y, N
     * @param address   주소 표시 : Y, N
     * @param contact   연락처 표시 : Y, N
     * @param lang      영어 : Y, N
     */
    func addNTS(type: Int, saupjaNum: String, usage: String, submit: String, rrn: String, address: String, contact: String, lang: String) {
        addParam(type: type, op1: saupjaNum, op2: usage, op3: submit, op4: rrn, op5: address, op6: contact, op7: "", op8: "", op9: "", op10: "", lang: lang)
    }
    
    /**
     * 국세청 과세표준증명서
    */
    func addVAT(usage: String, saupjaNum: String, submit: String, rrn: String, address: String, contact: String, lang: String, bangisu: String) {
        addParam(type: FH_NTS_VAT_GWASE, op1: saupjaNum, op2: usage, op3: submit, op4: rrn, op5: address, op6: contact, op7: bangisu, op8: "", op9: "", op10: "", lang: lang)
    }
    
    /**
     * 민원24 주민등록등본
     * @param address       주소변동이력 : 포함:FH_MW24_DB_JUSOHISTORY_INCLUDE, 미포함:FH_MW24_DB_JUSOHISTORY_NOTINCLUDE[기본], 최근5년:FH_MW24_DB_JUSOHISTORY_RECENT5YEAR
     * @param inmate        동거인 포함  : 포함:FH_MW24_DB_INMATE_INCLUDE, 미포함:FH_MW24_DB_INMATE_NOTINCLUDE[기본]
     * @param relation      세대주 관계  : 포함:FH_MW24_DB_RELATION_INCLUDE[기본], 미포함:FH_MW24_DB_RELATION_NOTINCLUDE
     * @param transferDate  전입일표시      : 포함:FH_MW24_DB_JEONIPIL_INCLUDE[기본], 미포함:FH_MW24_DB_JEONIPIL_NOTINCLUDE
     * @param reason        세대구성사유  : 포함:FH_MW24_DB_SEDAEREASON_INCLUDE[기본], 미포함:FH_MW24_DB_SEDAEREASON_NOTINCLUDE
     * @param rrn           세대원주민번호포함 : 포함:FH_MW24_DB_SEDAERRN_INCLUDE[기본], 미포함:FH_MW24_DB_SEDAERRN_NOTINCLUDE
     * @param name          세대원이름표시 : FH_MW24_DB_SEDAENAME_INCLUDE[기본], FH_MW24_DB_SEDAENAME_NOTINCLUDE
     * @param start         세대구성일자 : 01 포함, 02 미포함
     * @param changeReason  세대변동사유 : 01 포함, 02 미포함
     */
    func addMW24JuminD(address: String, inmate: String, relation: String, transferDate: String, reason: String, rrn: String, name: String, start: String, changeReason: String) {
        addParam(type: FH_MW24_JUMIND, op1: address, op2: inmate, op3: relation, op4: transferDate, op5: reason, op6: rrn, op7: name, op8: start, op9: changeReason, op10: "", lang: "")
    }
    
    /**
     * 민원24 주민등록초본
     * @param personalInformation   개인인적사항 : 포함:FH_MW24_CB_INJEOGHISTORY_INCLUDE, 미포함:FH_MW24_CB_INJEOGHISTORY_NOTINCLUDE[기본]
     * @param address               주소변동이력 : 포함:FH_MW24_CB_JUSOHISTORY_INCLUDE, 미포함:FH_MW24_CB_JUSOHISTORY_NOTINCLUDE[기본], 최근5년:FH_MW24_CB_JUSOHISTORY_RECENT5YEAR
     * @param relation              세대주 관계 : 포함:FH_MW24_CB_RELATION_INCLUDE[기본], 미포함:FH_MW24_CB_RELATION_NOTINCLUDE
     * @param militaryService       병역사항: 포함:FH_MW24_CB_MILITARY_INCLUDE, 미포함:FH_MW24_CB_MILITARY_NOTINCLUDE[기본]
     * @param rrn       외국인등록표시: 포함:FH_MW24_CB_FOREIGNNUMBER_INCLUDE, 미포함:FH_MW24_CB_FOREIGNNUMBER_NOTINCLUDE[기본]
     * @param oversea               재외국인국내거소 신고번호: 포함:FH_MW24_CB_FOREIGNHOUSENUMBER_INCLUDE , 미포함:FH_MW24_CB_FOREIGNHOUSENUMBER_NOTINCLUDE
     * @param jeonib    전입변동일 : 01 포함, 02: 미포함 (기본)
     * @param reason  변동사유 : 01 포함, 02:미포함 (기본)
     */
    func addMW24JuminC(personalInformation: String, address: String, relation: String, militaryService: String, rrn: String, oversea: String, jeonib: String, reason: String) {
        addParam(type: FH_MW24_JUMINC, op1: personalInformation, op2: address, op3: relation, op4: militaryService, op5: rrn, op6: oversea, op7: jeonib, op8: reason, op9: "", op10: "", lang: "")
    }
    
    /**
     * 국민연금관리공단 연급지급내역확인서
     * @param usage         용도 : FH_NPS_USAGE_PERSONAL, FH_NPS_USAGE_GWAN, FH_NPS_USAGE_GUMYOONG[기본], FH_NPS_USAGE_ETC
     * @param englishName   lang이 E로 세팅되는 경우 여권상 영문명
     * @param rrn           주민번호표시:1(표시), 0(비표시)
     * @param bankAccount   계좌표시:1(일부), 2(전체), 3(비표시)
     * @param lang          한국어:K, 영어:E
     *
     */
    func addNPSPension(usage: String, englishName: String, rrn: String, bankAccount: String, term: String, lang: String) {
        addParam(type: FH_NPS_PENSION, op1: "", op2: usage, op3: englishName, op4: rrn, op5: bankAccount, op6: term, op7: "", op8: "", op9: "", op10: "", lang: lang)
    }
    
    /**
     * 대법원 가족관계증명
     * @param type       종류 : 기본증명서(FH_SCF_GIBON), 가족관계증명서(FH_SCF_GAJOK), 혼인증명서(FH_SCF_HONIN)
     * @param hojukName  호적상이름 : 다를경우 (utf-8)
     * @param usage      용도 : 본인확인(FH_SCF_USAGE_CHECK)[기본], 회사/학교제출(FH_SCF_USAGE_SCHOOL), 신분증명(FH_SCF_USAGE_SINBUN), 가족관계증명(FH_SCF_USAGE_FMYRT), 연말정산제출(FH_SCF_USAGE_NYUNMAJS), 법원제출(FH_SCF_USAGE_COURT), 기타(FH_SCF_USAGE_ETC)
     * @param rrn        주민등록번호포함: 본인만(1), 전부(2), 전부비공개(3)
     * @param relation      아버지(0), 어머니(1), 배우자(2), 자녀(3)
     * @param relationName  관계자 이름
     */
    func addSCF(type: Int, hojukName: String, usage: String, rrn: String, relation: String, relationName: String) {
        addParam(type: type, op1: hojukName, op2: usage, op3: "", op4: rrn, op5: relation, op6: relationName, op7: "", op8: "", op9: "", op10: "", lang: "")
    }
    
    /**
     * 민원24 로그인용 - 주소 자동 입력
    */
    func addMWLogin() {
        addDefaultParam(type: FH_MW24_LOGIN)
    }
    
    /**
     * 민원24 로그인용
     * @param address1  시/도
     * @param address2  구/동
     * @param address3  나머지 도로명주소
     */
    func addMWLogin(address1: String, address2: String, address3: String) {
        addParam(type: FH_MW24_LOGIN, op1: address1, op2: address2, op3: address3, op4: "", op5: "", op6: "", op7: "", op8: "", op9: "", op10: "", lang: "")
    }
    
    /**
     * 자동차등록원부
     * @param cNum    : 차량번호
     * @param mNum      : 차대번호
     */
    func addECAR(cNum: String, mNum: String) {
        addParam(type: FH_ECAR_DEUNGLOGWONBU, op1: cNum, op2: mNum, op3: "", op4: "", op5: "", op6: "", op7: "", op8: "", op9: "", op10: "", lang: "")
    }
    
    /**
     *   OmniDoc Library's Interfaces
     */
    func CertRequestStructTermAndReset() {
        if canExecute() {
            getOmniDoc().certRequestStructTerm(handle, count: count)
            getOmniDoc().omniDocReset()
        }
        initialize()
    }
    
    /**
     * 공인인증서 oid 별 Policy
     */
    func ParseCertPolicy(oid: String) -> String {
        switch oid {
        case "1.2.410.200004.5.2.1.1": return "한국정보인증㈜|법인 범용"
        case "1.2.410.200004.5.2.1.2": return "한국정보인증㈜|개인 범용"
        case "1.2.410.200004.5.1.1.7": return "한국증권전산㈜|법인 범용"
        case "1.2.410.200004.5.1.1.5": return "한국증권전산㈜|개인 범용"
        case "1.2.410.200005.1.1.5": return "금융결제원|법인 범용"
        case "1.2.410.200005.1.1.1": return "금융결제원|개인 범용"
        case "1.2.410.200004.5.4.1.2": return "한국전자인증|법인 범용"
        case "1.2.410.200004.5.4.1.1": return "한국전자인증|개인 범용"
        case "1.2.410.200012.1.1.3": return "㈜한국무역정보통신|법인 범용"
        case "1.2.410.200012.1.1.1": return "㈜한국무역정보통신|개인 범용"
        case "1.2.410.200004.5.2.1.7.1": return "한국정보인증㈜|은행거래용/보험용"
        case "1.2.410.200004.5.2.1.7.2": return "한국정보인증㈜|증권거래용/보험용"
        case "1.2.410.200004.5.2.1.7.3": return "한국정보인증㈜|신용카드용"
        case "1.2.410.200004.5.1.1.9": return "한국증권전산㈜|용도제한용"
        case "1.2.410.200005.1.1.4": return "금융결제원|은행/보험용"
        case "1.2.410.200005.1.1.6.2": return "금융결제원|신용카드용"
        case "1.2.410.200004.5.4.1.101": return "한국전자인증|인터넷뱅킹용"
        case "1.2.410.200004.5.4.1.102": return "한국전자인증|증권거래용"
        case "1.2.410.200004.5.4.1.103": return "한국전자인증|인터넷보험용"
        case "1.2.410.200004.5.4.1.104": return "한국전자인증|신용카드용"
        case "1.2.410.200004.5.4.1.105": return "한국전자인증|전자민원용"
        case "1.2.410.200004.5.4.1.106": return "한국전자인증|인터넷뱅킹용/전자민원용"
        case "1.2.410.200004.5.4.1.107": return "한국전자인증|증권거래용/전자민원용"
        case "1.2.410.200004.5.4.1.108": return "한국전자인증|인터넷보험용/전자민원용"
        case "1.2.410.200004.5.4.1.109": return "한국전자인증|신용카드용/전자민원용"
        case "1.2.410.200012.11.31": return "㈜한국무역정보통신|은행거래용(서명용)"
        case "1.2.410.200012.11.32": return "㈜한국무역정보통신|은행거래용(암호용)"
        case "1.2.410.200012.11.35": return "㈜한국무역정보통신|증권거래용(서명용)"
        case "1.2.410.200012.11.36": return "㈜한국무역정보통신|증권거래용(암호용)"
        case "1.2.410.200012.11.39": return "㈜한국무역정보통신|보험거래용(서명용)"
        case "1.2.410.200012.11.40": return "㈜한국무역정보통신|보험거래용(암호용)"
        case "1.2.410.200012.11.43": return "㈜한국무역정보통신|신용카드용(서명용)"
        case "1.2.410.200012.11.44": return "㈜한국무역정보통신|신용카드용(암호용)"
        default: return "Unknown"
        }
    }
    
    func CertRequestStructInit(count: Int32, license: String) -> Int {
        self.count = count
        self.handle = getOmniDoc().certRequestStructInit(count)
        return getOmniDoc().setLicense(license)
    }
    
    /**
     * 차후 문서 문서발급 결과 확인을 위한 QueryString 뽑기
     * type : 문서 타입
    */
    func CertRequestStructGetQS(type: Int) -> String? {
        if canExecute() {
            return getOmniDoc().certRequestStructGetQS(handle, count: count, type: type)
        }
        return nil
    }
    
    /**
     * 공인인증서 비밀번호 확인
    */
    func CheckCertPassword(password: String) -> Int {
        return getOmniDoc().checkCertPassword(getNPKIPath(), password: password)
    }
    
    func CheckCertPassword(password: Data) -> Int {
        return getOmniDoc().checkCertPassword(getNPKIPath(), dataPassword: password)
    }
    
    /**
     * 발급문서 정보 일괄 세팅
    */
    func CertRequestStructSet(param: OmniDocParam) -> Int {
        if canExecute() {
            return getOmniDoc().certRequestStructSet(handle,
                                                     count: count,
                                                     type: Int(param.type),
                                                     option1: param.op1,
                                                     option2: param.op2,
                                                     option3: param.op3,
                                                     option4: param.op4,
                                                     option5: param.op5,
                                                     option6: param.op6,
                                                     option7: param.op7,
                                                     option8: param.op8,
                                                     option9: param.op9,
                                                     option10: param.op10,
                                                     language: param.lang)
        } else {
            return -1
        }
    }
    
    func CertRequestStructGetCert(type: Int) -> Data? {
        if canExecute() {
            return getOmniDoc().certRequestStructGetCert(handle, count: count, type: type)
        }
        return nil
    }
    
    func CertRequestStructGetErr(type: Int) -> Int {
        if canExecute() {
            return getOmniDoc().certRequestStructGetErr(handle, count: count, type: type)
        }
        return -1
    }
    
    func CertRequestStructGetErrMsg(type: Int) -> String? {
        if canExecute() {
            return getOmniDoc().certRequestStructGetErrMsg(handle, count: count, type: type)
        }
        return nil
    }
    
    func LoadCaptcha() -> Data? {
        if canExecute() {
            return getOmniDoc().mw24LoadCaptcha(handle, count: count)
        }
        return nil
    }
    
    func LoadCaptchaAudio() -> Data? {
        if canExecute() {
            return getOmniDoc().mw24LoadCaptchaAudio(handle, count: count)
        }
        return nil
    }
    
    func ReloadCaptcha() -> Data? {
        if canExecute() {
            return getOmniDoc().mw24ReloadCaptcha(handle, count: count)
        }
        return nil
    }
    
    func ReloadCaptchaAudio() -> Data? {
        if canExecute() {
            return getOmniDoc().mw24ReloadCaptchaAudio(handle, count: count)
        }
        return nil
    }
    
    func SetCaptcha(captcha: String) -> Int {
        if canExecute() {
            return getOmniDoc().mw24SetCaptcha(handle, count: count, captcha: captcha)
        }
        return -1
    }
    
    func SetECARNumber(carnum: String) {
        for index in 0 ..< params.count {
            if params[index].type == FH_ECAR_DEUNGLOGWONBU {
                params[index].op1 = carnum
                break
            }
        }
    }
    
    func CertIssue(password: String) -> [Int]? {
        if canExecute() {
            progress[0] = 0
            stop[0] = 0
            return getOmniDoc().certIssue(getNPKIPath(),
                                          password: password,
                                          name: name,
                                          rrn1: rrn1,
                                          rrn2: rrn2,
                                          count: count,
                                          handle: handle,
                                          progress: progress,
                                          stop: stop) as? [Int]
        }
        return nil
    }
    
    func CertIssue(password: Data) -> [Int]? {
        if canExecute() {
            progress[0] = 0
            stop[0] = 0
            return getOmniDoc().certIssue(getNPKIPath(),
                                          dataPassword: password,
                                          name: name,
                                          rrn1: rrn1,
                                          rrn2: rrn2,
                                          count: count,
                                          handle: handle,
                                          progress: progress,
                                          stop: stop) as? [Int]
        }
        return nil
    }
    
    func CertSign(password: String) -> Int? {
        if canExecute() {
            return getOmniDoc().certSign(getNPKIPath(), password: password, count: count, handle: handle)
        }
        return nil
    }
    
    func CertSign(password: Data) -> Int? {
        if canExecute() {
            return getOmniDoc().certSign(getNPKIPath(), dataPassword: password, count: count, handle: handle)
        }
        return nil
    }
    
    func CertStop() {
        stop[0] = 1
    }
    
    func GetProgress() -> Int32 {
        return progress[0]
    }
    
    func initialize() {
        handle = nil
        count = -1
    }
    
    func canExecute() -> Bool {
        if handle != nil && count != -1 {
            return true
        }
        return false
    }
    
    /**
     * 라이브러리 버전 획득
     */
    func getLibraryVersion() -> String {
        return getOmniDoc().getLibraryVersion()
    }
    
    /**
     * 주민등록번호 유효 확인
     */
    func checkRrn(password: Data) -> Int {
        return getOmniDoc().checkRRN(getNPKIPath(),
                                     dataPassword: password,
                                     rrn1: rrn1,
                                     rrn2: rrn2)
    }
    
    /**
     * MW24 주소검색
     */
    func findAddress(si: String, gu: String, restAddr: String) -> String? {
        return getOmniDoc().mw24FindAddress(si, gu: gu, restAddr: restAddr);
    }
    
    /**
    *   사용자 주소 확인
    */
    func getAddress(password: Data) -> [String] {
        return getOmniDoc().getAddress(getNPKIPath(),
                                       dataPassword: password,
                                       name: name,
                                       rrn1: rrn1,
                                       rrn2: rrn2,
                                       progress: progress,
                                       stop: stop) as! [String]
    }
    
    /**
     *   입력 Data를 암호화 한 String 타입으로 변환
     *   인증서 비밀번호 / 주민등록 번호를 암호화 하고 싶을 경우 해당 함수를 사용하여 암호화 한 후 사용하면 된다.
     *   param : 암호화 할 데이터 (인증서 비밀번호 / 주민등록 번호)
     *   return : 암호화 된 문자열. 해당 암호화된 문자열을 이후 파라메타로 그대로 사용하면 된다.
     */
    func encryptParam(param: Data) -> String {
        return getOmniDoc().encryptParams(param)
    }
    
    func parseAddress(address: String) -> [String] {
        return getOmniDoc().parseAddress(address) as! [String]
    }
    
    /**
     *  인증서 유효성 검증
     */
    func certValiudate() -> Int {
        return getOmniDoc().certValidate(getNPKIPath());
    }
}

class OmniDocParam {
    enum STATE: Int {
        case PROCESSING = 0, ERROR, COMPLETED, STOP
    }
    init(type: Int64,
         op1: String,
         op2: String,
         op3: String,
         op4: String,
         op5: String,
         op6: String,
         op7: String,
         op8: String,
         op9: String,
         op10: String,
         lang: String) {
        self.type = type
        self.op1 = op1
        self.op2 = op2
        self.op3 = op3
        self.op4 = op4
        self.op5 = op5
        self.op6 = op6
        self.op7 = op7
        self.op8 = op8
        self.op9 = op9
        self.op10 = op10
        self.lang = lang
        self.state = .PROCESSING
    }
    
    var type: Int64 = -1
    var op1: String = ""
    var op2: String = ""
    var op3: String = ""
    var op4: String = ""
    var op5: String = ""
    var op6: String = ""
    var op7: String = ""
    var op8: String = ""
    var op9: String = ""
    var op10: String = ""
    var lang: String = ""
    
    var state: STATE = .PROCESSING
    var issue: String = ""
    var ret: Int = -1
}
