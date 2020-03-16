//
//  PrintHelper.swift
//  BetIT
//
//  Created by joseph on 10/18/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import Foundation

func print(object: Any) {
    #if DEBUG
        Swift.print(object)
    #endif
}
