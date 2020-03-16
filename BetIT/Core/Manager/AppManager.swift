//
//  AppManager.swift
//  BetIT
//
//  Created by OSX on 7/31/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import UIKit
import ObjectMapper
import FBSDKLoginKit

class AppManager: NSObject {
    static let shared = AppManager()
    
    var isGuest: Bool = false
        
    override init() {
        super.init()
        loadUser()
    }
    
    // Current User
    var currentUser : User?
    var loggedIn: Bool{
        guard let user = currentUser else { return false }
        guard user.userID != nil else { return false }
        return true
    }

    func loadUser() {
        if let json = KeychainManager.getString(for: "current_user"), json.count > 0 {
            let mapper = Mapper<User>()
            currentUser = mapper.map(JSONString: json)
        }
        if let currentUser = currentUser {
            NotificationManager.shared.subscribe(user: currentUser)
        }
    }
    
    func logoutUser() {
        if let currentUser = currentUser {
            NotificationManager.shared.unsubscribe(user: currentUser)
        }
        if let currentUser = currentUser, let isFacebookUser = currentUser.isFacebookUser, isFacebookUser == true {
            LoginManager().logOut()
        }
        KeychainManager.setString(value: nil, for: "current_user")
        currentUser = nil
    }
    
    func saveUser(){
        KeychainManager.setString(value: currentUser?.toJSONString() ?? "", for: "current_user")
    }
    
    func saveCurrentUser(user: User) {
        if let currentUser = self.currentUser {
            currentUser.attach(user)
        } else {
            self.currentUser = user
        }
        if let currentUser = currentUser {
            NotificationManager.shared.subscribe(user: currentUser)
        }
        saveUser()
    }
}

extension AppManager {
    func showNext(animated: Bool = false) {
        if loggedIn {
            UIManager.showMain(animated: animated)
        } else {
            UIManager.showLogin(animated: animated)
        }
    }
}
