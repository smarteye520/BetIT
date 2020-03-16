//
//  EditProfileViewModel.swift
//  BetIT
//
//  Created by joseph on 11/4/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import Foundation
import FirebaseStorage

internal final class EditProfileViewModel {
    private let paymentHandleKey = "PaymentHandleKey"

    var didSetPaymentHandle: (() -> Void)?
    var didUpdateData: (() -> Void)?
    var showError: ((String) -> Void)?
    
    var currentUser: User
    var imageData: Data?
    var payment: PaymentHandle {
        let handleVal = UserDefaults.standard.integer(forKey: paymentHandleKey)
        return PaymentHandle(rawValue: handleVal) ?? .venmo
    }
    
    // UserViewModel
    
    init(user: User) {
        currentUser = user
    }
    
    var thumbnail: String? {
        return currentUser.thumbnail
    }
    
    var thumbnailImage: StorageReference? {
        if let thumbnail = self.thumbnail {
            return UploadManager.shared.getReference(for: thumbnail)
        }
        return nil
    }
    
    var fullName: String {
        return currentUser.fullName ?? ""
    }
    
    var email: String {
        return currentUser.email ?? ""
    }
    
    var phoneNumber: String {
        return currentUser.phoneNumber ?? ""
    }
    
    var zipCode: String {
        return currentUser.zipCode ?? ""
    }
    
    var paypalUserName: String {
        return currentUser.paypalUsername ?? ""
    }
    
    var venmoUserName: String {
        return currentUser.venmoUsername ?? ""
    }
    
    var firstNameInitial: String {
        return currentUser.fullName?.getInitial() ?? ""
    }
    
    func setPaymentHandle(_ paymentHandle: PaymentHandle) {
        UserDefaults.standard.set(paymentHandle.rawValue, forKey: paymentHandleKey)
        didSetPaymentHandle?()
    }
    
    func updateUserData(fullName: String?, email: String?, zipCode: String?, phoneNumber: String?, paymentHandleUsername: String?) {
        if let fullName = fullName?.trimmingCharacters(in: .whitespacesAndNewlines) {
            currentUser.fullName = fullName
        }
        
        if let zipCode = zipCode?.trimmingCharacters(in: .whitespacesAndNewlines), zipCode.isValidZipCode() {
            currentUser.zipCode = zipCode
        }
        
        if let phoneNumber = phoneNumber?.trimmingCharacters(in: .whitespacesAndNewlines) {
            currentUser.phoneNumber = phoneNumber
        }
        
        if let paymentHandleUsername = paymentHandleUsername?.trimmingCharacters(in: .whitespacesAndNewlines) {
            if payment == .paypal {
                currentUser.paypalUsername = paymentHandleUsername
            } else if payment == .venmo {
                currentUser.venmoUsername = paymentHandleUsername
            }
        }

        let next: () -> Void = { [weak self] in
            guard let strongSelf = self else { return }
            DatabaseManager.shared.updateUser(strongSelf.currentUser) { [weak self] error in
                guard let strongSelf = self else { return }

                if let error = error {
                    strongSelf.showError?(error.localizedDescription)
                    return
                }
                AppManager.shared.saveCurrentUser(user: strongSelf.currentUser)
                strongSelf.didUpdateData?()
            }
        }
        
        uploadProfilePicture { [weak self] in
            self?.updateEmail(email) {
                next()
            }
        }
    }
    
    private func updateEmail(_ email: String?, next: (() -> Void)? = nil) {
        
        guard let email = email?.trimmingCharacters(in: .whitespacesAndNewlines), email.isValidEmail(), let currentUserEmail = currentUser.email, currentUserEmail != email else {
            next?()
            return
        }
        
        currentUser.email = email
        AuthManager.shared.changeEmail(email) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error = error {
                strongSelf.showError?(error.localizedDescription)
                return
            }
            next?()
        }
    }
    
    private func uploadProfilePicture(next: (() -> Void)? = nil) {
        guard let imageData = imageData else {
            next?()
            return
        }

        guard let currentUserID = currentUser.userID, currentUserID.count > 0 else {
            self.showError?("Not logged in")
            return
        }
        
        guard let bucketKey  = Util.shared.generateBucketKey() else {
            self.showError?("Something went wrong")
            return
        }
        
        UploadManager.shared.uploadImageData(imageData, usingKey: bucketKey) { [weak self] (metadata, error) in
            guard let strongSelf = self else { return }
            if let error = error {
                strongSelf.showError?(error.localizedDescription)
                return
            }
            
            guard let metadata = metadata else {
                strongSelf.showError?("No photo upload metadata available")
                return
            }
            
            guard let photoURL = metadata.path else {
                strongSelf.showError?("Could not upload photo")
                return
            }

            strongSelf.currentUser.thumbnail = photoURL
            next?()
        }
    }
}
