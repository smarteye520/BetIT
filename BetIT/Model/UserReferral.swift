//
//  UserReferral.swift
//  BetIT
//
//  Created by joseph on 9/11/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import Foundation
import ObjectMapper

internal final class UserReferral: Mappable {
    var userID: String?
    var referralLink: String?
    var numCredits: Int?
    
    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        userID <- map["userID"]
        referralLink <- map["referralLink"]
        numCredits <- map["numCredits"]
    }
}
