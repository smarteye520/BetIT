//
//  ForgotPasswordViewController.swift
//  BetIT
//
//  Created by OSX on 7/31/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: BaseViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Initial view state
        activityIndicator.isHidden = true
        activityIndicator.style = .white
        
        emailField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        // Do something when textField text changes
    }

    @IBAction func sendButtonPressed(_ sender: Any) {
        guard let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        
        guard email.isValidEmail() else {
            showAlert("Please enter valid email address!")
            return
        }
        
        showActivityIndicator()
        AuthManager.shared.sendPasswordReset(email: email) { [weak self] (error) in
            guard let strongSelf = self else { return }
            strongSelf.hideActivityIndicator()
            if let error = error {
                strongSelf.showAlert(error.localizedDescription)
                return
            }

            strongSelf.showAlert("Sent password reset!") {
                strongSelf.performSegue(withIdentifier: "unwindIdentifier", sender: nil)
            }
        }
    }
    
    private func hideActivityIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        sendButton.setTitleColor(.white, for: .normal)
    }
    
    private func showActivityIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        sendButton.setTitleColor(.clear, for: .normal)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
