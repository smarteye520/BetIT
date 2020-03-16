//
//  AlertViewController.swift
//  BetIT
//
//  Created by OSX on 8/6/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import UIKit

class AlertViewController: BaseViewController {
    var alertContainer: AlertContainer!
    var isAnimated: Bool = false

    override func configureUI() {
        super.configureUI()
        
        self.view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0.4)
       
        if let container = alertContainer {
            container.removeFromSuperview()
            self.view.addSubview(container)
            container.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.top.equalTo(self.view.snp.top).offset(200)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isAnimated == false {
            self.alertContainer.frame = CGRect(x: (self.view.bounds.width - alertContainer.bounds.width)/2, y: -self.alertContainer.bounds.height, width: alertContainer.bounds.width, height: alertContainer.bounds.height)
            UIView.animate(withDuration: 0.3) {
                self.alertContainer.frame = CGRect(x: (self.view.bounds.width - self.alertContainer.bounds.width)/2, y: 200, width: self.alertContainer.bounds.width, height: self.alertContainer.bounds.height)
            }
        }
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [], animations: {
            self.alertContainer.snp.updateConstraints {
                $0.top.equalTo(self.view.snp.top).offset(-self.alertContainer.bounds.height)
            }
            self.view.layoutIfNeeded()
        }) { _ in
            self.dismiss(animated: false)
        }
    }
}

extension AlertViewController {
    convenience init(title: String, message: String, buttons:[String], completion: AlertCompletion? = nil) {
        self.init()
        
        alertContainer = AlertContainer.create(with: title, message: message, buttonTitles: buttons) { [weak self] index in
            guard let weak_self  = self else {
                completion?(index)
                return
            }
            
            completion?(index)
            weak_self.dismiss()
        }
    }
}
