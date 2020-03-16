//
//  BaseHeaderFooterView.swift
//  BetIT
//
//  Created by OSX on 8/2/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import UIKit

class BaseHeaderFooterView: UITableViewHeaderFooterView {
    class var identifier: String {
        return "base_header_footer"
    }

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configure()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configure()
    }
    
    func configure() {
        
    }
}

extension BaseHeaderFooterView {    
    class func registerWithNib(to tableView: UITableView, nibName: String? = nil) {
        let nibName = nibName ?? self.className
        let nib = UINib(nibName: nibName, bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: self.identifier)
    }
    
    class func register(to tableView: UITableView) {
        tableView.register(self, forHeaderFooterViewReuseIdentifier: self.identifier)
    }
}
