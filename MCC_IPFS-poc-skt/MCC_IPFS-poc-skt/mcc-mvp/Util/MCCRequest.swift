//
//  FRMShareInstance.swift
//  FreeMarket
//
//  Created by JeongInkyu on 2016. 8. 24..
//  Copyright © 2016년 finger. All rights reserved.
//

import Foundation
import Alamofire
import AES256CBC

public typealias successBlock = (_ responseData : Any? ) -> Void
public typealias failedBlock = (_ error : Error) -> Void

/*
 등록 및 수정은
 http://13.125.243.4:3000/invoke
 POST 메소드로 http 요청 헤더에서  Content-Type:application/json
 
 {
 "key":"test@test.net",
 "value":"dfgrety43"
 }
 */

enum MCCError: Error {
    case unknownError
    case connectionError
    case invalidCredentials
    case invalidRequest
    case notFound
    case invalidResponse
    case serverError
    case serverUnavailable
    case timeOut
    case unsuppotedURL
}

let APIAddressInvoke = "http://52.79.105.204:3000/system/invoke"
let APIAddressQuery = "http://52.79.105.204:3000/system/query"

let APIAddressFinc = "http://211.233.91.26:27986/mcc/parse.do"
//http://192.168.0.182:8080/mcc/parse.do?drmData=xxxxx

class MCCRequest: NSObject {
    
    static var Instance = MCCRequest()
    
    var _successBlock : (() -> Void)? = nil
    var _failedBlock : ((_ error : NSError) -> Void)? = nil
    

    static func checkErrorCode(_ errorCode: Int) -> MCCError {
        switch errorCode {
        case 400:
            return .invalidRequest
        case 401:
            return .invalidCredentials
        case 404:
            return .notFound
        case 500:
            return .serverError
        //bla bla bla
        default:
            return .unknownError
        }
    }
    
    internal func requestInvoke(parameter : [String:String], success : successBlock?, failed: failedBlock?){
        var request = URLRequest(url: URL(string:APIAddressInvoke)!)
        request.httpMethod = "POST"
        
        let jsonData = try? JSONSerialization.data(withJSONObject: parameter, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        
        request.httpBody = jsonString?.data(using: .utf8, allowLossyConversion: true)
        request.addValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        
        Alamofire.request(request).responseData { response in
            
            guard response.error == nil else {
                if failed != nil {
                    failed!(response.error!)
                }
                return
            }
            if response.response?.statusCode == 200
            {
                let data = (response.value)
                do{
                    if success != nil {
                        let json =  try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                        if let jsonDictionary =  json as? Dictionary<String,Any> {
                            success!(jsonDictionary as Any)
                        }
                        else if let jsonArray =  json as?  [Any] {
                            success!(jsonArray as Any)
                        }
                        else{
                            print(json)
                            print("Type is String")
                        }
                    }
                }catch let error{
                    print(error.localizedDescription)
                    if failed != nil {
                        failed!(MCCRequest.checkErrorCode((response.response?.statusCode)!))
                    }
                }
            }
            else{
                if failed != nil {
                    failed!(MCCRequest.checkErrorCode((response.response?.statusCode)!))
                }
                return
            }
        }
    }
    
    
    internal func requestQuery(parameter : [String:String], success : successBlock?, failed: failedBlock?){
        var request = URLRequest(url: URL(string: APIAddressQuery)!)

        request.httpMethod = "POST"
        
        let jsonData = try? JSONSerialization.data(withJSONObject: parameter, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        
        request.httpBody = jsonString?.data(using: .utf8, allowLossyConversion: true)
//        request.httpBody = jsonString?.data(using: .utf8)
        request.addValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
//          request.addValue("application/json", forHTTPHeaderField: "Accept")
        Alamofire.request(request).responseData { response in
            
            guard response.error == nil else {
                if failed != nil {
                    failed!(response.error!)
                }
                return
            }
            if response.response?.statusCode == 200
            {
                let data = (response.value)
                do{
                    if success != nil {
                        
                        let json =  try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                        
                        if let jsonDictionary =  json as? Dictionary<String,Any> {
                            success!(jsonDictionary as Any)
                        }
                        else if let jsonArray =  json as?  [Any] {
                            success!(jsonArray as Any)
                        }
                        else{
                            success!([])
                        }
                    }
                }catch let error{
                    print(error.localizedDescription)
                    if failed != nil {
                        failed!(MCCRequest.checkErrorCode((response.response?.statusCode)!))
                    }
                }
            }
            else{
                if failed != nil {
                    failed!(MCCRequest.checkErrorCode((response.response?.statusCode)!))
                }
                return
            }
        }
    }
    
    internal func requestQueryString(parameter : [String:String], success : successBlock?, failed: failedBlock?){
        var request = URLRequest(url: URL(string: APIAddressQuery)!)
        
        request.httpMethod = "POST"
        
        let jsonData = try? JSONSerialization.data(withJSONObject: parameter, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        
        request.httpBody = jsonString?.data(using: .utf8, allowLossyConversion: true)
        //        request.httpBody = jsonString?.data(using: .utf8)
        request.addValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        //          request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 5
        Alamofire.request(request).responseData { response in
            
            guard response.error == nil else {
                if failed != nil {
                    failed!(response.error!)
                }
                return
            }
            if response.response?.statusCode == 200
            {
                let data = (response.value)
                do{
                    if success != nil {
                        
                        let string =  String(decoding: data!, as: UTF8.self)
                        success!(string)
                    }
                }catch let error{
                    print(error.localizedDescription)
                    if failed != nil {
                        failed!(MCCRequest.checkErrorCode((response.response?.statusCode)!))
                    }
                }
            }
            else{
                if failed != nil {
                    failed!(MCCRequest.checkErrorCode((response.response?.statusCode)!))
                }
                return
            }
        }
    }
    
    
    internal func requestFinc(parameters : [String:Any], success : successBlock?, failed: failedBlock?){
        
//        let jsonData = try? JSONSerialization.data(withJSONObject: parameters, options: [])
//        let jsonString = String(data: jsonData!, encoding: .utf8)
//        let urlWithParams = APIAddressFinc + "?drmData=" + jsonString
//        urlWithParams = (urlWithParams.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))!
//        let myUrl = URL(string: urlWithParams)
//        var request = URLRequest(url: myUrl!)
//        request.httpMethod = "GET"

//
        var request = URLRequest(url: URL(string: APIAddressFinc)!)

        request.httpMethod = "POST"
        let jsonData = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        request.httpBody = jsonString?.data(using: .utf8)
        request.addValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        Alamofire.request(request).responseData { response in
            
            guard response.error == nil else {
                if failed != nil {
                    failed!(response.error!)
                }
                return
            }
            if response.response?.statusCode == 200
            {
                let data = (response.value)
                do{
                    if success != nil {
                        
                        let json =  try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                        
                        if let jsonDictionary =  json as? Dictionary<String,Any> {
                            success!(jsonDictionary as Any)
                        }
                        else if let jsonArray =  json as?  [Any] {
                            success!(jsonArray as Any)
                        }
                        else{
                            success!([])
                        }
                        
                    }
                }catch let error{
                    print(error.localizedDescription)
                    if failed != nil {
                        failed!(MCCRequest.checkErrorCode((response.response?.statusCode)!))
                    }
                }
            }
            else{
                if failed != nil {
                    failed!(MCCRequest.checkErrorCode((response.response?.statusCode)!))
                }
                return
            }
        }
    }
    
}
