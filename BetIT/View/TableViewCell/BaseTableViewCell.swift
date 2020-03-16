//
//  BaseTableViewCell.swift
//  MondaysAtSix
//
//  Created by OSX on 2/18/19.
//  Copyright © 2019 OSX. All rights reserved.
//

import UIKit

class BaseTableViewCell: UITableViewCell {
    class var height: CGFloat {
        return 50
    }
    
    class var identifier: String {
        return "CommonTableViewCell"
    }
    
    var indexPath: IndexPath!
    var controller: UIViewController!
    var tableView: UITableView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    func configure() {
        self.selectionStyle = .none
    }
}

//Register
extension BaseTableViewCell {
    class func registerWithNib(to tableView: UITableView, nibName: String? = nil, identifier: String? = nil) {
        let nibName = nibName ?? self.className
        let nib = UINib(nibName: nibName, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: identifier ?? self.identifier)
    }
    
    class func register(to tableView: UITableView) {
        tableView.register(self, forCellReuseIdentifier: self.identifier)
    }
}
