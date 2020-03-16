//
//  PhoneNumberTextField.swift
//  BetIT
//
//  Created by joseph on 8/31/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import Foundation
import UIKit

class PhoneNumberTextField: UITextField {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    func configure() {
        self.delegate = self
    }
}

extension PhoneNumberTextField: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let number = textField.text?.replacingCharacters(in: range, with: string)
        textField.text = formattedNumber(number: number)
        return false
    }
    
    private func formattedNumber(number: String?) -> String? {
        guard let number = number else {
            return nil
        }
        
        let cleanPhoneNumber = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let mask = "(XXX) XXX-XXXX"
        
        var result = ""
        var index = cleanPhoneNumber.startIndex
        for ch in mask where index < cleanPhoneNumber.endIndex {
            if ch == "X" {
                result.append(cleanPhoneNumber[index])
                index = cleanPhoneNumber.index(after: index)
            } else {
                result.append(ch)
            }
        }
        return result
    }
}
