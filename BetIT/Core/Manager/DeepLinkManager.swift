//
//  DeepLinkManager.swift
//  BetIT
//
//  Created by joseph on 8/29/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import Foundation
import Branch

typealias ShortURLCompletionHandler = (String?, Error?) -> Void 

internal final class DeepLinkManager {
    static let shared = DeepLinkManager()
    private let branch: Branch = Branch.getInstance()
    private var params: [AnyHashable: Any]?
    
    private init() {
        setup()
    }
    
    private func setup() {

    }
    
    func configure(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        branch.initSession(launchOptions: launchOptions) { (params, error) in
            guard error == nil else { return }
        
            guard let params = params else { return }

            if let betJSONString = params["bet"] as? String, let _ = Bet(JSONString: betJSONString) {
                self.params = params
                AppManager.shared.showNext()
            }
        }
    }
    
    func handlePushNotification(_ userInfo: [AnyHashable: Any]) {
        branch.handlePushNotification(userInfo)
    }
    
    func continueActivity(_ userActivity: NSUserActivity) {
        branch.continue(userActivity)
    }
    
    func open(_ application: UIApplication, url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return branch.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func getParams() -> [AnyHashable: Any]? {
        return params
    }
    
    func resetParams() {
        params = nil
    }
    
    func createShortURL(with bet: Bet? = nil, isInvite: Bool = false, completionHandler: ShortURLCompletionHandler? = nil) {
        
        var canonicalIdentifer: String
        if let betID = bet?.betID {
            canonicalIdentifer = betID
        } else {
            canonicalIdentifer = "BetIt_Invite_User \(UUID().uuidString)"
        }
        
        let buo = BranchUniversalObject(canonicalIdentifier: canonicalIdentifer)
        if let bet = bet {
            buo.title = bet.title ?? ""
            buo.contentDescription = bet.description ?? ""
            buo.contentMetadata.customMetadata["bet"] = bet.toJSONString() ?? ""
        } else {
            guard let currentUser = AppManager.shared.currentUser else { return }
            buo.title = currentUser.fullName
            buo.contentDescription = "Referral link"
        }
        
        let lp: BranchLinkProperties = BranchLinkProperties()
        lp.channel = "BetIT"
        lp.feature = "Invite User"
        
        buo.getShortUrl(with: lp) { (url, error) in
            completionHandler?(url, error)
        }
    }
    
    func trackUser(_ user: User) {
        guard let userID = user.userID, userID.count > 0 else { return }
        branch.setIdentity(userID)
    }
    
    func untrackUser() {
        if branch.isUserIdentified() {
            branch.logout()
        }
    }
    
}

