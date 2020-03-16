//
//  PrimitiveExtension.swift
//
//  Created by OSX on 7/31/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import Foundation

extension Array {
    /// Picks `n` random elements (partial Fisher-Yates shuffle approach)
    subscript (randomPick n: Int) -> [Element] {
        var copy = self
        for i in stride(from: count - 1, to: count - n - 1, by: -1) {
            copy.swapAt(i, Int(arc4random_uniform(UInt32(i + 1))))
        }
        return Array(copy.suffix(n))
    }
}

extension NSObject {
    class var classFullName: String { return NSStringFromClass(self)   }
    
    class var className: String {
        return (classFullName as NSString).pathExtension
    }
}

