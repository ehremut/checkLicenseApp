//
//  NetworkRequest.swift
//  hackaton
//
//  Created by andarbek on 28.11.2020.
//

import Foundation
import Alamofire

class NetworkRequest{
    
    var url: String!
    var headers: [String: String]!
    var parameters: [String: Any]!
    var method: Alamofire.HTTPMethod!
    var encoding = JSONEncoding.default
    
    required init(url: String, method: Alamofire.HTTPMethod, encoding: JSONEncoding) {
        self.url = url
        self.headers = [String: String]()
        self.parameters = [String: Any]()
        self.method = method
        self.encoding = JSONEncoding.default
    }
    
    
    
    class func create(url: String, method: Alamofire.HTTPMethod) -> Self {
        let request = self.init(url: url, method: method, encoding: JSONEncoding.default)
        //request.withHeader(headers)
        return request
    }
    
    class func check(url: String, method: Alamofire.HTTPMethod, parameters: [String: Any]) -> Self {
        let request = self.init(url: url, method: method, encoding: JSONEncoding.default)
        request.withParam(param: parameters)
        return request
    }
    
    class func login(url: String, method: Alamofire.HTTPMethod, parameters: [String: String]) -> Self {
        let request = self.init(url: url, method: method, encoding: JSONEncoding.default)
        request.withParam(param: parameters)
        return request
    }
    
    class func send(url: String, method: Alamofire.HTTPMethod, parameters: [String: Any]) -> Self {
        let request = self.init(url: url, method: method, encoding: JSONEncoding.default)
        request.withParam(param: parameters)
        return request
    }
    
    class func createWithHeader(url: String, method: Alamofire.HTTPMethod, headers: [String: String]) -> Self {
        let request = self.init(url: url, method: method, encoding: JSONEncoding.default)
        request.withHeader(headers: headers)
        return request
    }
    
    @discardableResult
    func withHeader(headers: [String: String]) -> Self {
        self.headers = headers
        return self
    }
    
    @discardableResult
    func withParam(param: [String: String]) -> Self {
        self.parameters = param
        return self
    }
    
    @discardableResult
    func withParam(param: [String: Any]) -> Self {
        self.parameters = param
        return self
    }
    
}
