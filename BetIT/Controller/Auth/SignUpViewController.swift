//
//  SignUpViewController.swift
//  BetIT
//
//  Created by OSX on 7/31/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import UIKit

class SignUpViewController: BaseViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signUpActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var termsOfServiceLabel: UILabel!
    
    var textContainer: NSTextContainer!
    var layoutManager: NSLayoutManager!
    var textStorage: NSTextStorage!

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: - IBActions
    @IBAction func signupButtonPressed(_ sender: Any) {
        guard AuthManager.shared.isLoggedIn == false else {
            showAlert("User is already logged in")
            return
        }
        guard let name = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        guard let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        guard let password = passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }

        if !name.isValidName() {
            showAlert("Please enter a valid name!")
            return
        }
        
        if !email.isValidEmail() {
            showAlert("Please enter a valid email address!")
            return
        }
        
        if !password.isValidPassword() {
            showAlert("Please enter a password with 8 or more characters!")
            return
        }
        
        // disableSignUpButton()
        showSignUpActivityIndicator()
        
        AuthManager.shared.signUp(email: email, password: password, fullName: name) { [weak self] (user, error) in
            guard let strongSelf = self else { return }
            strongSelf.hideSignUpActivityIndicator()
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
        guard let name = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        guard let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        guard let password = passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        
        if name.isValidName() && email.isValidEmail() && password.isValidPassword() {
            // enableSignUpButton()
        } else {
            // disableSignUpButton()
        }
    }
    
    // MARK: - Setup
    private func setup() {
        nameField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        emailField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        signUpActivityIndicator.color = .white
        enableSignUpButton()
        hideSignUpActivityIndicator()
        
        setupTermsOfServiceLabel()
    }
    
    // MARK: - Helper
    
    private func setupTermsOfServiceLabel() {
        guard let termsOfServiceText = termsOfServiceLabel.text else { return }
        // [START attributed_text]
        guard let termsConditionsRange = termsOfServiceText.range(of: "Terms and Conditions") else { return }
        guard let privacyPolicyRange = termsOfServiceText.range(of: "Privacy Policy") else { return }
        
        let defaultAttributes = [NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                                 NSAttributedString.Key.font: UIFont.systemFont(ofSize: termsOfServiceLabel.font.pointSize)]
        
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.black,
                          NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: termsOfServiceLabel.font.pointSize)]
        
        let attributedText = NSMutableAttributedString(string: termsOfServiceText, attributes: defaultAttributes)
        attributedText.setAttributes(attributes, range: NSRange(termsConditionsRange, in: termsOfServiceText))
        attributedText.setAttributes(attributes, range: NSRange(privacyPolicyRange, in: termsOfServiceText))
        
        termsOfServiceLabel.attributedText = attributedText
        // [END attributed_text]

        // [START tap_gesture_recognizer]
        termsOfServiceLabel.isUserInteractionEnabled = true
        termsOfServiceLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(_:))))
        
        layoutManager = NSLayoutManager()
        textContainer = NSTextContainer(size: termsOfServiceLabel.bounds.size)
        textStorage = NSTextStorage(attributedString: attributedText)
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = termsOfServiceLabel.lineBreakMode
        textContainer.maximumNumberOfLines = termsOfServiceLabel.numberOfLines
        // [END tap_gesture_recognizer]
    }

    @objc private func tap(_ tapGesture: UITapGestureRecognizer) {
        let location = tapGesture.location(in: tapGesture.view!)
        let labelSize = tapGesture.view!.bounds.size
        let textBounds = layoutManager.usedRect(for: textContainer)
        
        let textContainerOffset = CGPoint(x: (labelSize.width - textBounds.size.width) * 0.5 - textBounds.origin.x,
                                          y: (labelSize.height - textBounds.size.height) * 0.5 - textBounds.origin.y)
        let textContainerLocation = CGPoint(x: location.x - textContainerOffset.x,
                                            y: location.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: textContainerLocation,
                                                            in: textContainer,
                                                            fractionOfDistanceBetweenInsertionPoints: nil)
        if let finePrintText = termsOfServiceLabel.attributedText?.string,
            let rangeOfPrivacyPolicy = finePrintText.range(of: "Privacy Policy"),
            let rangeOfTermsOfService = finePrintText.range(of: "Terms and Conditions") {
            if NSLocationInRange(indexOfCharacter, NSRange(rangeOfPrivacyPolicy, in: finePrintText)) {
                presentWebViewController(Constant.URLs.privacyPolicy)
            } else if NSLocationInRange(indexOfCharacter, NSRange(rangeOfTermsOfService, in: finePrintText)) {
                presentWebViewController(Constant.URLs.termsConditions)
            }
        }
    }

    private func hideSignUpActivityIndicator() {
        signUpActivityIndicator.isHidden = true
        signUpActivityIndicator.stopAnimating()
        signUpButton.setTitleColor(UIColor(white: 0.92, alpha: 1.0), for: .normal)
        signUpButton.setTitleColor(UIColor(white: 1.0, alpha: 0.7), for: .disabled)
    }
    
    private func showSignUpActivityIndicator() {
        signUpActivityIndicator.isHidden = false
        signUpActivityIndicator.startAnimating()
        signUpButton.setTitleColor(.clear, for: .normal)
        signUpButton.setTitleColor(.clear, for: .disabled)
    }
    
    private func disableSignUpButton() {
        signUpButton.setTitleColor(UIColor(white: 1.0, alpha: 0.7), for: .disabled)
        signUpButton.isEnabled = false
    }
    
    private func enableSignUpButton() {
        signUpButton.setTitleColor(.white, for: .normal)
        signUpButton.isEnabled = true
    }
}
