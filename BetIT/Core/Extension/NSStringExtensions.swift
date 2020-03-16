//
//  NSStringExtensions.swift
//
//  Created by OSX on 7/31/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import Foundation

extension NSString{
    func decodeBase64()->String?{
        let data = Data(base64Encoded: self as String, options: NSData.Base64DecodingOptions(rawValue: 0))
        return String(data: data!, encoding: String.Encoding.utf8)!
    }
    
    func encodeBase64()->String?{
        let data = self.data(using: String.Encoding.utf8.rawValue)
        return (data?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0)))!
    }
}
