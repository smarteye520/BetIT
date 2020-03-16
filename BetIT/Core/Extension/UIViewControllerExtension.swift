//
//  UIViewControllerExtension.swift
//
//  Created by OSX on 7/31/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import UIKit
import SafariServices

extension UIViewController {
    func isRootController() -> Bool {
        let vc = self.navigationController?.viewControllers.first
        if self == vc {
            return true
        }
        return false
    }
    
    func showAlert(_ title: String, message: String? = nil, actionTitle: String = "OK", completionHandler: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: actionTitle, style: .default) { (action) in
            completionHandler?()
        }
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
    }
    
    func showCustomAlert(_ alertData: AlertData) {
        UIManager.showAlert(title: alertData.title, message: alertData.message,
                            buttons: alertData.buttons,
                            completion: alertData.completion,
                            parentController: self)
    }
    
    func showDefaultCustomAlert(title: String, message: String, button: String) {
        UIManager.showAlert(title: title,
                            message: message,
                            buttons: [button],
                            parentController: self)
    }
    
    func presentMailViewController() {
        if let url = URL(string: "mailto:\(Constant.Support.emailAddress)") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
            return
        }
    }
    
}

extension UIViewController: SFSafariViewControllerDelegate {
    
    func presentWebViewController(_ url: String) {
        guard let url = URL(string: url) else { return }
        let safariVC = SFSafariViewController(url: url)
        if #available(iOS 13.0, *) {
            safariVC.overrideUserInterfaceStyle = .light
        }
        safariVC.delegate = self
        present(safariVC, animated: true, completion: nil)
    }
    
    
}


