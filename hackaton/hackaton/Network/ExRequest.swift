//
//  ExRequest.swift
//  hackaton
//
//  Created by andarbek on 28.11.2020.
//

import Foundation
import SwiftyJSON

enum ASRequestType {
    case access
    case error
}

enum ErrorType{
    case wrongPassword
    case notRegistered
    case unknown
}

struct ASRequest {
    var code : ASRequestType?
    var data : Data?
    var error : ErrorType?
    var json : JSON?
    var user : User?
    var music : CheckModel?
}
