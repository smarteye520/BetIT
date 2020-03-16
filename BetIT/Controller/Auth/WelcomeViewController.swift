//
//  WelcomeViewController.swift
//  BetIT
//
//  Created by OSX on 7/31/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class WelcomeViewController: BaseViewController {

    @IBOutlet weak var facebookLoginContainer: UIButton!
    @IBOutlet weak var termsOfServiceLabel: UILabel!

    var facebookLoginButton: FBLoginButton!
    var facebookActivityIndicator: UIActivityIndicatorView!
    var textContainer: NSTextContainer!
    var layoutManager: NSLayoutManager!
    var textStorage: NSTextStorage!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupFacebookLogin()
        
        setupTermsOfServiceLabel()
    }
    
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
    
    
    private func setupFacebookLogin() {
        // facebookLoginButtonContainer.isUserInteractionEnabled = false
        
        facebookLoginButton = FBLoginButton()
        facebookLoginButton.delegate = self
        facebookLoginButton.frame = facebookLoginContainer.bounds
        // Any UIView that has alpha lower than 0.01 will be ignored by the touch events
        // processing system, i.e. will not receive touch.
        facebookLoginButton.alpha = 0.02
        facebookLoginContainer.addSubview(facebookLoginButton)
        
        facebookActivityIndicator = UIActivityIndicatorView(style: .white)
        facebookActivityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        facebookActivityIndicator.center = facebookLoginButton.center
        facebookActivityIndicator.style = .white
        facebookActivityIndicator.isHidden = true
        facebookLoginContainer.addSubview(facebookActivityIndicator)
    }
    
    // MARK: - Helpers
    
    private func showFacebookActivityIndicator() {
        facebookActivityIndicator.isHidden = false
        facebookActivityIndicator.startAnimating()
        
        facebookLoginContainer.setTitleColor(.clear, for: .normal)
        facebookLoginContainer.setTitleColor(.clear, for: .disabled)
    }
    
    private func hideFacebookActivityIndicator() {
        facebookActivityIndicator.isHidden = true
        facebookActivityIndicator.stopAnimating()
        facebookLoginContainer.setTitleColor(.white, for: .normal)
        facebookLoginContainer.setTitleColor(.white, for: .disabled)
    }

}


// MARK: - Facebook login

extension WelcomeViewController: LoginButtonDelegate {
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
            if let error = error {
                // self?.showAlert("There was an error logging in via facebook")
                self?.hideFacebookActivityIndicator()
                self?.showAlert(error.localizedDescription)
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

