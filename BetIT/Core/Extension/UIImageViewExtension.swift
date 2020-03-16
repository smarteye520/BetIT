//
//  UIImageViewExtension.swift
//  BetIT
//
//  Created by OSX on 8/2/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import Foundation
import SDWebImage

extension UIImageView {
    func loadImage(url photoUrl: URL?, placeholder imageName: String = "img_placeholder") {
        guard let url = photoUrl else {
            self.image = UIImage.init(named: imageName)!
            self.contentMode = .center
            return
        }
        
        self.sd_setImage(with: url, placeholderImage: UIImage(named: imageName), options: .continueInBackground) { (image, error, type, url) in
            self.contentMode = .scaleAspectFill
        }
    }
    
    func loadImage(string urlString: String?, placeholder imageName: String = "img_placeholder") {
        guard let urlString = urlString?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: urlString) else {
            loadImage(url: nil, placeholder: imageName)
            return
        }
        
        loadImage(url: url, placeholder: imageName)
    }
}

