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
                    parseJson(data: data.data!)
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
    
    
    //    {
    //      "Find": {
    //        "Artist": "string",
    //        "Title": "string",
    //        "Album": "string",
    //        "Licence": "int"
    //      },
    //      "Similar": [
    //        {
    //          "Artist": "string",
    //          "Title": "string",
    //          "Album": "string",
    //          "Licence": "int"
    //        }
    //      ]
    //    }
    //
    //    OpenLicence    = 0
    //    CloseLicence   = 1
    //    UnknownLicence = 2
    
    func parseJson(data: Data){
        guard let jsondata = try? JSON(data: data) else {return}
        res.json = jsondata
        print("\n")
        print(jsondata)
        print("\n")
        var mass = [AudioModel]()
        guard let artist = jsondata["Find"]["artist"].string else {return}
        guard let title = jsondata["Find"]["title"].string else {return}
        guard let licence = jsondata["Find"]["licence"].int else {return}
        guard let link = jsondata["Find"]["link"].string else {return}
        guard let img = jsondata["Find"]["image"].string else {return}
        guard let imgURL = URL(string: img) else {return}
        let similar = jsondata["Similar"].array ?? []
        for i in similar{
            guard let artist = i["artist"].string else {return}
            guard let title = i["title"].string else {return}
            guard let licence = i["licence"].int else {return}
            guard let link = i["link"].string else {return}
            mass.append(AudioModel(artist: artist, title: title, licence: licence, link: link))
        }
        
        
        if let data = try? Data(contentsOf: imgURL) {
            if let image = UIImage(data: data) {
                
                let musics = CheckModel(find: AudioModel(artist: artist, title: title, licence: licence, link: link, image: image), similar: mass)
                self.res.music = musics
            }
            
        }
        
    }
    
    
}


