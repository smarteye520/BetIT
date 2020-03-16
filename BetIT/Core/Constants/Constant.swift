//
//  Constant.swift
//  BetIT
//
//  Created by OSX on 7/31/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import UIKit
import Localize_Swift

struct Constant {
    struct UI {
        static let TAP_BAR_HEIGHT: CGFloat = 60
        static let COMMON_BUTTON_HEIGHT = 40
        static var SCREEN_WIDTH: CGFloat {
            return UIScreen.main.bounds.width
        }
        
        static let ROW_HEIGHT: CGFloat = 40
    }
    
    struct Format {
        static let betTime = "MM • dd • yy     |     hh:mm a"
    }
    
    struct URLs {
        static let termsConditions = "https://betit.us/terms.html"
        static let privacyPolicy = "https://betit.us/privacy.html"
    }
    
    struct Support {
        static let emailAddress = "info@betit.us"
        static let subject = "Support"
    }
}

struct ThirdPartyAPI {
}

struct DataSource {
    static var stateNames: [String] {
        return stateDict.map { $0.1 }.sorted()
    }
    
    static let stateDict: [String : String] = [
        "AK" : "Alaska",
        "AL" : "Alabama",
        "AR" : "Arkansas",
        "AS" : "American Samoa",
        "AZ" : "Arizona",
        "CA" : "California",
        "CO" : "Colorado",
        "CT" : "Connecticut",
        "DC" : "District of Columbia",
        "DE" : "Delaware",
        "FL" : "Florida",
        "GA" : "Georgia",
        "GU" : "Guam",
        "HI" : "Hawaii",
        "IA" : "Iowa",
        "ID" : "Idaho",
        "IL" : "Illinois",
        "IN" : "Indiana",
        "KS" : "Kansas",
        "KY" : "Kentucky",
        "LA" : "Louisiana",
        "MA" : "Massachusetts",
        "MD" : "Maryland",
        "ME" : "Maine",
        "MI" : "Michigan",
        "MN" : "Minnesota",
        "MO" : "Missouri",
        "MS" : "Mississippi",
        "MT" : "Montana",
        "NC" : "North Carolina",
        "ND" : "North Dakota",
        "NE" : "Nebraska",
        "NH" : "New Hampshire",
        "NJ" : "New Jersey",
        "NM" : "New Mexico",
        "NV" : "Nevada",
        "NY" : "New York",
        "OH" : "Ohio",
        "OK" : "Oklahoma",
        "OR" : "Oregon",
        "PA" : "Pennsylvania",
        "PR" : "Puerto Rico",
        "RI" : "Rhode Island",
        "SC" : "South Carolina",
        "SD" : "South Dakota",
        "TN" : "Tennessee",
        "TX" : "Texas",
        "UT" : "Utah",
        "VA" : "Virginia",
        "VI" : "Virgin Islands",
        "VT" : "Vermont",
        "WA" : "Washington",
        "WI" : "Wisconsin",
        "WV" : "West Virginia",
        "WY" : "Wyoming"]
}

struct FirebaseGCM {
    static let LegacyAPIKey = "AIzaSyAePTcnvPf_FyPaFkTboQp6aZbdFUjADkI"
    static let APIKey = "AAAAhs2Sy9o:APA91bG26oLd_6_1triBz_JIZ_UGmp19QhDb7XEOlvz0jQLGppYC6hpFHE0fv3wSsu9ughLnne5WUJTNe9Xd5uKFjzXH9bKuh1Hf5sUthyaKi29VCEM6rcvby-VBFcXFNYDNeoR5JY5D"
}
