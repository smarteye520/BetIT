//
//  ControlHelper.swift
//  BetIT
//
//  Created by OSX on 7/31/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import UIKit

extension UIView {
    func addChild(view: UIView) {
        if self is UIStackView {
            (self as! UIStackView).addArrangedSubview(view)
        }
        else {
            self.addSubview(view)
        }
    }
    
    func removeAllSubViews() {
        for subView in subviews {
            subView.removeFromSuperview()
        }
    }
}

extension UILabel {
    convenience init(font: UIFont, color: UIColor, backgroundColor: UIColor = .clear, letterSpacing: CGFloat = 0, superView: UIView? = nil) {
        self.init(frame: .zero)
        self.font = font
        self.textColor = color
        self.backgroundColor = backgroundColor
        self.letterSpacing = letterSpacing
        
        superView?.addChild(view: self)
    }
}

extension UIButton {
    convenience init(image: UIImage? = nil, selectedImage: UIImage? = nil, action: Selector, target: Any, superView: UIView? = nil) {
        self.init(type: .custom)
        self.frame = .zero
        self.backgroundColor = .clear
        
        self.setImage(image, for: .normal)
        self.setImage(selectedImage, for: .selected)
        
        self.addTarget(target, action: action, for: .touchUpInside)
        
        superView?.addChild(view: self)
    }
}


extension UIImageView {
    convenience init(backgroundColor: UIColor = .clear, contentMode: UIView.ContentMode = UIView.ContentMode.scaleAspectFit, superView: UIView? = nil) {
        self.init(frame: .zero)
        self.backgroundColor = backgroundColor
        self.contentMode = contentMode
        self.clipsToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
        
        superView?.addChild(view: self)
    }
//    
//    func loadImage(url photoUrl: URL?, placeholder imageName: String = "img_placeholder") {
//        guard let url = photoUrl else {
//            self.image = UIImage.init(named: imageName)!
//            self.contentMode = .center
//            return
//        }
//        
//        self.sd_setImage(with: url, placeholderImage: UIImage(named: imageName), options: .continueInBackground) { (image, error, type, url) in
//            self.contentMode = .scaleAspectFill
//        }
//    }
//    
//    func loadImage(string urlString: String?, placeholder imageName: String = "img_placeholder") {
//        guard let urlString = urlString?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: urlString) else {
//            loadImage(url: nil, placeholder: imageName)
//            return
//        }
//        
//        loadImage(url: url, placeholder: imageName)
//    }
}
