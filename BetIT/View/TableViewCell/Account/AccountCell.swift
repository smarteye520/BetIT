//
//  AccountTableViewCell.swift
//  BetIT
//
//  Created by OSX on 8/5/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import UIKit

class AccountCell: BaseTableViewCell {
    override class var identifier: String {
        return "account_cell"
    }
    
    override class var height: CGFloat {
        return 80
    }
    
    @IBOutlet weak var lblTitle: UILabel!
    
    func reset(with title: String) {
        lblTitle.text = title
    }
}
