//
//  NetworkService.swift
//  hackaton
//
//  Created by andarbek on 28.11.2020.
//

import Foundation
import Alamofire
import PromiseKit
import SwiftyJSON

class NetworkService: NetworkManager {
    var res = ASRequest()
    func getJson(url: String) -> Promise<ASRequest> {
        return Promise { [unowned self] promise in
            let request = NetworkRequest.check(url: url, method: .post, parameters: Constant.parametersCheck)
            self.performRequest(request).done({ (data) in
                switch data.code {
                case .access:
                    res.code = data.code
                    //parseJson(data: data.data!)
                    promise.fulfill(self.res)
                case .error:
                    res.code = data.code
                    res.error = data.error ?? ErrorType.unknown
                    promise.fulfill(self.res ?? ASRequest(code: .error))
                case .none:
                    res.code = data.code ?? ASRequestType.error
                    res.error = data.error ?? ErrorType.unknown
                    promise.fulfill(self.res ?? ASRequest(code: .error))
                }
               // promise.fulfill(json)
            })
            
        }
    }
    
    func parseJson(data: Data){
        guard let jsondata = try? JSON(data: data) else {return}
        res.json = jsondata
        guard let id = jsondata["User"]["Id"].int else {return}
        guard let token = jsondata["User"]["Token"].string else {return}
        guard let username = jsondata["User"]["Username"].string else {return}
        guard let mobile = jsondata["User"]["Mobile"].string else {return}
        guard let address = jsondata["User"]["Address"].string else {return}
        guard let email = jsondata["User"]["Email"].string else {return}
        let coord = Coordinate(latitude: jsondata["User"]["AddressCoord"]["Latitude"].double!, longitude: jsondata["User"]["AddressCoord"]["Longitude"].double!)
        
        let user = User(id: id, token: token, username: username, mobile: mobile, address: address, email: email, coord: coord)
        self.res.user = user
    }
    
    func sendComment(url: String) -> Promise<ASRequest> {
        return Promise { [unowned self] promise in
            print(Constant.sendParam)
            let request = NetworkRequest.send(url: url, method: .post, parameters: Constant.sendParam)
            self.performSend(request).done({ (data) in
                switch data.code{
                case .access:
                    res.code = data.code
                    parseJson(data: data.data ?? Data())
                    promise.fulfill(self.res)
                case .error:
                    res.code = data.code
                    res.error = data.error ?? ErrorType.unknown
                    promise.fulfill(self.res ?? ASRequest(code: .error))
                case .none:
                    res.code = data.code ?? ASRequestType.error
                    res.error = data.error ?? ErrorType.unknown
                    promise.fulfill(self.res ?? ASRequest(code: .error))
                }
               // promise.fulfill(json)
            })
            
        }
    }
    
}
