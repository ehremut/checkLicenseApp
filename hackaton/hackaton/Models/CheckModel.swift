//
//  CheckModel.swift
//  hackaton
//
//  Created by andarbek on 29.11.2020.
//

import Foundation
import UIKit

struct AudioModel{
    var artist: String?
    var title: String?
    var licence: Int?
    var link: String?
    var image: UIImage?
}

struct CheckModel {
    var find: AudioModel?
    var similar: [AudioModel]?
}
