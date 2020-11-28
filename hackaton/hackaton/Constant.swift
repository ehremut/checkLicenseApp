//
//  Constant.swift
//  hackaton
//
//  Created by andarbek on 28.11.2020.
//

import Foundation
import UIKit

class Constant{
    
    
    //static let authURL = "http://jsonplaceholder.typicode.com/posts"
    static let checkURL = "http://192.168.31.44:8080/recognition"
    static let authURL = "http://192.168.31.44:8080/login"
    static let sendCommentURL = "http://192.168.31.44:8080/send-email"
    static let getSpotsURL = "http://192.168.31.44:8080/get-free-space"
    
    static var parametersCheck: [String: String] = [
        "Filename" : "",
        "Sound" : ""
    ]
    
    static var sendParam: [String: Any] = [
        "error_code" : 92 ,
        "comment" : "huhu",
        "email" : "hhaa"
    ]
    
}
