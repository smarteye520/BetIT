//
//  KeychainManager.swift
//  BetIT
//
//  Created by OSX on 6/12/19.
//  Copyright © 2019 Majestyk Apps. All rights reserved.
//

import Foundation
import KeychainSwift
import ObjectMapper
import SwiftyJSON

class KeychainManager {
    static let shared = KeychainManager()
    //KeyChain
    fileprivate let keychain = KeychainSwift(keyPrefix: "stored_data")
    
    static func setBool(value: Bool, for key: String) {
        shared.keychain.set(value, forKey: key)
    }
    
    static func getBool(for key: String) -> Bool{
        return shared.keychain.getBool(key) ?? false
    }
    
    static func setString(value: String?, for key: String) {
        shared[key] = value
    }
    
    static func getString(for key: String) -> String?{
        return shared[key]
    }
    
    static func setData(value: Data?, for key: String) {
        guard let data = value else {
            shared.keychain.delete(key)
            return
        }
        shared.keychain.set(data, forKey: key)
    }
    
    static func getData(for key: String) -> Data?{
        return shared.keychain.getData(key)
    }
    
    static func setInt(value: Int?, for key: String) {
        if let value = value {
            shared[key] = "\(value)"
        }
        else {
            shared[key] = nil
        }
    }
    
    static func getInt(for key: String) -> Int?{
        if let value = shared[key] {
            return Int(value)
        }
        return nil
    }
    
    static func setDict(value: [String: Any], for key: String) {
        shared[key] = JSON(value).rawString()
    }
    
    static func getDict(for key: String) -> [String: Any]? {
        guard let jsonString = shared[key] else {
            return nil
        }        
        return JSON.init(parseJSON: jsonString).dictionaryObject
    }
    
    static func setArray(value: [Any], for key: String) {
        shared[key] = JSON(value).rawString()
    }
    
    static func getArray(for key: String) -> [Any]? {
        guard let jsonString = shared[key] else {
            return nil
        }
        return JSON.init(parseJSON: jsonString).arrayObject
    }
    
    subscript(key: String) -> String? {
        get {
            return keychain.get(key)
        }
        set {
            if let value = newValue {
                keychain.set(value, forKey: key)
            }
            else {
                keychain.delete(key)
            }
        }
    }
    
    static func clear() {
        shared.keychain.clear()
    }
}
