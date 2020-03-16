//
//  BundleExtension.swift
//
//  Created by OSX on 7/31/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import Foundation

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
    
    static var versionInfo: String? {
        guard let version = Bundle.main.releaseVersionNumber,
            let build = Bundle.main.buildVersionNumber else {
                return nil
        }
        return "Version \(version)(\(build))"
    }
}
