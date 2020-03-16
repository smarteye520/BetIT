//
//  ModalViewController.swift
//
//  Created by OSX on 7/31/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//


import UIKit

class ModalViewController: UIViewController {
    @IBOutlet weak var viewContainer: UIView!
    var isAnimated: Bool = false

    // Status Bar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isAnimated == false {
            self.viewContainer.frame = CGRect(x: 0, y: self.view.bounds.height, width: viewContainer.bounds.width, height: viewContainer.bounds.height)
            UIView.animate(withDuration: 0.3) {
                self.viewContainer.frame = CGRect(x: 0, y: 54, width: self.viewContainer.bounds.width, height: self.viewContainer.bounds.height)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    @IBAction func onCancel(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, animations: {
            self.viewContainer.frame = CGRect(x: self.viewContainer.frame.minX, y: self.viewContainer.frame.minY + self.viewContainer.bounds.height, width: self.viewContainer.bounds.width, height: self.viewContainer.bounds.height)
        }) { _ in
            super.dismiss(animated: true, completion: nil)
        }
    }
}
