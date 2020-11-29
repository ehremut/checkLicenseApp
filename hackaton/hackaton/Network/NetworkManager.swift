//
//  NetworkManager.swift
//  hackaton
//
//  Created by andarbek on 28.11.2020.
//

import Foundation
import Alamofire
import PromiseKit
import SwiftyJSON

class NetworkManager {
    
    func performRequest(_ request: NetworkRequest, validStatusCodes: [Int] = (200...299).map({$0})) -> Promise<ASRequest> {

        return Promise { [weak self] promise in
            AF.request(request.url!,
                       method: .post, parameters: request.parameters, encoding: JSONEncoding.default)
                .responseData(completionHandler: { (response) in
                    if validStatusCodes.contains(response.response?.statusCode ?? 0) {
                        let res = ASRequest(code: .access, data: response.data)
                        promise.fulfill(res)
                    } else {
                        let error = response.response?.statusCode
                        let errType: ErrorType?
                        switch error {
                        case 400:
                            errType = .wrongPassword
                        case 401:
                            errType = .notRegistered
                        default:
                            errType = .unknown
                        }
                        promise.fulfill(ASRequest(code: .error, error: errType))
                    }
                    
                })
            //requestHandler?(request)
        }
    }
    
    func performSend(_ request: NetworkRequest, validStatusCodes: [Int] = (200...299).map({$0})) -> Promise<ASRequest> {
        return Promise { [weak self] promise in
            AF.request(request.url,
                       method: .post, parameters: Constant.sendParam, encoding: JSONEncoding.default)
                .responseData(completionHandler: { (response) in
                    if validStatusCodes.contains(response.response?.statusCode ?? 0) {
                        let res = ASRequest(code: .access, data: response.data)
                        promise.fulfill(res)
                    } else {
                        let error = response.response?.statusCode
                        let errType: ErrorType?
                        switch error {
                        case 400:
                            errType = .wrongPassword
                        case 401:
                            errType = .notRegistered
                        default:
                            errType = .unknown
                        }
                        promise.fulfill(ASRequest(code: .error, error: errType))
                    }
                    
                })
            //requestHandler?(request)
        }
    }
    
}
