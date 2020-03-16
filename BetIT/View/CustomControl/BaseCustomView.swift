//
//  BaseCustomView.swift
//  BetIT
//
//  Created by OSX on 8/1/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import UIKit

class BaseCustomView: UIControl {
    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        build()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        build()
    }
    
    func build() {
        //add sub views here
    }
}
