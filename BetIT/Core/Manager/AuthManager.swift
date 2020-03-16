//
//  AuthManager.swift
//  BetIT
//
//  Created by joseph on 8/23/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import Foundation
import Firebase
import FBSDKLoginKit

typealias AuthUser = Firebase.User
typealias LoginCompletionHandler = (User?, Error?) -> Void
typealias SignUpCompletionHandler = (User?, Error?) -> Void
typealias SendPasswordResetCompletionHandler = (Error?) -> Void
typealias SignOutCompletionHandler = (Error?) -> Void
typealias ChangePasswordCompletionHandler = (Error?) -> Void
typealias ChangeEmailCompletionHandler = (Error?) -> Void
typealias ConfirmPasswordCompletionHandler = (Error?) -> Void

internal final class AuthManager {
    static let shared = AuthManager()
    
    private init() { }
    
    var currentUser: AuthUser? {
        return Auth.auth().currentUser
    }
    
    func changePassword(_ password: String, completionHandler: ChangePasswordCompletionHandler? = nil) {
        Auth.auth().currentUser?.updatePassword(to: password, completion: { (error) in
            completionHandler?(error)
        })
    }
    
    func changeEmail(_ email: String, completionHandler: ChangeEmailCompletionHandler? = nil) {
        guard email.isValidEmail() else { return }
        
        DatabaseManager.shared.checkEmailTaken(email: email) { (user, error) in
            if let error = error {
                completionHandler?(error)
                return
            }
            
            if let _ = user {
                // Email taken
                let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Email already taken"])
                completionHandler?(error)
                return
            }
            
            Auth.auth().currentUser?.updateEmail(to: email, completion: { (error) in
                completionHandler?(error)
            })
        }
    }
    
    func sendPasswordReset(email: String, completionHandler: SendPasswordResetCompletionHandler? = nil) {
        guard email.isValidEmail() else {
            let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "There was an error reseting password. Please try again."
            ])
            completionHandler?(error)
            return
        }
        Auth.auth().sendPasswordReset(withEmail: email, completion: completionHandler)
    }
    
    func signUp(email: String? = nil, password: String? = nil, fullName: String? = nil, completionHandler: SignUpCompletionHandler? = nil) {
        guard let email = email, email.isValidEmail() else { return }
        guard let password = password, password.isValidPassword() else { return }
        guard let fullName = fullName, fullName.isValidName() else { return }
        
         Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if let error = error {
                completionHandler?(nil, error)
                return
            }
            guard let authResult = authResult else {
                let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "There was an error signing up. Please try again."
                ])
                completionHandler?(nil , error)
                return
            }
            let authUser: AuthUser = authResult.user
            // completionHandler?(authUser, nil)

            var firstName: String = ""
            var lastName: String = ""
            let names = fullName.components(separatedBy: " ")
            if names.count == 1 {
                firstName = names[0]
            } else if names.count >= 2 {
                firstName = names[0]
                lastName = names[1]
            }
            
            DatabaseManager.shared.createUser(userID: authUser.uid, email: email, password: password, firstName: firstName, lastName: lastName, completionHandler: completionHandler)
        }
    }
    
    func facebookLogin(_ accessToken: AccessToken, completionHandler: LoginCompletionHandler? = nil) {
        // TODO: Facebook auth
        // Sign in with facebook credentials
        // Check if user with the account exists
        // If exists, call completion handler
        // else populate user data with facebook user data (i.e: fullName, email, phoneNumber, etc...)
        
        let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print("[DEBUG] AuthManager.shared.facebookLogin() - ERROR: \(error.localizedDescription)")
                completionHandler?(nil, error)
                return
            }

            guard let authResult = authResult else {
                let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Empty auth result"
                ])
                completionHandler?(nil, error)
                return
            }
            
            print("[DEBUG] AuthManager.shared.facebookLogin() - USER_ID: \(authResult.user.uid)")
            
            DatabaseManager.shared.getUser(authResult.user.uid) { (user, error) in
                if let error = error {
                    if let errorObj = error as NSError? {
                        if errorObj.code == NotFoundError {
                            // Create User
                            self.createFacebookUser(accessToken: accessToken, completionHandler: completionHandler)
                            return
                        }
                    } else {
                        completionHandler?(nil, error)
                        return
                    }
                }
                completionHandler?(user, error)
            }
        }
    }
    
    func createFacebookUser(accessToken: AccessToken, completionHandler: GetUserCompletionHandler? = nil) {
        Profile.loadCurrentProfile { (profile, error) in
            if let error = error {
                completionHandler?(nil, error)
                return
            }
            guard let profile = profile else {
                let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Could not create facebook user"
                ])
                completionHandler?(nil, error)
                return
            }
            
            guard let bucketKey = Util.shared.generateBucketKey() else { return }
            print("[DEBUG] AuthManager.shared.createFacebookUser() - Creating facebook user")
            let user = User()
            user.firstName = profile.firstName ?? ""
            user.lastName = profile.lastName ?? ""
            user.email = ""
            user.isFacebookUser = true
            user.userID = accessToken.userID
            
            if let profilePicURL = profile.imageURL(forMode: .normal, size: .zero) {
                UploadManager.shared.uploadImage(profilePicURL, usingKey: bucketKey) { (metadata, error) in
                    if let error = error {
                        completionHandler?(nil, error)
                        return
                    }
                    guard let metadata = metadata else {
                        let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [
                            NSLocalizedDescriptionKey: "No photo upload metadata available"
                        ])
                        
                        completionHandler?(nil, error)
                        return
                    }
                    guard let photoURL = metadata.path else {
                        let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [
                            NSLocalizedDescriptionKey: "No photo url available"
                        ])
                        completionHandler?(nil, error)
                        return
                    }
                    user.thumbnail = photoURL
                    DatabaseManager.shared.createFacebookUser(user) { (user, error) in
                        completionHandler?(user, error)
                    }
                }
                // UploadManager.shared.uploadImage(image, usingKey: nil, completionHandler: nil)
            } else {
                DatabaseManager.shared.createFacebookUser(user) { (user, error) in
                    completionHandler?(user, error)
                }
            }
        }
    }
    
    func login(email: String? = nil, password: String? = nil, completionHandler: LoginCompletionHandler? = nil) {
        // Store the email in lowercase, leave the password as is
        guard let email = email?.lowercased(), email.isValidEmail() else { return }
        guard let password = password, password.isValidPassword() else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if let error = error {
                completionHandler?(nil, error)
                return
            }
            
            guard let _ = authResult else {
                let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Empty auth result"
                ])
                completionHandler?(nil, error)
                return
            }
            
            DatabaseManager.shared.checkEmailTaken(email: email, completionHandler: { (user, error) in
                completionHandler?(user, error)
            })
            
            // completionHandler?(authResult.user, nil)
        }
    }
    
    func changePassword(email: String, currentPassword: String, newPassword: String, completionHandler: ConfirmPasswordCompletionHandler? = nil) {
        guard let currentUser = Auth.auth().currentUser else { return }
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        currentUser.reauthenticate(with: credential) { (authResult, error) in
            if let error = error {
                completionHandler?(error)
                return
            }
            currentUser.updatePassword(to: newPassword, completion: { (error) in
                completionHandler?(error)
            })
        }
        
    }
    
    func signOut(completionHandler: SignOutCompletionHandler? = nil) {
        // guard isLoggedIn else { return }
        do {
            try Auth.auth().signOut()
        } catch {
            completionHandler?(error)
            return
        }
        completionHandler?(nil)
    }
    
    var isLoggedIn: Bool {
        return currentUser != nil
    }
}
