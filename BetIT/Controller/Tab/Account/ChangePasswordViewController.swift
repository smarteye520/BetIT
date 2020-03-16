//
//  ChangePasswordViewController.swift
//  BetIT
//
//  Created by OSX on 7/31/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import UIKit

class ChangePasswordViewController: BaseViewController {
    var isAnimated: Bool = false

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var currentPasswordField: UITextField!
    @IBOutlet weak var newPasswordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var savePasswordButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
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
    
    private func setup() {
        currentPasswordField.becomeFirstResponder()
        currentPasswordField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        newPasswordField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        confirmPasswordField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        hideActivityIndicator()
        disableSavePasswordButton()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let currentPassword = currentPasswordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        guard let newPassword = newPasswordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        guard let confirmNewPassword = confirmPasswordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        
        if currentPassword.isValidPassword() && newPassword.isValidPassword() && confirmNewPassword.isValidPassword() {
            enableSavePasswordButton()
        } else {
            disableSavePasswordButton()
        }
    }
    
    @IBAction func savePasswordButtonPressed(_ sender: Any) {
        guard let currentPassword = currentPasswordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        
        guard let newPassword = newPasswordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        guard let confirmNewPassword = confirmPasswordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        
        if confirmNewPassword != newPassword {
            showAlert("Passwords don't match")
            disableSavePasswordButton()
            return
        }
        
        
        showActivityIndicator()
        
        guard let email = AppManager.shared.currentUser?.email else { return }
        AuthManager.shared.changePassword(email: email, currentPassword: currentPassword, newPassword: newPassword) { [weak self] error in
            guard let strongSelf = self else { return }
            strongSelf.hideActivityIndicator()
            if let error = error {
                strongSelf.showAlert(error.localizedDescription)
                strongSelf.disableSavePasswordButton()
                return
            }
            strongSelf.showAlert("Updated password!")
            strongSelf.performSegue(withIdentifier: "unwindIdentifier", sender: nil)
        }
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    private func disableSavePasswordButton() {
        savePasswordButton.isEnabled = false
        savePasswordButton.setTitleColor(UIColor(white: 0.92, alpha: 1.0), for: .disabled)
    }
    
    private func enableSavePasswordButton() {
        savePasswordButton.isEnabled = true
        savePasswordButton.setTitleColor(.white, for: .normal)
    }
    
    private func showActivityIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        savePasswordButton.setTitleColor(.clear, for: .normal)
        savePasswordButton.setTitleColor(.clear, for: .disabled)

    }
    
    private func hideActivityIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        savePasswordButton.setTitleColor(.white, for: .normal)
        savePasswordButton.setTitleColor(UIColor(white: 0.92, alpha: 1.0), for: .disabled)

    }
}
