//
//  CheckModule.swift
//  hackaton
//
//  Created by andarbek on 28.11.2020.
//

import Foundation
import PromiseKit

class CheckModule {
    
    let network = NetworkService()
    
    func check() -> Promise<ASRequest>{
        return Promise{ promise in
        //var res = false
            network.getJson(url: Constant.checkURL).done({ (data) in
            switch data.code{
            case .access:
                promise.fulfill(data)
            case .error:
                promise.fulfill(data)
            case .none:
                promise.fulfill(data)
            }
        }).catch { (error) in
            promise.reject(error)
        }
        
    }
    }
}
