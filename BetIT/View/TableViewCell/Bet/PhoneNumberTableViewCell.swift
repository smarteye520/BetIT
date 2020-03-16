//
//  PhoneNumberTableViewCell.swift
//  BetIT
//
//  Created by joseph on 9/11/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import UIKit

class PhoneNumberTableViewCell: UITableViewCell {
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
