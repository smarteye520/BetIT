//
//  User.swift
//  BetIT
//
//  Created by OSX on 7/31/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//
import UIKit
import ObjectMapper
import SwiftyJSON

class User: BaseObject {
    // User property
    var userID: String?
    var email: String?
    var firstName: String?
    var lastName: String?
    var name: String?
    var thumbnail: String?
    var phoneNumber: String?
    var zipCode: String?
    var venmoUsername: String?
    var paypalUsername: String?
    var isFacebookUser: Bool?
    
    private var notificationSettings: NotificationSettings?
    private var userReferral: UserReferral?
    
    var fullName: String? {
        get {
            var name: String = ""
            if let firstName = firstName {
                name += firstName
            }
            if let lastName = lastName {
                name += " \(lastName)"
            }
            return name.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        set {
            guard let newValue = newValue else { return }
            let names = newValue.components(separatedBy: " ")
            var firstName: String?
            var lastName: String?
            if names.count >= 2 {
                firstName = names[0]
                lastName = names[1]
            } else if names.count == 1 {
                firstName = names[0]
            }
            self.firstName = firstName
            self.lastName = lastName
        }
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        userID                      <- map["userID"]
        email                       <- map["email"]
        firstName                   <- map["firstName"]
        lastName                    <- map["lastName"]
        name                        <- map["name"]
        thumbnail                   <- map["thumbnail"]
        phoneNumber                 <- map["phoneNumber"]
        zipCode                     <- map["zipCode"]
        paypalUsername              <- map["paypalUsername"]
        venmoUsername               <- map["venmoUsername"]
        isFacebookUser              <- map["facebookUser"]
        if isFacebookUser == nil {
            isFacebookUser <- map["isFacebookUser"]
        }
    }
    
    override func attach(_ model: BaseObject) {
        super.attach(model)
        guard let user = model as? User else { return }
        
        userID              = user.userID ?? userID
        email               = user.email ?? email
        firstName           = user.firstName ?? firstName
        lastName            = user.lastName ?? lastName
        thumbnail           = user.thumbnail ?? thumbnail
        phoneNumber         = user.phoneNumber ?? phoneNumber
        zipCode             = user.zipCode ?? zipCode
        paypalUsername      = user.paypalUsername ?? paypalUsername
        venmoUsername       = user.venmoUsername ?? venmoUsername
        isFacebookUser      = user.isFacebookUser ?? isFacebookUser
    }
    
    // MARK: Notification settings
    
    func updateNotificationSettings(_ notificationSettings: NotificationSettings, completionHandler: ((Error?) -> Void)? = nil) {
        
        if self.notificationSettings == nil {
            self.notificationSettings = notificationSettings
        } else {
            self.notificationSettings?.occasionalReminders = notificationSettings.occasionalReminders
            self.notificationSettings?.requests = notificationSettings.isRequests
            self.notificationSettings?.claimed = notificationSettings.isClaimed
            self.notificationSettings?.disputed = notificationSettings.isDisputed
            self.notificationSettings?.email = notificationSettings.isEmail
        }
        self.notificationSettings?.userID = userID

        if let settings = self.notificationSettings {
            DatabaseManager.shared.updateNotificationSettings(settings, for: self) { error in
                completionHandler?(error)
            }
        }
    }
    
    func getNotificationSettings(completionHandler: ((NotificationSettings?) -> Void)? = nil) {
        if let notificationSettings = notificationSettings {
            print("[DEBUG] User.getNotificationSettings() - Already have notification settings for user: \(self.fullName)")
            completionHandler?(notificationSettings)
            return
        }
        
        guard let userID = userID else {
            completionHandler?(nil)
            return
        }
        
        DatabaseManager.shared.fetchNotificationSettings(for: userID) { [weak self] (notificationSettings, error) in
            guard let strongSelf = self else { return }
            if let error = error as NSError? {
                if error.code == NotFoundError {
                    print("[DEBUG] User.getNotificationSettings() - Notification settings not found for user: \(self?.fullName)")
                    strongSelf.notificationSettings = NotificationSettings()
                    strongSelf.notificationSettings?.userID = strongSelf.userID
                    completionHandler?(strongSelf.notificationSettings)
                    return
                }
                completionHandler?(nil)
                return
            }
            
            guard let notificationSettings = notificationSettings else {
                print("[DEBUG] User.getNotificationSettings() - Could not fetch notification settings for user: \(self?.fullName)")

                completionHandler?(nil)
                return
            }
            
            print("[DEBUG] User.getNotificationSettings() - Got notification settings for user: \(self?.fullName)")

            strongSelf.notificationSettings = notificationSettings
            completionHandler?(notificationSettings)
        }
    }
    
    // MARK: - User Referrals
    
    func getUserReferral(completionHandler: ((UserReferral?) -> Void)? = nil) {
        if let userReferral = userReferral {
            completionHandler?(userReferral)
            return
        }
        
        DatabaseManager.shared.fetchUserReferral(for: self) { [weak self] (userReferral, error) in
            guard let strongSelf = self else { return }
            if let error = error as NSError? {
                if error.code == NotFoundError {
                    // [START create_user_referral_link]
                    DeepLinkManager.shared.createShortURL(with: nil, completionHandler: { [weak self] (url, error) in
                        guard let strongSelf = self else { return }
                        
                        guard let url = url else {
                            completionHandler?(nil)
                            return
                        }
                        
                        // Create user referral
                        let userReferral = UserReferral()
                        userReferral.userID = strongSelf.userID
                        userReferral.referralLink = url
                        
                        // Write to database since it was created for the first time
                        DatabaseManager.shared.updateUserReferral(userReferral, for: strongSelf)

                        // Cache it
                        strongSelf.userReferral = userReferral
                        
                        // Completion handler
                        DispatchQueue.main.async {
                            completionHandler?(strongSelf.userReferral)
                        }
                    })
                    // [END create_user_referral_link]
                    
                    return
                }
                
                DispatchQueue.main.async {
                    completionHandler?(nil)
                }
                return
            }
            
            guard let userReferral = userReferral else {
                DispatchQueue.main.async {
                    completionHandler?(nil)
                }
                return
            }
            
            strongSelf.userReferral = userReferral
            DispatchQueue.main.async {
                completionHandler?(strongSelf.userReferral)
            }
        }
    }
}

extension User {
    func isValidProfile() -> Bool {
        guard firstName != nil else {
            return false
        }
        return true
    }
}

extension User {
    static func == (lhs: User, rhs: User) -> Bool {
        // Just check email and user id 
        guard let lhsUserID = lhs.userID, let rhsUserID = rhs.userID else { return false }
        return lhsUserID == rhsUserID

        // guard let lhsEmail = lhs.email, let rhsEmail = rhs.email else { return false }
        // return (lhsUserID == rhsUserID &&
        //         lhsEmail == rhsEmail)
    }
    static func != (lhs: User, rhs: User) -> Bool {
        return !(lhs == rhs)
    }
}

