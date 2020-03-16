//
//  Theme.swift
//  BetIT
//
//  Created by OSX on 7/31/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import UIKit

// Color palette
extension UIColor {
    @nonobjc class var darkForestGreen: UIColor {
        return #colorLiteral(red: 0.2, green: 0.5960784314, blue: 0.1725490196, alpha: 1)
    }
    
    @nonobjc class var darkBlue: UIColor {
        return #colorLiteral(red: 0.1215686275, green: 0.2431372549, blue: 0.5764705882, alpha: 1)
    }
    
    @nonobjc class var facebook: UIColor {
        return #colorLiteral(red: 0.2392156863, green: 0.3803921569, blue: 0.7333333333, alpha: 1)
    }
    
    @nonobjc class var lightCyan: UIColor {
        return #colorLiteral(red: 0.3803921569, green: 0.7607843137, blue: 0.8039215686, alpha: 1)
    }
    
    @nonobjc class var cyan: UIColor {
        return #colorLiteral(red: 0.6, green: 0.8274509804, blue: 0.9254901961, alpha: 1)
    }
    
    @nonobjc class var darkestBlue: UIColor {
        return #colorLiteral(red: 0.06274509804, green: 0.1215686275, blue: 0.2901960784, alpha: 1)
    }
    
    @nonobjc class var darkGrey: UIColor {
        return #colorLiteral(red: 0.462745098, green: 0.4588235294, blue: 0.462745098, alpha: 1)
    }
    
    @nonobjc class var purple: UIColor {
        return #colorLiteral(red: 0.4862745098, green: 0.2392156863, blue: 0.7882352941, alpha: 1)
    }
    
    @nonobjc class var lightOrange: UIColor {
        return #colorLiteral(red: 0.968627451, green: 0.7098039216, blue: 0, alpha: 1)
    }
    
    @nonobjc class var lightRed: UIColor {
        return #colorLiteral(red: 0.8784313725, green: 0.1254901961, blue: 0.1254901961, alpha: 1)
    }
}

enum AppFont {
    case louisGeorgeCafe
    case interstate
    
    var fontNameRegular: String {
        switch self {
        case .louisGeorgeCafe:
            return "LouisGeorgeCafe"
        case .interstate:
            return "Interstate-Regular"
        }
    }
    
    var fontNameLight: String {
        switch self {
        case .louisGeorgeCafe:
            return "LouisGeorgeCafeLight"
        case .interstate:
            return "Interstate-Light"
        }
    }
    
    var fontNameBold: String {
        switch self {
        case .louisGeorgeCafe:
            return "LouisGeorgeCafe-Bold"
        case .interstate:
            return "Interstate-Bold"
        }
    }
    
    func bold(size: CGFloat) -> UIFont {
        return UIFont.font(name: fontNameBold, size: size)
    }
    
    func regular(size: CGFloat) -> UIFont {
        return UIFont.font(name: fontNameRegular, size: size)
    }
    
    func light(size: CGFloat) -> UIFont {
        return UIFont.font(name: fontNameLight, size: size)
    }
}

//Font of the App
let iPhoneXFontScale: CGFloat = 1.1

extension UIFont {
    static func font(name: String, size: CGFloat)->UIFont {
        var size = size
        if UIDevice.current.isiPhoneX {
            size = size * iPhoneXFontScale
        }
        return UIFont.init(name: name, size: size) ?? UIFont.systemFont(ofSize: size)
    }

    static func bold(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .bold)
    }
    
    static func regular(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .regular)
    }
    
    static func light(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .light)
    }
    
    static func medium(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .medium)
    }
    
    static func semibold(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .semibold)
    }
    
    static func printFonts() {
        for family: String in UIFont.familyNames
        {
            print(family)
            for names: String in UIFont.fontNames(forFamilyName: family)
            {
                print("== \(names)")
            }
        }
    }
}

//Button spacing
extension UIButton {
    //    @IBInspectable
    var letterSpacing: CGFloat {
        set {
            guard let text = self.titleLabel?.text, text.count > 0 else {
                return
            }
            
            let attributedString = NSMutableAttributedString(string: text)
            attributedString.addAttribute(NSAttributedString.Key.kern, value: newValue, range: NSRange(location: 0, length: text.count))
            self.setAttributedTitle(attributedString, for: .normal)
        }
        get {
            return self.titleLabel?.attributedText?.attribute(NSAttributedString.Key.kern, at: 0, effectiveRange: .none) as? CGFloat ?? 0
        }
    }
}

extension UILabel {
    //    @IBInspectable
    var letterSpacing: CGFloat {
        set {
            let attributedString: NSMutableAttributedString!
            if let currentAttrString = attributedText {
                attributedString = NSMutableAttributedString(attributedString: currentAttrString)
            } else {
                attributedString = NSMutableAttributedString(string: text ?? "")
                text = nil
            }
            attributedString.addAttribute(NSAttributedString.Key.kern,
                                          value: newValue,
                                          range: NSRange(location: 0, length: attributedString.length))
            attributedText = attributedString
        }
        
        get {
            if let currentLetterSpace = attributedText?.attribute(NSAttributedString.Key.kern, at: 0, effectiveRange: .none) as? CGFloat {
                return currentLetterSpace
            } else {
                return 0
            }
        }
    }

    // Pass value for any one of both parameters and see result
    func setLineSpacing(lineSpacing: CGFloat = 0.0, lineHeightMultiple: CGFloat = 0.0, alignment: NSTextAlignment = .left) {
        
        guard let labelText = self.text else { return }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.lineHeightMultiple = lineHeightMultiple
        paragraphStyle.alignment = alignment
        
        let attributedString: NSMutableAttributedString
        if let labelattributedText = self.attributedText {
            attributedString = NSMutableAttributedString(attributedString: labelattributedText)
        } else {
            attributedString = NSMutableAttributedString(string: labelText)
        }
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        self.attributedText = attributedString
    }
}

