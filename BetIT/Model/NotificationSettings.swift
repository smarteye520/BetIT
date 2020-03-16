//
//  NotificationSettings.swift
//  BetIT
//
//  Created by joseph on 9/10/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import Foundation
import ObjectMapper

internal final class NotificationSettings: Mappable {
    
    var userID: String?
    var occasionalReminders: Bool?
    var requests: Bool?
    var claimed: Bool?
    var disputed: Bool?
    var email: Bool?
    
    var isOccasionalReminders: Bool {
        return occasionalReminders ?? true
    }
    
    var isRequests: Bool {
        return requests ?? true
    }
    
    var isClaimed: Bool {
        return claimed ?? true
    }
    
    var isDisputed: Bool {
        // Default to true
        return disputed ?? true
    }
    
    var isEmail: Bool {
        return email ?? true
    }

    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        userID <- map["userID"]
        occasionalReminders <- map["occasionalReminders"]
        requests <- map["requests"]
        claimed <- map["claimed"]
        disputed <- map["disputed"]
        email <- map["email"]
    }
}
