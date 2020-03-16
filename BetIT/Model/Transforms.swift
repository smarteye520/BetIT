//
//  Transforms.swift
//  BetIT
//
//  Created by OSX on 7/31/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import Foundation
import ObjectMapper

extension DateTransform {
    static let shared = DateTransform()
}

extension URLTransform {
    static let shared = URLTransform()
}

open class DateFormatTransform: TransformType {
    static let shared = DateFormatTransform()
    public typealias Object = Date
    public typealias JSON = String
    var format: String = "yyyy-MM-dd"
    
    init(_ format: String = "yyyy-MM-dd") {
       self.format = format
    }
    
    open func transformFromJSON(_ value: Any?) -> Date? {
        if let dateStr = value as? String {
            return Date(dateString: dateStr, format: self.format)
        }
        return nil
    }
    
    open func transformToJSON(_ value: Date?) -> String? {
        if let date = value {
            return date.string(withFormat: self.format)
        }
        return nil
    }
}

open class StringArrayTransform: TransformType {
    static let shared = StringArrayTransform()
    public typealias Object = [String]
    public typealias JSON = String

    open func transformFromJSON(_ value: Any?) -> [String]? {
        if let value = value as? String {
            let data = value.data(using: .utf8)!
            guard let array = try? JSONDecoder().decode([String].self, from: data) else {
                return nil
            }
            return array
        }
        return nil
    }
    
    open func transformToJSON(_ value: [String]?) -> String? {
        if let value = value {
            guard let data = try? JSONEncoder().encode(value) else {
                return nil
            }
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}

open class IntTransform: TransformType {
    static let shared = IntTransform()
    public typealias Object = Int
    public typealias JSON = Any
    
    open func transformFromJSON(_ value: Any?) -> Object? {
        guard let value = value else {
            return nil
        }
        
        if value is String {
            return Int(value as! String)
        }
        else if value is Int {
            return (value as! Int)
        }
        return nil
    }
    
    open func transformToJSON(_ value: Object?) -> JSON? {
        if let value = value {
            return "\(value)"
        }
        return nil
    }
}

open class BoolTransform: TransformType {
    static let shared = BoolTransform()
    public typealias Object = Bool
    public typealias JSON = Any
    
    open func transformFromJSON(_ value: Any?) -> Object? {
        guard let value = value else {
            return nil
        }
        
        if value is String {
            let boolStr = (value as! String).lowercased()
            return boolStr == "true" || boolStr == "1"
        }
        else if value is Bool {
            return (value as! Bool)
        }
        else if value is Int {
            return (value as! Int) != 0
        }
        return nil
    }
    
    open func transformToJSON(_ value: Object?) -> JSON? {
        if let value = value {
            return value ? "true" : "false"
        }
        return nil
    }
}
