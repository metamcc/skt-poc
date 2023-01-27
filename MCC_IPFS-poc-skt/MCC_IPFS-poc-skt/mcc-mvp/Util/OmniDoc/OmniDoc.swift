//
//  OmniDoc.swift
//  OmniDocSample
//
//  Created by Jinryul.Kim on 2017. 6. 29..
//  Copyright © 2017년 FlyHigh. All rights reserved.
//
//
//  OmniDoc.swift
//  OmniDocPT
//
//  Created by Jinryul.Kim on 2017. 6. 1..
//  Copyright © 2017년 FlyHigh. All rights reserved.
//

import Foundation


class OmniDoc {
    
    // 법원 전자가족관계 등록 시스템
    static let FH_SCF: Int64 = 0x01000000
    static let FH_SCF_INDEX: Int = 1
    
    // 문서 종류
    static let FH_SCF_GIBON: Int64 = (FH_SCF | 0x00000001)
    static let FH_SCF_GAJOK: Int64 = (FH_SCF | 0x00000002)
    static let FH_SCF_HONIN: Int64 = (FH_SCF | 0x00000004)
    
    // 문서 용도 옵션 파라미터
    static let FH_SCF_USAGE_CHECK = "01"
    static let FH_SCF_USAGE_SCHOOL = "02"
    static let FH_SCF_USAGE_SINBUN = "03"	//개인 신분증명용(여권발급, 계약 체결, 국제결혼 등)
    static let FH_SCF_USAGE_FMYRT = "04"	//가족관계증명용(건강보험, 미성년자 보호자 증명 등)
    static let FH_SCF_USAGE_NYUNMAJS = "05"	//연말정산 제출
    static let FH_SCF_USAGE_COURT = "06"	//법원 제출용
    static let FH_SCF_USAGE_ETC = "10"	//기타
    
    static let FH_SCR: Int64 = 0x02000000
    static let FH_SCR_INDEX: Int = 2
    
    //문서 종류
    static let FH_SCR_BUDONGSAN: Int64 = (FH_SCR | 0x00000001)
    static let FH_SCR_BEOPIN: Int64 = (FH_SCR | 0x00000002)
    static let FH_SCR_DONGSAN: Int64 = (FH_SCR | 0x00000004)
    
    /* 민원 24 */
    static let FH_MW24: Int64 = 0x04000000
    static let FH_MW24_INDEX: Int = 0
    
    //문서 종류
    static let FH_MW24_LOGIN: Int64 = (FH_MW24 | 0x00000001)	//민원24 로그인용 공통사용 구조체
    static let FH_MW24_JUMIND: Int64 = (FH_MW24 | 0x00000002)	//주민등록등본
    static let FH_MW24_JUMINC: Int64 = (FH_MW24 | 0x00000004)	//주민등록초본
    static let FH_MW24_JANGAE: Int64 = (FH_MW24 | 0x00000008)	//장애인증명서
    static let FH_MW24_DOKLIBU: Int64 = (FH_MW24 | 0x00000010)	//독립유공자 확인
    static let FH_MW24_GICHOS: Int64 = (FH_MW24 | 0x00000020)	//기초생활수급자 증명서
    static let FH_MW24_GOYOEP: Int64 = (FH_MW24 | 0x00000040)	//고엽제법 적용대상 확인서
    static let FH_MW24_518MU: Int64 = (FH_MW24 | 0x00000080)	//5.18민주유공자 확인서
    
    //등본 옵션. 불필요시 null
    //opt1
    static let FH_MW24_DB_JUSOHISTORY_INCLUDE = "01"		//주소 변동이력 포함
    static let FH_MW24_DB_JUSOHISTORY_NOTINCLUDE = "02"	//주소 변동이력 미포함 - 기본
    static let FH_MW24_DB_JUSOHISTORY_RECENT5YEAR = "03"	//최근 5년간 주소 변동이력 포함
    
    //opt2
    static let FH_MW24_DB_INMATE_INCLUDE = "01"			//동거인 포함
    static let FH_MW24_DB_INMATE_NOTINCLUDE = "02"			//동거인 미포함 - 기본
    
    //opt3
    static let FH_MW24_DB_RELATION_INCLUDE = "01"			//세대주 관계 포함 - 기본
    static let FH_MW24_DB_RELATION_NOTINCLUDE = "02"		//세대주 관계 미포함
    
    //opt4
    static let FH_MW24_DB_JEONIPIL_INCLUDE = "01"			//전입일 포함 - 기본
    static let FH_MW24_DB_JEONIPIL_NOTINCLUDE = "02"		//전입일 미포함
    
    //opt5
    static let FH_MW24_DB_SEDAEREASON_INCLUDE = "01"		//세대구성사유 포함 - 기본
    static let FH_MW24_DB_SEDAEREASON_NOTINCLUDE = "02"	//세대구성사유 미포함
    
    //opt6
    static let FH_MW24_DB_SEDAERRN_INCLUDE = "01"			//세대원 주민번호 공개 - 기본
    static let FH_MW24_DB_SEDAERRN_NOTINCLUDE = "02"		//세대원 주민번호 미공개
    static let FH_MW24_DB_SEDAERRN_BONIN = "03"			//본인
    static let FH_MW24_DB_SEDAERRN_SEDAEWON = "04"			//세대원
    
    //opt7
    static let FH_MW24_DB_SEDAENAME_INCLUDE = "01"			//세대원 이름 공개 - 기본
    static let FH_MW24_DB_SEDAENAME_NOTINCLUDE = "02"		//세대원 이름 미공개
    
    //초본 옵션. 불필요시 null
    //opt1
    static let FH_MW24_CB_INJEOGHISTORY_INCLUDE = "01"	//개인 인적사항 변경내역 포함
    static let FH_MW24_CB_INJEOGHISTORY_NOTINCLUDE = "02"	//개인 인적사항 변경내역 미포함 - 기본
    
    //opt2
    static let FH_MW24_CB_JUSOHISTORY_INCLUDE = "01"		//주소 변동이력 포함
    static let FH_MW24_CB_JUSOHISTORY_NOTINCLUDE = "02"	//주소 변동이력 미포함 - 기본
    static let FH_MW24_CB_JUSOHISTORY_RECENT5YEAR = "03"	//최근 5년간 주소 변동이력 포함
    
    //opt3
    static let FH_MW24_CB_RELATION_INCLUDE = "01"			//세대주 관계 포함 - 기본
    static let FH_MW24_CB_RELATION_NOTINCLUDE = "02"		//세대주 관계 미포함
    
    //opt4
    static let FH_MW24_CB_MILITARY_INCLUDE = "01"			//병역사항 포함
    static let FH_MW24_CB_MILITARY_NOTINCLUDE = "02"		//병역사항 미포함 - 기본
    
    //opt5
    static let FH_MW24_CB_FOREIGNNUMBER_INCLUDE = "01"		//외국인 등록번호 포함
    static let FH_MW24_CB_FOREIGNNUMBER_NOTINCLUDE = "02"	//외국인 등록번호 미포함 - 기본
    
    //opt6
    static let FH_MW24_CB_FOREIGNHOUSENUMBER_INCLUDE = "01"	//재외국민 국내거소 신고번호 포함
    static let FH_MW24_CB_FOREIGNHOUSENUMBER_NOTINCLUDE = "02"	//재외국민 국내거소 신고번호 미포함 - 기본
    
    /* 국세청 */
    static let FH_NTS: Int64 = 0x08000000
    static let FH_NTS_INDEX: Int = 3
    
    //문서 종류
    static let FH_NTS_SODEUK: Int64	= (FH_NTS | 0x00000001);				//소득금액증명서
    static let FH_NTS_SODEUK_BONGGUP: Int64 = (FH_NTS_SODEUK | 0x00010000); 	//소득금액증명서(봉급근로자) - 기본
    static let FH_NTS_SODEUK_SAUP: Int64 = (FH_NTS_SODEUK | 0x00020000); 	//소득금액증명서(사업자)
    static let FH_NTS_SODEUK_JONGHAP: Int64 = (FH_NTS_SODEUK | 0x00040000); 	//소득금액증명서(종합소득세)
    static let FH_NTS_SAUPJA: Int64	= (FH_NTS | 0x00000002);				//사업자등록증명원
    static let FH_NTS_VAT_GWASE: Int64 = (FH_NTS | 0x00000003);				//부가가치세 과세표준증명
    
    //용도
    static let FH_NTS_USAGE_CONTRACT = "01";	//계약체결
    static let FH_NTS_USAGE_SUGUM = "02";		//수금
    static let FH_NTS_USAGE_GWAN = "03";		//관공서제출
    static let FH_NTS_USAGE_LOAN = "04";		//대출  - 기본
    static let FH_NTS_USAGE_VISA = "05";		//비자발급
    static let FH_NTS_USAGE_GUNBO = "06";		//건강보험공단
    static let FH_NTS_USAGE_GUMYOONG = "07";	//금융기관
    static let FH_NTS_USAGE_CARD = "08";		//카드사
    static let FH_NTS_USAGE_ETC = "99";			//기타
    
    //제출처
    static let FH_NTS_SUBMIT_GUMYOONG = "01";	//금융기관제출 - 기본
    static let FH_NTS_SUBMIT_GWAN = "02";		//관공서제출
    static let FH_NTS_SUBMIT_JOHAP = "03";		//조합/협회
    static let FH_NTS_SUBMIT_GEURAE = "04";		//거래처
    static let FH_NTS_SUBMIT_SCHOOL = "05";		//학교
    static let FH_NTS_SUBMIT_ETC = "99";		//기타
    
    /* 국민연금 */
    static let FH_NPS: Int64 = 0x10000000;
    static let FH_NPS_INDEX = 4;
    
    //문서
    static let FH_NPS_PENSION: Int64	= (FH_NPS | 0x00000001);	//연금지급내역증명
    
    //용도
    static let FH_NPS_USAGE_PERSONAL = "01";	//개인
    static let FH_NPS_USAGE_GWAN = "02";		//관공서
    static let FH_NPS_USAGE_GUMYOONG = "03";	//금융기관 - 기본
    static let FH_NPS_USAGE_ETC = "04";			//기타
    
    
    
    /* 국민건강보험공단 */
    static let FH_NHIS: Int64 = 0x20000000;
    static let FH_NHIS_INDEX: Int = 5;
    
    //문서
    static let FH_NHIS_JAGEOK: Int64	= (FH_NHIS | 0x00000001);		//건보자격득실증명
    static let FH_NHIS_NABBU: Int64	= (FH_NHIS | 0x00000002);		//건보납입증명
    static let FH_NHIS_WANNAB: Int64	= (FH_NHIS | 0x00000004);
    
    //건보자격득실증명 옵션
    static let FH_NHIS_JAGEOK_ALL = "0";		//전체 - 기본
    static let FH_NHIS_JAGEOK_JIKJANG = "1";	//직장
    static let FH_NHIS_JAGEOK_JIYEOK = "2";		//지역
    static let FH_NHIS_JAGEOK_GAIPJA = "3";		//가입자전체
    
    //용도옵션
    static let FH_NHIS_USAGE_CHECK = "2";		//납부확인 - 기본
    static let FH_NHIS_USAGE_NYUNMALJS = "4";	//연말정산
    static let FH_NHIS_USAGE_SCHOOL = "6";		//학교
    static let FH_NHIS_USAGE_JONGHAP = "8";		//종합
    
    //완납 용도 옵션
    static let FH_NHIS_USAGE_W_CHECK = "53";	//납부확인
    static let FH_NHIS_USAGE_W_GWAN = "30";		//국가지방자치단체 공공기관 제출용
    
    /* 4대보험 */
    static let FH_4INSU: Int64 = 0x40000000;
    static let FH_4INSU_INDEX: Int = 6;
    
    //문서
    static let FH_4INSU_GAIB: Int64		= (FH_4INSU | 0x00000001);	//가입증명
    static let FH_4INSU_NMLIST: Int64	= (FH_4INSU | 0x00000002);
    
    /* 자동차 */
    static let FH_ECAR: Int64 = 0x80000000;
    static let FH_ECAR_INDEX: Int = 7;
    
    //문서
    static let FH_ECAR_DEUNGLOGWONBU: Int64	= (FH_ECAR | 0x00000001);	//자동차등록원부
    
    /*                        *
     *  문서 발급용 파라미터  *
     *                        */
    
    /* 문서 발급 결과 에러 코드 */
    static let FH_E_N_SERVER_CONNECT: Int64		= 0x00000001;	//서버연결에 실패. 단말 네트웍 또는 서버 서비스가 죽음
    static let FH_E_N_AUTH_FAIL: Int64			= 0x00000002;	//로그인이나 사용자 인증에 실패. 입력값이 바르지 않거나 사용자 등록이 되어있지 않음
    static let FH_E_N_SERVICE_TIME: Int64		= 0x00000003;	//서비스시간이 아님
    static let FH_E_N_APPLIED: Int64				= 0x00000004;	//사용자가 발급 조건에 적합하지 않음
    static let FH_E_N_INFO_EXTRACT: Int64		= 0x00000005;	//정보추출에 실패
    static let FH_E_N_ESSENTIAL_INFO: Int64		= 0x00000006;	//필수정보 누락
    static let FH_E_F_DECOMPRESS: Int64			= 0x00000007;	//압축해제 실패
    static let FH_E_F_DECRYPT: Int64				= 0x00000008;	//복호화 실패
    static let FH_E_F_SM_CONNECT: Int64			= 0x00000009;	//세션서버 연결 실패(xgate, Random, Time 서버등)
    static let FH_E_F_SSO: Int64					= 0x0000000A;	//SSO 실패(건보, 국세청 등 여러 도메인 넘나들을 때 발생)
    static let FH_E_F_PROTOCOL: Int64			= 0x0000000B;	//서버의 응답 내용이 변경됨
    static let FH_E_F_ENCRYPT: Int64				= 0x0000000C;	//암호화 실패
    static let FH_E_F_MALFORMAT: Int64			= 0x0000000D;	//메시지 형태 오류
    static let FH_E_F_REGISTRATION: Int64		= 0x0000000E;	//회원등록 실패
    static let FH_E_F_ROLE_CHANGE: Int64			= 0x0000000F;	//조회자격 변경(개인 -> 사업자)
    static let FH_E_F_TIME_OVER: Int64		= 0x00000010;	//시간 지연으로 발급이 불가능한 상태 ... 나중에 재시도
    static let FH_E_F_MEM_ALLOC: Int64		= 0x00000011;	//메모리 할당 실패
    static let FH_E_F_CONNECT_INIT_FAIL: Int64	= 0x00000012;	//웹연결 초기화 실패
    static let FH_E_F_CERTTYPE_MISMATCH: Int64	= 0x00000013;	//조회된 인증서가 요청한 인증서와 다름
    static let FH_E_F_CERT_NOT_EXIST: Int64		= 0x00000014;	//인증서가 조회지 않음
    static let FH_E_F_WRONG_ADDRESS: Int64		= 0x00000015;	//잘못된 주소
    static let FH_E_F_LICENSE_CHECK: Int64		= 0x00000016;	//라이선스 검증 실패
    static let FH_E_F_NO_LICENSE: Int64			= 0x00000017;	//라이선스 값이 존재하지 않음
    static let FH_E_F_LICENSE_EXPIRED: Int64		= 0x00000018;	//라이선스 기간 만료
    
    /* 인증서 정보 필드 아이디 */
    static let  CERT_SERIAL: Int64				= 0x00000001;	//인증서의 시리얼
    static let  CERT_NOTBEFORE: Int64				= 0x00000002;	//인증서의 유효기간중 시작일
    static let  CERT_NOTAFTER: Int64				= 0x00000003;	//인증서의 유효기간중 종료일
    static let  CERT_ISSUER: Int64			= 0x00002000;	//인증서 발급자
    static let  CERT_SUBJECT: Int64				= 0x00004000;	//인증서 소유자
    static let  CERT_CERTPOLICY: Int64			= 0x00010000;	//인증서 정책
}
