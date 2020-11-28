//
//  User.swift
//  hackaton
//
//  Created by andarbek on 28.11.2020.
//

import Foundation

class User {
    var id: Int
    var token: String
    var username: String
    var mobile: String
    var address: String
    var email: String
    var addressCoord: Coordinate

    
    init(id: Int, token: String, username: String, mobile: String, address: String ,email: String, coord: Coordinate){
        self.id = id
        self.token = token
        self.username = username
        self.mobile = mobile
        self.address = address
        self.email = email
        self.addressCoord = coord
    }
}

struct Coordinate{
    var latitude : Double
    var longitude : Double
}
