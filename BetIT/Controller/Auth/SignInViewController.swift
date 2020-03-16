//
//  SignInViewController.swift
//  BetIT
//
//  Created by OSX on 7/31/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class SignInViewController: BaseViewController {

    // MARK: - IBOutlets

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginActivityIndicator: UIActivityIndicatorView!
    
    var facebookLoginButton: FBLoginButton!
    var facebookActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var facebookLoginButtonContainer: UIButton!
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setup()
    }

    // MARK: - Setup
    
    private func setup() {
        emailField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        hideActivityIndicator()
        disableLogInButton()
        setupFacebookLogin()
    }
    
    private func setupFacebookLogin() {
        facebookLoginButton = FBLoginButton()
        facebookLoginButton.delegate = self
        facebookLoginButton.frame = facebookLoginButtonContainer.bounds
        // Any UIView that has alpha lower than 0.01 will be ignored by the touch events
        // processing system, i.e. will not receive touch.
        facebookLoginButton.alpha = 0.02
        facebookLoginButtonContainer.addSubview(facebookLoginButton)
        
        facebookActivityIndicator = UIActivityIndicatorView(style: .white)
        facebookActivityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        facebookActivityIndicator.center = facebookLoginButton.center
        facebookActivityIndicator.style = .white
        facebookActivityIndicator.isHidden = true
        facebookLoginButtonContainer.addSubview(facebookActivityIndicator)
        
    }
    // MARK: - Helpers
    
    private func showFacebookActivityIndicator() {
        facebookActivityIndicator.isHidden = false
        facebookActivityIndicator.startAnimating()
        
        facebookLoginButtonContainer.setTitleColor(.clear, for: .normal)
        facebookLoginButtonContainer.setTitleColor(.clear, for: .disabled)
    }
    
    private func hideFacebookActivityIndicator() {
        facebookActivityIndicator.isHidden = true
        facebookActivityIndicator.stopAnimating()
        facebookLoginButtonContainer.setTitleColor(.white, for: .normal)
        facebookLoginButtonContainer.setTitleColor(.white, for: .disabled)
    }
    
    private func showActivityIndicator() {
        loginActivityIndicator.isHidden = false
        loginActivityIndicator.startAnimating()
        loginButton.setTitleColor(.clear, for: .normal)
        loginButton.setTitleColor(.clear, for: .disabled)
    }
    
    private func hideActivityIndicator() {
        loginActivityIndicator.isHidden = true
        loginActivityIndicator.stopAnimating()
        loginButton.setTitleColor(UIColor(white: 0.92, alpha: 1.0), for: .normal)
        loginButton.setTitleColor(UIColor(white: 1.0, alpha: 0.7), for: .disabled)
    }
    
    private func enableLogInButton() {
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.isEnabled = true
    }
    
    private func disableLogInButton() {
        loginButton.setTitleColor(UIColor(white: 1.0, alpha: 0.7), for: .disabled)
        loginButton.isEnabled = false
    }
    
    // MARK: - IBActions
    
    @IBAction func onLogIn(_ sender: Any) {
        // AppManager.shared.isLoggedIn = true
        // AppManager.shared.showNext(animated: true)
        guard AppManager.shared.loggedIn == false else {
            showAlert("User is already logged in")
            return
        }
        
        guard let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        guard let password = passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        
        disableLogInButton()
        showActivityIndicator()
        
        AuthManager.shared.login(email: email, password: password) { [weak self] (user, error) in
            guard let strongSelf = self else { return }
            strongSelf.hideActivityIndicator()
            if let error = error {
                strongSelf.showAlert(error.localizedDescription)
                return
            }
            guard let user = user else {
                strongSelf.showAlert("Could not log in. Please try again")
                return
            }
            AppManager.shared.saveCurrentUser(user: user)
            DeepLinkManager.shared.trackUser(user)
            UIManager.showMain(animated: true)
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        guard let password = passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        
        if email.isValidEmail() && password.isValidPassword() {
            enableLogInButton()
        } else {
            disableLogInButton()
        }
    }

}

// MARK: - Facebook login

extension SignInViewController: LoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {

    }
    
    func loginButtonWillLogin(_ loginButton: FBLoginButton) -> Bool {
        showFacebookActivityIndicator()
        return true
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
        if let error = error {
            hideFacebookActivityIndicator()
            showAlert(error.localizedDescription)
            return
        }
        
        guard let _ = result, let accessToken = AccessToken.current else {
            hideFacebookActivityIndicator()
            showAlert("Could not login with facebook")
            return
        }
        
        AuthManager.shared.facebookLogin(accessToken) { [weak self] (user, error) in
            if let _ = error {
                self?.hideFacebookActivityIndicator()
                self?.showAlert("There was an error logging in via facebook")
                return
            }
            
            guard let user = user else {
                self?.hideFacebookActivityIndicator()
                self?.showAlert("No facebook user")
                return
            }
            
            AppManager.shared.saveCurrentUser(user: user)
            UIManager.showMain(animated: true)
            self?.hideFacebookActivityIndicator()

        }
    }
}
