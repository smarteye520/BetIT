//
//  Token.swift
//  BetIT
//
//  Created by OSX on 7/31/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import UIKit
import ObjectMapper

class Token: BaseObject {
    var accessToken: String!
    var refreshToken: String!
    
    override func mapping(map: Map) {
        accessToken <- map["access_token"]
        refreshToken <- map["refresh_token"]
    }
}

extension Token {
    static func map(json: Any) -> Token? {
        let mapper = Mapper<Token>()
        if let data = json as? [String: Any], let tokens = data["tokens"]{
            return mapper.map(JSONObject: tokens)
        }
        else {
            return mapper.map(JSONObject: json)
        }
    }
}
