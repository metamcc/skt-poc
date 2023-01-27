//
//  FHOmniDoc.h
//  OmniDoc
//
//  Created by FlyHigh on 2016. 4. 20..
//  Copyright © 2016년 FlyHigh. All rights reserved.
//

#import <Foundation/Foundation.h>

static const NSInteger FH_SCF = 0x01000000; //대법원 가족
static const NSInteger FH_SCF_INDEX = 1;

static const NSInteger FH_SCF_GIBON = (FH_SCF | 0x00000001); //기본증명서
static const NSInteger FH_SCF_GAJOK = (FH_SCF | 0x00000002); //가족관계증명서
static const NSInteger FH_SCF_JEJOEK = (FH_SCF | 0x00000003); //가족관계증명서
static const NSInteger FH_SCF_HONIN = (FH_SCF | 0x00000004); //혼인관계증명서
static const NSInteger FH_SCF_GIBON_UC = (FH_SCF | 0x00000005); //기본증명서(후견인)

static const NSString *FH_SFC_USAGE_CHECK = @"01"; //본인 확인용(출생, 혼인, 사망 등 확인을 위한 목적)
static const NSString *FH_SFC_USAGE_SCHOOL = @"02"; //회사 및 학교 제출용(입사, 경조사, 장학금신청 등)
static const NSString *FH_SFC_USAGE_SINBUN = @"03"; //개인 신분증명용(여권발급, 계약 체결, 국제결혼 등)
static const NSString *FH_SFC_USAGE_FMYRT = @"04"; //가족관계증명용(건강보험, 미성년자 보호자 증명 등)
static const NSString *FH_SFC_USAGE_NYUNMAJS = @"05"; //연말정산 제출
static const NSString *FH_SFC_USAGE_COURT = @"06"; //법원 제출용
static const NSString *FH_SFC_USAGE_ETC = @"10"; //기타

static const NSInteger FH_SCR = 0x02000000; //대법원 등기
static const NSInteger FH_SCR_INDEX = 2;
static const NSInteger FH_SCR_BUDONGSAN = (FH_SCR | 0x00000001); //부동산등기사항증명서
static const NSInteger FH_SCR_BEOPIN = (FH_SCR | 0x00000002); //법인등기사항증명서
static const NSInteger FH_SCR_DONGSAN = (FH_SCR | 0x00000004); //동산채권담보등기증명서

static const NSInteger FH_MW24 = 0x04000000; //민원24
static const NSInteger FH_MW24_INDEX = 0;
static const NSInteger FH_MW24_LOGIN = (FH_MW24 | 0x00000001);	//로그인
static const NSInteger FH_MW24_JUMIND = (FH_MW24 | 0x00000002);	//주민등록등본
static const NSInteger FH_MW24_JAMGAE = (FH_MW24 | 0x00000003);	//장애인증명
static const NSInteger FH_MW24_JUMINC = (FH_MW24 | 0x00000004);	//주민등록초본
static const NSInteger FH_MW24_GICHOS = (FH_MW24 | 0x00000005);	//기초수금대상자증명
static const NSInteger FH_MW24_HANBUMO = (FH_MW24 | 0x00000006);	//한부모증명
static const NSInteger FH_MW24_JIBANGSENAB = (FH_MW24 | 0x00000007);	//지방세납입증명
static const NSInteger FH_MW24_INNOUT = (FH_MW24 | 0x00000008);	  //출입국사실증명
static const NSInteger FH_MW24_ALIENREG = (FH_MW24 | 0x00000009);	//외국인등록 사실증명
static const NSInteger FH_MW24_LIVINGIN = (FH_MW24 | 0x0000000A);	//국내거소신고 사실증명

//등본 옵션 파라미터 1~9
static const NSString* FH_MW24_DB_JUSOHISTORY_INCLUDE = @"01"; //주소 변동이력 포함
static const NSString* FH_MW24_DB_JUSOHISTORY_NOTINCLUDE = @"02"; //주소 변동이력 미포함	 - 기본옵션
static const NSString* FH_MW24_DB_JUSOHISTORY_RECENT5YEAR = @"03"; //최근 5년간 주소 변동이력 포함

static const NSString* FH_MW24_DB_INMATE_INCLUDE = @"01";	//동거인 포함
static const NSString* FH_MW24_DB_INMATE_NOTINCLUDE = @"02"; //동거인 미포함 - 기본옵션

static const NSString* FH_MW24_DB_RELATION_INCLUDE = @"01"; //세대주 관계 포함 - 기본옵션
static const NSString* FH_MW24_DB_RELATION_NOTINCLUDE = @"02"; //세대주 관계 미포함

static const NSString* FH_MW24_DB_JEONIPIL_INCLUDE = @"01";	//전입일 포함 - 기본옵션
static const NSString* FH_MW24_DB_JEONIPIL_NOTINCLUDE = @"02"; //전입일 미포함

static const NSString* FH_MW24_DB_SEDAEREASON_INCLUDE = @"01"; //세대구성사유 포함 - 기본옵션
static const NSString* FH_MW24_DB_SEDAEREASON_NOTINCLUDE = @"02"; //세대구성사유 미포함

static const NSString* FH_MW24_DB_SEDAERRN_INCLUDE = @"01"; //세대원 주민번호 모두공개
static const NSString* FH_MW24_DB_SEDAERRN_NOTINCLUDE = @"02"; //세대원 주민번호 모두미공개 - 기본옵션
static const NSString* FH_MW24_DB_SEDAERRN_REQONLY = @"03";   //본인만 공개
static const NSString* FH_MW24_DB_SEDAERRN_OTHERONLY = @"04"; //세대원만 공개

static const NSString* FH_MW24_DB_SEDAENAME_INCLUDE = @"01"; //세대원 이름 공개 - 기본옵션
static const NSString* FH_MW24_DB_SEDAENAME_NOTINCLUDE = @"02"; //세대원 이름 미공개

static const NSString* FH_MW24_DB_SEDAEDAY_INCLUDE = @"01"; //세대구성일자 포함
static const NSString* FH_MW24_DB_SEDAEDAY_NOTINCLUDE = @"02"; //세대구성일자 미포함 - 기본옵션

static const NSString* FH_MW24_DB_SEDAECNGREASON_INCLUDE = @"01"; //세대변동사유 포함
static const NSString* FH_MW24_DB_SEDAECNGREASON_NOTINCLUDE = @"02"; //세대변동사유 미포함 - 기본옵션

//초본 옵션 파라미터 1~8
static const NSString* FH_MW24_CB_INJEOGHISTORY_INCLUDE = @"01"; //개인 인적사항 변경내역 포함
static const NSString* FH_MW24_CB_INJEOGHISTORY_NOTINCLUDE = @"02"; //개인 인적사항 변경내역 미포함 - 기본옵션

static const NSString* FH_MW24_CB_JUSOHISTORY_INCLUDE = @"01"; //주소 변동이력 포함
static const NSString* FH_MW24_CB_JUSOHISTORY_NOTINCLUDE = @"02"; //주소 변동이력 미포함 - 기본옵션
static const NSString* FH_MW24_CB_JUSOHISTORY_RECENT5YEAR = @"03"; //최근 5년간 주소 변동이력 포함

static const NSString* FH_MW24_CB_RELATION_INCLUDE = @"01"; //세대주 관계 포함 - 기본옵션
static const NSString* FH_MW24_CB_RELATION_NOTINCLUDE = @"02"; //세대주 관계 미포함

static const NSString* FH_MW24_CB_MILITARY_INCLUDE = @"01";	//병역사항 포함
static const NSString* FH_MW24_CB_MILITARY_NOTINCLUDE = @"02"; //병역사항 미포함 - 기본옵션

static const NSString* FH_MW24_CB_RRN_INCLUDE = @"01"; //주민등록번호 뒷자리 포함
static const NSString* FH_MW24_CB_RRN_NOTINCLUDE = @"02"; //주민등록번호 뒷자리 미포함 - 기본옵션

static const NSString* FH_MW24_CB_FOREIGNHOUSENUMBER_INCLUDE = @"01"; //재외국민 국내거소 신고번호 포함
static const NSString* FH_MW24_CB_FOREIGNHOUSENUMBER_NOTINCLUDE = @"02"; //재외국민 국내거소 신고번호 미포함 - 기본옵션

static const NSString* FH_MW24_CB_JEONIPCNG_INCLUDE = @"01"; //전입변동일 포함
static const NSString* FH_MW24_CB_JEONIPCNG_NOTINCLUDE = @"02"; //전입변동일 미포함 - 기본옵션

static const NSString* FH_MW24_CB_CNGREASON_INCLUDE = @"01"; //변동사유 포함
static const NSString* FH_MW24_CB_CNGREASON_NOTINCLUDE = @"02"; //변동사유 미포함 - 기본옵션

static const NSInteger FH_NTS = 0x08000000; //홈텍스
static const NSInteger FH_NTS_INDEX = 3;
static const NSInteger FH_NTS_SODEUK = (FH_NTS | 0x00000001);
static const NSInteger FH_NTS_SODEUK_BONGGUP = (FH_NTS_SODEUK | 0x00010000);	//봉급생활자 소득금액증명
static const NSInteger FH_NTS_SODEUK_SAUP = (FH_NTS_SODEUK | 0x00020000);	//사업소득자 소득금액증명
static const NSInteger FH_NTS_SODEUK_JONGHAP = (FH_NTS_SODEUK | 0x00040000);	//종합소득세신고자 소득금액증명
static const NSInteger FH_NTS_SAUPJA = (FH_NTS | 0x00000002);	//사업자등록증명
static const NSInteger FH_NTS_VAT_GWASE = (FH_NTS | 0x00000003);	//부가가치세 과세표준증명
static const NSInteger FH_NTS_CREDITCARD_USE = (FH_NTS | 0x00000004);	//신용카드이용내역
static const NSInteger FH_NTS_JEONGSAN = (FH_NTS | 0x00000005);	//원천징수영수증
static const NSInteger FH_NTS_MYOUNSESUIP = (FH_NTS | 0x00000006);	//부가가치세 면세사업자 수입금액증명
static const NSInteger FH_NTS_JONGHAPSINGO = (FH_NTS | 0x00000007);	//종합신고확인서
static const NSInteger FH_NTS_NABSE = (FH_NTS | 0x00000008);	//납세증명서(국세완납증명)
static const NSInteger FH_NTS_PIEUP = (FH_NTS | 0x00000009);	//폐업사실증명
static const NSInteger FH_NTS_HIUUP = (FH_NTS | 0x0000000A);	//휴업사실증명
static const NSInteger FH_NTS_GONGJE = (FH_NTS | 0x0000000B);	//연금보험료등 소득·세액 공제확인서
static const NSInteger FH_NTS_DEBITCARD_USE = (FH_NTS | 0x0000000C);	 //직불카드이용내역
static const NSInteger FH_NTS_CASHRECEIPT = (FH_NTS | 0x0000000D);	   //현금영수증
static const NSInteger FH_NTS_PENSIONSAVINGS = (FH_NTS | 0x0000000E);	 //개인연금저축/연금계좌
static const NSInteger FH_NTS_NHEALTHINSURANCE = (FH_NTS | 0x0000000F);	 //건강보험
static const NSInteger FH_NTS_NATIONALPENSION = (FH_NTS | 0x00000010);	  //국민연금
static const NSInteger FH_NTS_INSURANCE = (FH_NTS | 0x00000011);			  //보험료
static const NSInteger FH_NTS_MEDICALEXPENSE = (FH_NTS | 0x00000013);	   //의료비
static const NSInteger FH_NTS_EDUCATIONEXPENSE = (FH_NTS | 0x00000014);	 //교육비

static const NSInteger FH_NTS_SAUPJA_LIST = (FH_NTS | 0x00000012);	//개인사업자 사업장목록

static const NSInteger FH_NTS_SASIL_CHAENAB = (FH_NTS | 0x00000101);	//개인용 : 주민등록번호, 법인용 : 본점(지점)사업자등록번호
static const NSInteger FH_NTS_SASIL_SODEUKGONGJE = (FH_NTS | 0x00000102);	//주민등록번호
static const NSInteger FH_NTS_SASIL_NOSINGO = (FH_NTS | 0x00000103);
static const NSInteger FH_NTS_SASIL_SAUPJA = (FH_NTS | 0x00000104);
static const NSInteger FH_NTS_SASIL_SAUPJABYUNGYUNG = (FH_NTS | 0x00000105);	//개인용 : 주민등록번호, 법인용 : 본점(지점)사업자등록번호
static const NSInteger FH_NTS_SASIL_DAEPYO = (FH_NTS | 0x00000106);
static const NSInteger FH_NTS_SASIL_SAUPJAGONDONG = (FH_NTS | 0x00000107);
static const NSInteger FH_NTS_SASIL_SAUPJAMALSO = (FH_NTS | 0x00000108);
static const NSInteger FH_NTS_SASIL_JEONYONGGEYJOA = (FH_NTS | 0x0000010A);	//사업자등록번호(국세청 기능번호와 맵핑을 위해 09를 스킵)
static const NSInteger FH_NTS_SASIL_PEYUP = (FH_NTS | 0x0000010B);	//주민등록번호
static const NSInteger FH_NTS_SASIL_SOBISEWHABGEUP = (FH_NTS | 0x0000010C);	//사업자등록번호

static const NSString *FH_NTS_KIND_BONGGUP = @"B1013"; //봉급근로자 소득증명 - 기본
static const NSString *FH_NTS_KIND_SAUP = @"B1010";	//사업자 소득증명
static const NSString *FH_NTS_KIND_JONGHAP = @"B1001"; //종합소득세신고자 소득증명
static const NSString *FH_NTS_KIND_BUGAMYUNSE = @"B1002"; //부가가치세면세사업자수입금액증명
static const NSString *FH_NTS_KIND_HIUUP = @"B0002"; //휴업증명
static const NSString *FH_NTS_KIND_PIEUP = @"B0012"; //폐업증명
static const NSString *FH_NTS_KIND_DANWUIGOASE = @"B0021"; //사업자단위과세적용증명 or B0024
static const NSString *FH_NTS_KIND_MYUNSE = @"B1002"; //면세사업자증명
static const NSString *FH_NTS_KIND_JAEMUJEPYO = @"B1003"; //표준재무제표
static const NSString *FH_NTS_KIND_BUGAGOASE = @"B4009"; //부가가치세과세표준증명
static const NSString *FH_NTS_KIND_SASIL_CHAENAB = @"B0101"; //사실증명(체납내역)
static const NSString *FH_NTS_KIND_SASIL_SODEUKGONGJE = @"B0102"; //사실증명(주택자금 등 소득공제사실여부)
static const NSString *FH_NTS_KIND_SASIL_NOSINGO = @"B0103"; //사실증명(신고사실없음)
static const NSString *FH_NTS_KIND_SASIL_SAUPJA = @"B0104"; //사실증명(사업자등록사실여부)
static const NSString *FH_NTS_KIND_SASIL_SAUPJABYUNGYUNG = @"B0105"; //사실증명(사업자등록변경내역)
static const NSString *FH_NTS_KIND_SASIL_DAEPYO = @"B0106"; //사실증명(대표자등록내역)
static const NSString *FH_NTS_KIND_SASIL_SAUPJAGONDONG = @"B0107"; //사실증명(공동사업자내역)
static const NSString *FH_NTS_KIND_SASIL_SAUPJAMALSO = @"B0108"; //사실증명(사업자단위과세 승인시 지점사업자등록번호 직권말소)
static const NSString *FH_NTS_KIND_SASIL_JEONYONGGEYJOA = @"B0110"; //사사실증명(전용계좌개설여부)
static const NSString *FH_NTS_KIND_SASIL_PEYUP = @"B0111"; //사실증명(폐업자에 대한 업종등의 정보내역)
static const NSString *FH_NTS_KIND_SASIL_SOBISEWHABGEUP = @"B0112"; //사실증명(개별소비세 (교통·에너지·환경세) 환급사실여부)
static const NSString *FH_NTS_KIND_NABSE_DAEGUM = @"B0006"; //납세증명서 for 대금수령
static const NSString *FH_NTS_KIND_NABSE_GITA = @"B0007"; //납세증명서 for 기타
static const NSString *FH_NTS_KIND_GONGJE = @"B1012"; //연금보험료등 소득,세액공제확인서

static const NSString *FH_NTS_USAGE_CONTRACT = @"01"; //계약체결
static const NSString *FH_NTS_USAGE_SUGUM = @"02";	//수금
static const NSString *FH_NTS_USAGE_GWAN = @"03";	 //관공서제출
static const NSString *FH_NTS_USAGE_LOAN = @"04";	 //대출 - 기본
static const NSString *FH_NTS_USAGE_VISA = @"05";	 //비자발급
static const NSString *FH_NTS_USAGE_GUNBO = @"06";	//건강보험공단
static const NSString *FH_NTS_USAGE_GUMYOONG = @"07"; //금융기관
static const NSString *FH_NTS_USAGE_CARD = @"08";	 //카드사
static const NSString *FH_NTS_USAGE_ETC = @"99";	  //기타

static const NSString *FH_NTS_SUBMIT_GUMYOONG = @"01"; //금융기관제출 - 기본
static const NSString *FH_NTS_SUBMIT_GWAN = @"02";		//관공서제출
static const NSString *FH_NTS_SUBMIT_JOHAP = @"03";	//조합/협회
static const NSString *FH_NTS_SUBMIT_GEURAE = @"04";   //거래처
static const NSString *FH_NTS_SUBMIT_SCHOOL = @"05";   //학교
static const NSString *FH_NTS_SUBMIT_ETC = @"99";		//기타

static const NSInteger FH_NPS = 0x10000000;	//국민연금
static const NSInteger FH_NPS_INDEX = 4;

static const NSInteger FH_NPS_PENSION = (FH_NPS | 0x00000001);	//연금지급내역
static const NSInteger FH_NPS_NPS_JOIN = (FH_NPS | 0x00000002);	//가입자 가입증명
static const NSInteger FH_NPS_MEMBER_PAY = (FH_NPS | 0x00000003);	//연금산정용 가입내역

static const NSString *FH_NPS_USAGE_PERSONAL = @"01"; //개인
static const NSString *FH_NPS_USAGE_GWAN = @"02";	 //관공서
static const NSString *FH_NPS_USAGE_GUMYOONG = @"03"; //금융기관 - 기본
static const NSString *FH_NPS_USAGE_ETC = @"04";	  //기타

static const NSInteger FH_NHIS = 0x20000000;	//건강보험공단
static const NSInteger FH_NHIS_INDEX = 5;

static const NSInteger FH_NHIS_JAGEOK = (FH_NHIS | 0x00000001);	//자격득실확인서
// 0 - 전체, 1- 직장, 2- 지역, 3- 가입자전체
static const NSString *FH_NHIS_JAGEOK_ALL = @"0";	 //전체 - 기본
static const NSString *FH_NHIS_JAGEOK_JIKJANG = @"1"; //직장
static const NSString *FH_NHIS_JAGEOK_JIYOEK = @"2";  //지역
static const NSString *FH_NHIS_JAGEOK_GAIPJA = @"3";  //가입자전체
static const NSInteger FH_NHIS_NABBU = (FH_NHIS | 0x00000002);	//납부확인서
// 2 - 납부확인용, 4 - 연말정산용, 6 - 학교제출용, 8 - 종합소득세신고용
static const NSString *FH_NHIS_USAGE_CHECK = @"2";		//납부확인 - 기본
static const NSString *FH_NHIS_USAGE_NYUNMALJS = @"4"; //연말정산
static const NSString *FH_NHIS_USAGE_SCHOOL = @"6";	//학교
static const NSString *FH_NHIS_USAGE_JONGHAP = @"8";   //조합
static const NSInteger FH_NHIS_WANNAB = (FH_NHIS | 0x00000004);	//완납증명서
// 53 - 납부확인용, 30 - 국가 지방자치단체 공공기관 제출용
static const NSString *FH_NHIS_USAGE_W_CHECK = @"53"; //납부확인
static const NSString *FH_NHIS_USAGE_W_GWAN = @"30";  //국가 지방자치단체 공공기관 제출용
static const NSInteger FH_NHIS_HEALTHCHECK = (FH_NHIS | 0x00000005);	//건강검진
static const NSInteger FH_NHIS_JINRYOHISTORY = (FH_NHIS | 0x00000006);	//진료이력

static const NSInteger FH_4INSU = 0x40000000; // 4대사회보험
static const NSInteger FH_4INSU_INDEX = 6;
static const NSInteger FH_4INSU_GAIB = (FH_4INSU | 0x00000001);	//가입증명서
static const NSInteger FH_4INSU_WANNAB = (FH_4INSU | 0x00000002); //미구현

static const NSInteger FH_ECAR = 0x80000000; //자동차 대국민 포털
static const NSInteger FH_ECAR_INDEX = 7;
static const NSInteger FH_ECAR_DEUNGLOGWONBU = (FH_ECAR | 0x00000001); //자동차등록원부

static const NSInteger FH_CREDIT4U = 0x00100000;//내보험다보여
static const NSInteger FH_CREDIT4U_INDEX = 8;

static const NSInteger FH_CREDIT4U_MY_INSU_CREDIT = (FH_CREDIT4U | 0x00000001);	//전체목록
static const NSInteger FH_CREDIT4U_MY_INSU_FIX = (FH_CREDIT4U | 0x00000002);	//정액보험 상세
static const NSInteger FH_CREDIT4U_MY_INSU_SILSON = (FH_CREDIT4U | 0x00000003);	//실손보험 상세

static const NSInteger FH_NICE_MC_SKT = 1;
static const NSInteger FH_NICE_MC_KTF = 2;
static const NSInteger FH_NICE_MC_LGT = 3;

/*알뜰폰*/
static const NSInteger FH_NICE_MC_SKM = 4;
static const NSInteger FH_NICE_MC_KTM = 5;
static const NSInteger FH_NICE_MC_LGM = 6;

static const NSInteger FH_NICE_GENDER_F = 0;
static const NSInteger FH_NICE_GENDER_M = 1;

static const NSInteger FH_NICE_NATION_KOREA = 0;
static const NSInteger FH_NICE_NATION_FOREIGN = 1;

static const NSInteger FH_PAYINFO = 0x00200000;	//계좌통합관리서비스
static const NSInteger FH_PAYINFO_INDEX = 9;
static const NSInteger FH_PAYINFO_MY_ACCOUNT_ALL = (FH_PAYINFO | 0x00000001); //전계좌조회

static const NSString *FH_PAYINFO_BANK_HANA = @"081"; //KEB하나은행
static const NSString *FH_PAYINFO_BANK_NH = @"011";   //NH농협은행
static const NSString *FH_PAYINFO_BANK_SC = @"023";   //SC제일은행
static const NSString *FH_PAYINFO_BANK_KN = @"039";   //경남은행
static const NSString *FH_PAYINFO_BANK_KJ = @"034";   //광주은행
static const NSString *FH_PAYINFO_BANK_KM = @"004";   //국민은행
static const NSString *FH_PAYINFO_BANK_KU = @"003";   //기업은행
static const NSString *FH_PAYINFO_BANK_DG = @"031";   //대구은행
static const NSString *FH_PAYINFO_BANK_BS = @"032";   //부산은행
static const NSString *FH_PAYINFO_BANK_SAU = @"002";  //산업은행
static const NSString *FH_PAYINFO_BANK_SUH = @"007";  //수협은행
static const NSString *FH_PAYINFO_BANK_SH = @"088";   //신한은행
static const NSString *FH_PAYINFO_BANK_CT = @"027";   //씨티은행
static const NSString *FH_PAYINFO_BANK_WR = @"020";   //우리은행
static const NSString *FH_PAYINFO_BANK_JB = @"037";   //전북은행
static const NSString *FH_PAYINFO_BANK_JJ = @"035";   //제주은행
static const NSString *FH_PAYINFO_BANK_K = @"089";	//케이뱅크
static const NSString *FH_PAYINFO_BANK_KKO = @"090";  //카카오뱅크

static const NSInteger FH_GEPS = 0x00300000;	//공무원연금공단
static const NSInteger FH_GEPS_INDEX = 10;
static const NSInteger FH_GEPS_ACCOUNT_CHECK = (FH_GEPS | 0x00000001);	//계정정보
static const NSInteger FH_GEPS_PENSION_INFO = (FH_GEPS | 0x00000002);	//계정상세정보

static const NSInteger FH_MPS = 0x00400000;	//군인연금
static const NSInteger FH_MPS_INDEX = 11;
static const NSInteger FH_MPS_ACCOUNT_CHECK = (FH_MPS | 0x00000001);	//계정정보

static const NSInteger FH_TP = 0x00500000;	//사학연금
static const NSInteger FH_TP_INDEX = 12;
static const NSInteger FH_TP_ACCOUNT_CHECK = (FH_TP | 0x00000001);	//계정정보

static const NSInteger FH_AIPIS = 0x80100000;	//보험개발원 자동차보험 과납보험료 환급조회 통합시스템
static const NSInteger FH_AIPIS_INDEX = 13;
static const NSInteger FH_AIPIS_REQ_REFUND = (FH_AIPIS | 0x00000001);	//자동차보험이력조회

static const NSInteger FH_KUCA = 0x80200000;	//한국자동차매매사업조합연합회
static const NSInteger FH_KUCA_INDEX = 14;
static const NSInteger FH_KUCA_CARSEARCH = (FH_KUCA | 0x00000001);	//중고차 조회

static const NSInteger FH_EFINE = 0x80300000;	// eFine
static const NSInteger FH_EFINE_INDEX = 15;
static const NSInteger FH_EFINE_MIPENALTYLIST = (FH_EFINE | 0x00000001); //미납과태료
static const NSInteger FH_EFINE_MIVIOLLIST = (FH_EFINE | 0x00000002); //미납범칙금
static const NSInteger FH_EFINE_GIPENALTYLIST = (FH_EFINE | 0x00000003); //기납과태료
static const NSInteger FH_EFINE_GIVIOLLIST = (FH_EFINE | 0x00000004); //기납범칙금
static const NSInteger FH_EFINE_SUSLICENSEPERIOD = (FH_EFINE | 0x00000005); //운전면허정지기간
static const NSInteger FH_EFINE_PENALTYPOINT = (FH_EFINE | 0x00000006); //운전면허벌점조회
static const NSInteger FH_EFINE_LICENSEINCAP = (FH_EFINE | 0x00000007); //운전면허결격기간
static const NSInteger FH_EFINE_LICENSECAREER = (FH_EFINE | 0x00000008); //운전면허경력서

static const NSInteger FH_KCB = 0x80400000; // KCB
static const NSInteger FH_KCB_INDEX = 16;
static const NSInteger FH_KCB_CREDITSUMMARY = (FH_KCB | 0x00000001); //신용요약

static const NSInteger FH_CH = 0x80500000; //보험개발원 카히스토리
static const NSInteger FH_CH_INDEX = 17;
static const NSInteger FH_CH_CARHISTORY = (FH_CH | 0x00000001); //자동차사고이력조회

static const NSInteger FH_CONTI = 0x80600000; //생명보험협회 내보험 찾아줌
static const NSInteger FH_CONTI_INDEX = 18;
static const NSInteger FH_CONTI_INSUSEARCH = (FH_CONTI | 0x00000001); //내보험찾아줌

static const NSInteger FH_SCJ = 0x01100000;
static const NSInteger FH_SCJ_INDEX = 19;
static const NSInteger FH_SCJ_DEUNGBON = (FH_SCJ | 0x00000001); //제적등본(해당호적전체)
static const NSInteger FH_SCJ_CHOBON = (FH_SCJ | 0x00000002); //제적초본(호주-당사자)

static const NSInteger FH_FSS100 = 0x01200000; //금감원 통합연금 포털
static const NSInteger FH_FSS100_INDEX = 20;
static const NSInteger FH_FSS100_PENSEARCH = (FH_FSS100 | 0x00000001); //내연금 조회

/* 문서 발급 결과 에러 코드 */
static const NSInteger FH_E_N_SERVER_CONNECT = 0x00000001; //서버연결에 실패. 단말 네트웍 또는 서버 서비스가 죽음
static const NSInteger FH_E_N_AUTH_FAIL = 0x00000002; //로그인이나 사용자 인증에 실패. 입력값이 바르지 않거나 사용자 등록이 되어있지 않음
static const NSInteger FH_E_N_SERVICE_TIME = 0x00000003; //서비스시간이 아님
static const NSInteger FH_E_N_APPLIED = 0x00000004; //사용자가 발급 조건에 적합하지 않음
static const NSInteger FH_E_N_INFO_EXTRACT = 0x00000005; //정보추출에 실패
static const NSInteger FH_E_N_ESSENTIAL_INFO = 0x00000006; //필수정보 누락
static const NSInteger FH_E_F_DECOMPRESS = 0x00000007;	 //압축해제 실패
static const NSInteger FH_E_F_DECRYPT = 0x00000008;		   //복호화 실패
static const NSInteger FH_E_F_SM_CONNECT = 0x00000009; //세션서버 연결 실패(xgate, Random, Time 서버등)
static const NSInteger FH_E_F_SSO = 0x0000000A; // SSO 실패(건보, 국세청 등 여러 도메인 넘나들을 때 발생)
static const NSInteger FH_E_F_PROTOCOL = 0x0000000B; //서버의 응답 내용이 변경됨
static const NSInteger FH_E_F_ENCRYPT = 0x0000000C;   //암호화 실패
static const NSInteger FH_E_F_MALFORMAT = 0x0000000D; //메시지 형태 오류
static const NSInteger FH_E_F_REGISTRATION = 0x0000000E; //회원등록 실패
static const NSInteger FH_E_F_ROLE_CHANGE = 0x0000000F; //조회자격 변경(개인 -> 사업자)
static const NSInteger FH_E_F_TIME_OVER = 0x00000010; //시간 지연으로 발급이 불가능한 상태 ... 나중에 재시도
static const NSInteger FH_E_F_MEM_ALLOC = 0x00000011; //메모리 할당 실패
static const NSInteger FH_E_F_CONNECT_INIT_FAIL = 0x00000012; //웹연결 초기화 실패
static const NSInteger FH_E_F_CERTTYPE_MISMATCH = 0x00000013; //조회된 인증서가 요청한 인증서와 다름
static const NSInteger FH_E_F_CERT_NOT_EXIST = 0x00000014; //인증서가 조회지 않음
static const NSInteger FH_E_F_WRONG_ADDRESS = 0x00000015; //잘못된 주소
static const NSInteger FH_E_F_LICENSE_CHECK = 0x00000016; //라이선스 검증 실패
static const NSInteger FH_E_F_NO_LICENSE = 0x00000017; //라이선스 값이 존재하지 않음
static const NSInteger FH_E_F_LICENSE_EXPIRED = 0x00000018; //라이선스 기간 만료
static const NSInteger FH_E_F_NO_CONTENT = 0x00000019; //조회결과 내용이 없음
static const NSInteger FH_E_F_SSO_FAIL = 0x0000001A; // SSO 실패한 경우
static const NSInteger FH_E_F_DIFF_NAME = 0x0000001B; //주민등록상 이름과 호적상 이름이 다름
static const NSInteger FH_E_F_WRONG_VALUE = 0x0000001C; //입력값 오류(이름이 다르거나 ...)
static const NSInteger FH_E_F_LOCKED = 0x0000001D; //오류나 개인의 신청으로 잠김
static const NSInteger FH_E_F_TARGET_N_EXIST = 0x0000001E; //발급대상이 존재하지 않음
static const NSInteger FH_E_F_WRONG_RESPONSE = 0x0000001F; //발급 결과가 바르지 않음
static const NSInteger FH_E_F_ADV_CARD = 0x00000020; //신용카드 본인인증 실패 - 사용할 수 없는 선불카드입니다
static const NSInteger FH_E_F_BC_CARD = 0x00000021; //신용카드 본인인증 실패 - BC카드는 지원하지 않습니다
static const NSInteger FH_E_F_SVR_CARD = 0x00000022; //신용카드 본인인증 실패 - 지원불가한 신용카드입니다
static const NSInteger FH_E_F_WRONG_ACCESS = 0x00000023; //본인인증 실패 - 잘못된 접근
static const NSInteger FH_E_F_CAPTCHA_01 = 0x00000024; //휴대폰 본인인증 실패 - 세션값이 유효하지 않습니다
static const NSInteger FH_E_F_CAPTCHA_02 = 0x00000025; //휴대폰 본인인증 실패 - 문자값이 유효하지 않습니다
static const NSInteger FH_E_F_CAPTCHA_03 = 0x00000026; //휴대폰 본인인증 실패 - 문자입력값 체크 중 오류가 발생했습니다
static const NSInteger FH_E_F_CAPTCHA_04 = 0x00000027; //휴대폰 본인인증 실패 - 입력된 자동인증방지문자가 틀립니다
static const NSInteger FH_E_F_PHONE_AUTH = 0x00000028; //휴대폰 본인인증 실패 - 인증번호 발송요청 실패
static const NSInteger FH_E_F_SAUP_CLOSE = 0x00000030; //사업자 폐업
static const NSInteger FH_E_F_SAUP_REST = 0x00000031;  //사업자 휴업
static const NSInteger FH_E_F_NO_MORE_CONTRACT = 0x00000032; //계약 해지로 옴니독 서비스 중단
static const NSInteger FH_E_F_CERT_EXFIRED = 0x00000033; //인증서 만료
static const NSInteger FH_E_F_CERT_REVOKED = 0x00000034; //인증서 폐기
static const NSInteger FH_E_N_CERT_ACCEPTIBLE = 0x00000035; //인증서가 적절하지 않음
static const NSInteger FH_E_F_VID_MATCH = 0x00000036; //식별번호 검증 실패
static const NSInteger FH_E_F_WRONG_TYPE = 0x00000037; //문서 지정 값 오류
static const NSInteger FH_E_F_OVERTRY = 0x00000038;	//시도횟수 초과
static const NSInteger FH_E_F_REQUEST = 0x00000039;	//요청오류
static const NSInteger FH_E_F_MW24_CAPTCHA = 0x0000003A; //민원24 캡차 오류
static const NSInteger FH_E_F_ARREARS = 0x0000003B;		 //체납금액 존재
static const NSInteger FH_E_F_LUA_CRASH = 0x00000040;			//루아에서 크래시 발생
static const NSInteger FH_E_F_LUA_LOWMEM = 0x00000041;		//루아에서 메모리부족으로 종료
static const NSInteger FH_E_F_LUA_ERRERR = 0x00000042;		//루아에서 에러핸들링 실패
static const NSInteger FH_E_F_LUA_ERRGCMM = 0x00000043;		//루아에서 가비지컬랙션 실패
static const NSInteger FH_E_F_LUA_LOADFAIL = 0x00000044;		//루아스크립트 로드 실패
static const NSInteger FH_E_F_MANY_CONTENT = 0x00000045;		//결과 갯수 초과

/* 인증서 정보 필드 아이디 */
static const NSInteger CERT_SERIAL = 0x00000001; //인증서의 시리얼
static const NSInteger CERT_NOTBEFORE = 0x00000002; //인증서의 유효기간중 시작일
static const NSInteger CERT_NOTAFTER = 0x00000003; //인증서의 유효기간중 종료일
static const NSInteger CERT_ISSUER = 0x00002000;	 //인증서 발급자
static const NSInteger CERT_SUBJECT = 0x00004000;	//인증서 소유자
static const NSInteger CERT_CERTPOLICY = 0x00010000; //인증서 정책
static const NSInteger CERT_CRLDP = 0x00100000;		 // CRL 확인

@interface Err : NSObject {
    NSInteger code;
    NSInteger line;
    NSString* msg;
}

@property (nonatomic) NSInteger code;
@property (nonatomic) NSInteger line;
@property (strong, nonatomic) NSString* msg;

-(id)init;
-(id)init:(NSInteger)code
	 line:(NSInteger)line
	  msg:(NSString*)msg;

@end

@interface FHOmniDoc : NSObject

- (instancetype)init;

- (void *)CertRequestStructInit:(int)count;

- (NSData *)CertRequestStructGetCert:(void *)handle
							   count:(int)count
								type:(NSInteger)type;

- (NSString *)CertRequestStructGetAddr:(void *)handle count:(int)count;

- (NSInteger)CertRequestStructGetErr:(void *)handle
							   count:(int)count
								type:(NSInteger)type;

-(Err*) CertRequestStructGetErrs:(void*)handle
                           count:(int)count
                            type:(NSInteger)type;

-(NSData*) PayinfoCaptcha:(NSString*)certPath
                 password:(NSString*)password
                     rrn1:(NSString*)rrn1
                     rrn2:(NSString*)rrn2;

-(NSData*) PayinfoCaptcha:(NSString*)certPath
             DataPassword:(NSData*)password
                     rrn1:(NSString*)rrn1
                     rrn2:(NSString*)rrn2;

-(NSData*) PayinfoCaptcha:(NSData*)certData
                  keyData:(NSData*)keyData
                 password:(NSString*)password
                     rrn1:(NSString*)rrn1
                     rrn2:(NSString*)rrn2;

-(NSData*) PayinfoCaptcha:(NSData*)certData
                  keyData:(NSData*)keyData
             DataPassword:(NSData*)password
                     rrn1:(NSString*)rrn1
                     rrn2:(NSString*)rrn2;

-(int) PayinfoAuth:(NSString*)captcha
              name:(NSData*)name
             count:(int)count
            handle:(void*)handle;

-(int) PayinfoAuth:(NSString*)captcha
         euckrname:(NSData*)name
             count:(int)count
            handle:(void*)handle;

- (NSString *)CertRequestStructGetErrMsg:(void *)handle
								   count:(int)count
									type:(NSInteger)type;

- (NSString *)CertRequestStructGetQS:(void *)handle
							   count:(int)count
								type:(NSInteger)type;

- (NSInteger)CertRequestStructSet:(void *)handle
							count:(int)count
							 type:(NSInteger)type
						  option1:(NSString *)opt1
						  option2:(NSString *)opt2
						  option3:(NSString *)opt3
						  option4:(NSString *)opt4
						  option5:(NSString *)opt5
						  option6:(NSString *)opt6
						  option7:(NSString *)opt7
						  option8:(NSString *)opt8
						  option9:(NSString *)opt9
						 option10:(NSString *)opt10
						 language:(NSString *)lang;

- (NSInteger)CertRequestStructTerm:(void *)handle count:(int)count;

- (NSString *)EncryptParams:(NSData *)param;

- (NSString *)MW24FindAddress:(NSString *)si
						   gu:(NSString *)gu
					 restAddr:(NSString *)restAddr;

- (NSData *)MW24LoadCaptcha:(void *)handle count:(int)count;

- (NSData *)MW24LoadCaptchaAudio:(void *)handle count:(int)count;

- (NSData *)MW24ReloadCaptcha:(void *)handle count:(int)count;

- (NSData *)MW24ReloadCaptchaAudio:(void *)handle count:(int)count;

- (NSInteger)MW24SetCaptcha:(void *)handle
					  count:(int)count
					captcha:(NSString *)captcha;

- (NSArray *)Credit4uPhoneCaptcha:(void *)handle
							count:(int)count
							 name:(NSString *)name
							 rrn1:(NSString *)rrn1
							 rrn2:(NSString *)rrn2
								t:(NSString *)t;

- (NSArray *)Credit4uPhoneCaptcha:(void *)handle
							count:(int)count
					  encodedname:(NSData *)name
							 rrn1:(NSString *)rrn1
							 rrn2:(NSString *)rrn2
								t:(NSString *)t;

- (int)Credit4uPhoneAuth:(void *)handle
				   count:(int)count
					name:(NSString *)name
					rrn1:(NSString *)rrn1
					rrn2:(NSString *)rrn2
					   t:(NSString *)t
				 captcha:(NSString *)captcha;

- (int)Credit4uPhoneAuth:(void *)handle
				   count:(int)count
			 encodedname:(NSData *)name
					rrn1:(NSString *)rrn1
					rrn2:(NSString *)rrn2
					   t:(NSString *)t
				 captcha:(NSString *)captcha;

- (NSString *)Credit4uCardAuth:(void *)handle
						 count:(int)count
						  name:(NSString *)name
						  rrn1:(NSString *)rrn1
						  rrn2:(NSString *)rrn2;

- (NSString *)Credit4uCardAuth:(void *)handle
						 count:(int)count
				   encodedname:(NSData *)name
						  rrn1:(NSString *)rrn1
						  rrn2:(NSString *)rrn2;

- (void)Credit4uReset;

- (NSArray *)CertIssue:(NSString *)certPath
			  password:(NSString *)password
				  name:(NSString *)name
				  rrn1:(NSString *)rrn1
				  rrn2:(NSString *)rrn2
				 count:(int)count
				handle:(void *)handle
			  progress:(int *)progress
				  stop:(int *)stop;

- (NSArray *)CertIssue:(NSString *)certPath
		  DataPassword:(NSData *)password
				  name:(NSString *)name
				  rrn1:(NSString *)rrn1
				  rrn2:(NSString *)rrn2
				 count:(int)count
				handle:(void *)handle
			  progress:(int *)progress
				  stop:(int *)stop;

- (NSArray *)CertIssue:(NSData *)certData
			   keyData:(NSData *)keyData
			  password:(NSString *)password
				  name:(NSString *)name
				  rrn1:(NSString *)rrn1
				  rrn2:(NSString *)rrn2
				 count:(int)count
				handle:(void *)handle
			  progress:(int *)progress
				  stop:(int *)stop;

- (NSArray *)CertIssue:(NSData *)certData
			   keyData:(NSData *)keyData
		  DataPassword:(NSData *)password
				  name:(NSString *)name
				  rrn1:(NSString *)rrn1
				  rrn2:(NSString *)rrn2
				 count:(int)count
				handle:(void *)handle
			  progress:(int *)progress
				  stop:(int *)stop;

- (NSArray *)CertIssueRetry:(NSString *)certPath
              password:(NSString *)password
                  name:(NSString *)name
                  rrn1:(NSString *)rrn1
                  rrn2:(NSString *)rrn2
                 count:(int)count
                handle:(void *)handle
              progress:(int *)progress
                  stop:(int *)stop;

- (NSArray *)CertIssueRetry:(NSString *)certPath
          DataPassword:(NSData *)password
                  name:(NSString *)name
                  rrn1:(NSString *)rrn1
                  rrn2:(NSString *)rrn2
                 count:(int)count
                handle:(void *)handle
              progress:(int *)progress
                  stop:(int *)stop;

- (NSArray *)CertIssueRetry:(NSData *)certData
               keyData:(NSData *)keyData
              password:(NSString *)password
                  name:(NSString *)name
                  rrn1:(NSString *)rrn1
                  rrn2:(NSString *)rrn2
                 count:(int)count
                handle:(void *)handle
              progress:(int *)progress
                  stop:(int *)stop;

- (NSArray *)CertIssueRetry:(NSData *)certData
               keyData:(NSData *)keyData
          DataPassword:(NSData *)password
                  name:(NSString *)name
                  rrn1:(NSString *)rrn1
                  rrn2:(NSString *)rrn2
                 count:(int)count
                handle:(void *)handle
              progress:(int *)progress
                  stop:(int *)stop;

- (NSInteger)CertSign:(NSString *)certPath
			 password:(NSString *)password
				count:(int)count
			   handle:(void *)handle;

- (NSInteger)CertSign:(NSString *)certPath
		 DataPassword:(NSData *)password
				count:(int)count
			   handle:(void *)handle;

- (NSInteger)CertSign:(NSData *)certData
			  keyData:(NSData *)keyData
			 password:(NSString *)password
				count:(int)count
			   handle:(void *)handle;

- (NSInteger)CertSign:(NSData *)certData
			  keyData:(NSData *)keyData
		 DataPassword:(NSData *)password
				count:(int)count
			   handle:(void *)handle;

- (NSString *)GetSaupjangList:(NSString *)certPath
					 password:(NSString *)password
						 name:(NSString *)name
						 rrn1:(NSString *)rrn1
						 rrn2:(NSString *)rrn2
					 progress:(int *)progress
						 stop:(int *)stop;

- (NSString *)GetSaupjangList:(NSString *)certPath
				 DataPassword:(NSData *)password
						 name:(NSString *)name
						 rrn1:(NSString *)rrn1
						 rrn2:(NSString *)rrn2
					 progress:(int *)progress
						 stop:(int *)stop;

- (NSString *)GetSaupjangList:(NSData *)certData
					  keyData:(NSData *)keyData
					 password:(NSString *)password
						 name:(NSString *)name
						 rrn1:(NSString *)rrn1
						 rrn2:(NSString *)rrn2
					 progress:(int *)progress
						 stop:(int *)stop;

- (NSString *)GetSaupjangList:(NSData *)certData
					  keyData:(NSData *)keyData
				 DataPassword:(NSData *)password
						 name:(NSString *)name
						 rrn1:(NSString *)rrn1
						 rrn2:(NSString *)rrn2
					 progress:(int *)progress
						 stop:(int *)stop;

- (NSArray *)ParseAddress:(NSString *)fullAddress;

- (NSArray *)GetAddress:(NSString *)certPath
			   password:(NSString *)password
				   name:(NSString *)name
				   rrn1:(NSString *)rrn1
				   rrn2:(NSString *)rrn2
			   progress:(int *)progress
				   stop:(int *)stop;

- (NSArray *)GetAddress:(NSString *)certPath
		   DataPassword:(NSData *)password
				   name:(NSString *)name
				   rrn1:(NSString *)rrn1
				   rrn2:(NSString *)rrn2
			   progress:(int *)progress
				   stop:(int *)stop;

- (NSArray *)GetAddress:(NSData *)certData
				keyData:(NSData *)keyData
			   password:(NSString *)password
				   name:(NSString *)name
				   rrn1:(NSString *)rrn1
				   rrn2:(NSString *)rrn2
			   progress:(int *)progress
				   stop:(int *)stop;

- (NSArray *)GetAddress:(NSData *)certData
				keyData:(NSData *)keyData
		   DataPassword:(NSData *)password
				   name:(NSString *)name
				   rrn1:(NSString *)rrn1
				   rrn2:(NSString *)rrn2
			   progress:(int *)progress
				   stop:(int *)stop;

- (void)OmniDocReset;

- (NSInteger)SetLicense:(NSString *)license;

- (NSInteger)CheckCertPassword:(NSString *)certPath
					  password:(NSString *)password;

- (NSInteger)CheckCertPassword:(NSString *)certPath
				  DataPassword:(NSData *)password;

- (NSInteger)CheckCertPassword:(NSData *)certData
					   keyData:(NSData *)keyData
					  password:(NSString *)password;

- (NSInteger)CheckCertPassword:(NSData *)certData
					   keyData:(NSData *)keyData
				  DataPassword:(NSData *)password;

- (NSInteger)CertValidate:(NSString *)certPath;

- (NSInteger)CertValidateData:(NSString *)certData;

- (NSInteger)CheckRRN:(NSString *)certPath
			 password:(NSString *)password
				 rrn1:(NSString *)rrn1
				 rrn2:(NSString *)rrn2;

- (NSInteger)CheckRRN:(NSString *)certPath
		 DataPassword:(NSData *)password
				 rrn1:(NSString *)rrn1
				 rrn2:(NSString *)rrn2;

- (NSInteger)CheckRRN:(NSData *)certData
			  keyData:(NSData *)keyData
			 password:(NSString *)password
				 rrn1:(NSString *)rrn1
				 rrn2:(NSString *)rrn2;

- (NSInteger)CheckRRN:(NSData *)certData
			  keyData:(NSData *)keyData
		 DataPassword:(NSData *)password
				 rrn1:(NSString *)rrn1
				 rrn2:(NSString *)rrn2;

- (NSString *)CertInfo:(NSString *)certPath fieldId:(int)fieldId;

- (NSString *)CertDataInfo:(NSData *)certData fieldId:(int)fieldId;

- (NSString *)GetLibraryVersion;

@end
