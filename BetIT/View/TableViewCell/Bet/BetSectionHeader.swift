//
//  BetSectionHeader.swift
//  BetIT
//
//  Created by OSX on 8/2/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import UIKit

class BetSectionHeader: UIView {
    
    var lblTitle: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setup() {
        backgroundColor = .clear

        lblTitle = UILabel(font: AppFont.interstate.bold(size: 12), color: .lightGray)
        lblTitle.backgroundColor = .clear
        self.addSubview(lblTitle)
    
        lblTitle.snp.makeConstraints {
            $0.left.equalToSuperview().offset(12)
            $0.centerY.equalToSuperview()
        }
    }
    
    func setTitle(_ title: String) {
        lblTitle.text = title
    }
}
