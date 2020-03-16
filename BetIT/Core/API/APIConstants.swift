//
//  APIConstant.swift
//  BetIT
//
//  Created by OSX on 7/31/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

/*
import Foundation
import ObjectMapper

struct Environment {
    public static let current: Options = .development
    
    enum Options {
        case development, production
    }
}

struct Paths {
    private static var Base: String {
        get {
            switch Environment.current {
            case .development:
                return "http://betit.com/api/v1"
            case .production:
                return "https://betit.com/api/v1"
            }
        }
    }
    
    struct Token {
        public static let refresh = "\(Base)/refresh-token"
    }
    
    struct Me {
        public static let signIn =  "\(Base)/login"
        public static let signUp =  "\(Base)/signup"
        public static let logOut =  "\(Base)/logout"
        public static let me =      "\(Base)/me"
        public static let profile = "\(Base)/my/profile"
    }
        
    struct Password {
        public static let reset = "\(Base)/password/reset"
    }
}

struct ClientCredentials {
    public static var id: String {
        switch Environment.current {
        case .development:
            return "1"
        case .production:
            return "1"
        }
    }
    public static var secret: String {
        switch Environment.current {
        case .development:
            return "JdsA55BOZC5B5zZxXaSPHNIaEK2Ur7qs3DggCDSA"
        case .production:
            return "JdsA55BOZC5B5zZxXaSPHNIaEK2Ur7qs3DggCDSA"
        }
    }
}

struct ServerResponse: Mappable {
    var success: Bool!
    var message: String!
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        success <- map["success"]
        message <- map["message"]
    }
}
*/
