//
//  DatabaseManager.swift
//  BetIT
//
//  Created by joseph on 8/23/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

typealias CreateUserCompletionHandler = (User?, Error?) -> Void
typealias UpdateUserCompletionHandler = (Error?) -> Void
typealias CheckEmailCompletionHandler = (User?, Error?) -> Void

typealias FetchBetsCompletionHandler = ([Bet]?, Error?) -> Void
typealias AddBetCompletionHandler = (Bet?, Error?) -> Void
typealias UpdateBetCompletionHandler = (Error?) -> Void
typealias DeleteBetCompletionHandler = (Error?) -> Void
typealias GetBetCompletionHandler = (Bet?, Error?) -> Void

typealias FetchNotificationsCompletionHandler = ([BetNotification]?, Error?) -> Void
typealias AddNotificationCompletionHandler = (BetNotification?, Error?) -> Void
typealias UpdateNotificationCompletionHandler = (Error?) -> Void
typealias DeleteNotificationCompletionHandler = (Error?) -> Void
typealias FetchUsersCompletionHandler = ([User]?, Error?) -> Void
typealias GetUserCompletionHandler = (User?, Error?) -> Void

typealias FetchNotificationSettingsCompletionHandler = (NotificationSettings?, Error?) -> Void
typealias UpdateNotificationSettingsCompletionHandler = (Error?) -> Void

typealias FetchUserReferralLinkCompletionHandler = (UserReferral?, Error?) -> Void
typealias UpdateUserReferralLinkCompletionHandler = (Error?) -> Void


let NotFoundError = 404

internal final class DatabaseManager {
    static let shared = DatabaseManager()
    let Users = "Users"
    let Bets = "Bets"
    let Notifications = "Notifications"
    let NotificationSettingsCollection = "NotificationSettings"
    let UserReferralsCollection = "UserReferrals"
    
    private let db = Firestore.firestore()
    
    private init() {
        setup()
    }
    
    // MARK: - Setup
    
    private func setup() {
        // Do some set up
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        db.settings = settings
    }
    
    // MARK : - User
    
    func checkEmailTaken(email: String, completionHandler: CheckEmailCompletionHandler? = nil)
    {
        db.collection(Users).whereField("email", isEqualTo: email).getDocuments { (querySnapshot, error) in
            if let error = error {
                completionHandler?(nil, error)
                return
            }
            
            guard let snapshot = querySnapshot else {
                let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "There was an error signing up."
                ])
                completionHandler?(nil, error)
                return
            }
            
            // User exists with the specified email, show error
            if let existingUserDocument = snapshot.documents.first  {
                let existingUser = User(JSON: existingUserDocument.data())
                completionHandler?(existingUser, error)
                return
            }
            
            // No user and no error
            completionHandler?(nil, nil)
        }
    }
    
    func createFacebookUser(_ user: User, completionHandler: CreateUserCompletionHandler? = nil) {
        guard let userID = user.userID, user.isFacebookUser == true else { return }
        
        print("[DEBUG] DatabaseManager.shared.createFacebookUser() - USER_TO_JSON: \(user.toJSON())")
        db.collection(self.Users).document(userID).setData(user.toJSON()) { error in
            completionHandler?(user, error)
        }
    }
    
    
    func createUser(userID: String?, email: String, password: String, firstName: String, lastName: String, completionHandler: CreateUserCompletionHandler? = nil)
    {
        checkEmailTaken(email: email) { (user, error) in
            if let error = error {
                completionHandler?(nil, error)
                return
            }
            
            // User exists with the email, show error
            if let _ = user {
                let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Email already taken"
                ])
                completionHandler?(nil, error)
                return
            }
            
            // Create new user since email is not taken
            var newUserDocRef: DocumentReference
            if let userID = userID {
                newUserDocRef = self.db.collection(self.Users).document(userID)
            } else {
                newUserDocRef = self.db.collection(self.Users).document()
            }
            
            let newUser = User()
            newUser.userID = newUserDocRef.documentID
            newUser.email = email
            newUser.firstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
            newUser.lastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
            newUser.name = "\(firstName) \(lastName)"
            newUser.createdAt = Date()
            newUserDocRef.setData(newUser.toJSON()) { error in
                if let error = error {
                    completionHandler?(nil, error)
                    return
                }
                completionHandler?(newUser, nil)
            }
        }
    }
    
    func updateUser(_ user: User, completionHandler: UpdateUserCompletionHandler? = nil) {
        guard let userID = user.userID else { return }
        db.collection(Users).document(userID).updateData(user.toJSON()) { error in
            completionHandler?(error)
        }
    }
    
    // MARK: - Bets
    func getBet(_ betID: String, completionHandler: GetBetCompletionHandler? = nil) {
        guard betID.count > 0 else { return }
        db.collection(Bets).document(betID).getDocument { (docSnapshot, error) in
            if let error = error {
                completionHandler?(nil, error)
                return
            }
            
            guard let docSnapshot = docSnapshot else {
                let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Could not fetch bet"
                ])
                completionHandler?(nil, error)
                return
            }
            
            guard let betData = docSnapshot.data() else {
                let error = NSError(domain: "AppErrorDomain", code: NotFoundError, userInfo: [NSLocalizedDescriptionKey: "Bet does not exist"])
                completionHandler?(nil, error)
                return
            }
            
            guard let bet = Bet(JSON: betData) else {
                let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Bet does not exist"])
                completionHandler?(nil, error)
                return
            }
            
            completionHandler?(bet, nil)
        }
    }
    
    func addBet(_ bet: Bet, completionHandler: AddBetCompletionHandler? = nil) {
        // guard bet.betID
        guard bet.betID == nil else { return }
        guard bet.opponent != nil else { return }
        guard bet.owner != nil else { return }

        let newBetDocRef = db.collection(Bets).document()
        bet.betID = newBetDocRef.documentID
        newBetDocRef.setData(bet.toJSON()) { error in
            if let error = error {
                completionHandler?(nil, error)
                return
            }
            completionHandler?(bet, nil)
        }
    }
    
    func updateBet(_ bet: Bet, completionHandler: UpdateBetCompletionHandler? = nil) {
        guard bet.betID != nil else { return }
        guard let betID = bet.betID, betID.count > 0 else { return }
        let betDocRef = db.collection(Bets).document(betID)
        betDocRef.updateData(bet.toJSON()) { error in
            completionHandler?(error)
        }
    }
    
    
    func fetchBets(completionHandler: FetchBetsCompletionHandler? = nil) {
        guard let currentUserID = AppManager.shared.currentUser?.userID else { return }
        guard currentUserID.count > 0 else { return }
        // guard betQuery == "ownerID" || betQuery == "opponentID" else { return }

        // Fetch all bets where the owner is the current user or the opponent is the current user
        db.collection(Bets).whereField("ownerID", isEqualTo: currentUserID).getDocuments { (querySnapshot, error) in
            if let error = error {
                completionHandler?(nil, error)
                return
            }
            guard let snapshot = querySnapshot else {
                let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Error fetching bets"
                ])
                completionHandler?(nil, error)
                return
            }
            // Add all bets that the current user created
            var bets = [Bet]()
            for document in snapshot.documents {
                guard let bet = Bet(JSON: document.data()) else { continue }
                bets.append(bet)
            }

            // Fetch all bets where opponent is the current user and merge the bets
            self.db.collection(self.Bets).whereField("opponentID", isEqualTo: currentUserID).getDocuments(completion: { (querySnapshot, error) in
                if let error = error {
                    completionHandler?(nil, error)
                    return
                }
                guard let snapshot = querySnapshot else {
                    let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [
                        NSLocalizedDescriptionKey: "Error fetching bets"
                    ])
                    completionHandler?(nil, error)
                    return
                }
                for document in snapshot.documents {
                    guard let bet = Bet(JSON: document.data()) else { continue }
                    bets.append(bet)
                }
                // Sort by latest bets first
                bets.sort(by: { (bet1, bet2) -> Bool in
                    guard let deadline1 = bet1.deadline, let deadline2 = bet2.deadline else { return false }
                    return deadline1 > deadline2
                })
                // Merge bets, sort them, call completion handler
                completionHandler?(bets, nil)
            })
        }
    }
    
    func deleteBet(_ bet: Bet, completionHandler: DeleteBetCompletionHandler? = nil) {
        guard let betID = bet.betID else { return }
        guard let currentUserID = AppManager.shared.currentUser?.userID else { return }
        guard let ownerID = bet.ownerID else { return }
        guard let opponentID = bet.opponentID else { return }
        guard currentUserID == ownerID || currentUserID == opponentID else { return }
        
        db.collection(Bets).document(betID).delete { (error) in
            completionHandler?(error)
        }
    }

    // MARK: - Notifications
    func deleteNotification(_ notification: BetNotification, completionHandler:  DeleteNotificationCompletionHandler? = nil) {
        guard let notificationID = notification.notificationID else { return }
        guard let recipientID = notification.recipientID, let senderID = notification.senderID else { return }
        guard let currentUserID = AppManager.shared.currentUser?.userID, currentUserID.count > 0 else { return }
        guard currentUserID == recipientID || currentUserID == senderID else { return }

        db.collection(Notifications).document(notificationID).delete { (error) in
            completionHandler?(error)
        }
    }
    
    func addNotification(_ notification: BetNotification, completionHandler: AddNotificationCompletionHandler? = nil) {
        
        // Already in firestore
        guard notification.notificationID == nil else { return }
        guard notification.senderID != nil else { return }
        guard notification.recipientID != nil else { return }
        guard notification.sender != nil else { return }
        guard notification.recipient != nil else { return }
        
        let newNotificationDocRef = db.collection(Notifications).document()
        notification.notificationID = newNotificationDocRef.documentID
        newNotificationDocRef.setData(notification.toJSON()) { error in
            if let error = error {
                completionHandler?(nil, error)
                return
            }
            completionHandler?(notification, nil)
        }
    }
    
    func updateNotification(_ notification: BetNotification, completionHandler: UpdateNotificationCompletionHandler? = nil) {
        guard let notificationID = notification.notificationID else { return }
        let notificationDocRef = db.collection(Notifications).document(notificationID)
        notificationDocRef.updateData(notification.toJSON()) { error in
            if let error = error {
                completionHandler?(error)
                return
            }
            completionHandler?(nil)
        }
    }
    
    func updateNotificationRead(_ notification: BetNotification, completionHandler: UpdateNotificationCompletionHandler? = nil) {
        guard let notificationID = notification.notificationID else { return }
        let notificationDocRef = db.collection(Notifications).document(notificationID)
        notificationDocRef.setData(["new": false], merge: true) { error in
            completionHandler?(error)
        }
    }
    
    func fetchNotifications(completionHandler: FetchNotificationsCompletionHandler? = nil) {
        guard let currentUserID = AppManager.shared.currentUser?.userID else { return }
        guard currentUserID.count > 0 else { return }
        
        db.collection(Notifications).whereField("recipientID", isEqualTo: currentUserID).getDocuments { (querySnapshot, error) in
            if let error = error {
                completionHandler?(nil, error)
                return
            }
            guard let snapshot = querySnapshot else {
                let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Error fetching notifications"
                ])
                completionHandler?(nil, error)
                return
            }
            
            var notifications = [BetNotification]()
            for document in snapshot.documents {
                if let notification = BetNotification(JSON: document.data()) {
                    notifications.append(notification)
                }
            }
            
            // Latest notifications first
            notifications.sort(by: { (notif1, notif2) -> Bool in
                guard let date1 = notif1.createdAt, let date2 = notif2.createdAt else { return false}
                return date1 > date2
            })
            
            completionHandler?(notifications, nil)
        }
    }
    
    func updateNotificationSettings(_ notificationSettings: NotificationSettings, for user: User, completionHandler: UpdateNotificationSettingsCompletionHandler? = nil) {
        guard let userID = user.userID else { return }
        guard userID.count > 0 else { return }

        db.collection(NotificationSettingsCollection).whereField("userID", isEqualTo: userID).getDocuments { (querySnapshot, error) in
            if let error = error {
                completionHandler?(error)
                return
            }
            
            guard let snapshot = querySnapshot else {
                let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Could not fetch snapshot"
                ])
                completionHandler?(error)
                return
            }
            
            if let document = snapshot.documents.first {
                document.reference.setData(notificationSettings.toJSON(), merge: true) { error in
                    completionHandler?(error)
                }
            } else {
                // Does not exist create one
                let document = self.db.collection(self.NotificationSettingsCollection).document()
                document.setData(notificationSettings.toJSON()) { error in
                    completionHandler?(error)
                }
            }
            
        }
    }
    
    func fetchNotificationSettings(for userID: String, completionHandler: FetchNotificationSettingsCompletionHandler? = nil) {
        guard userID.count > 0 else { return }
        
        db.collection(NotificationSettingsCollection).whereField("userID", isEqualTo: userID).getDocuments { (querySnapshot, error) in
            if let error = error {
                completionHandler?(nil, error)
                return
            }
            guard let snapshot = querySnapshot else {
                let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "No snapshot"
                ])
                completionHandler?(nil, error)
                return
            }
            guard let data = snapshot.documents.first?.data(), let notificationSettings = NotificationSettings(JSON: data) else  {
                let errorCode: Int = (snapshot.documents.first?.exists ?? false) ? -1 : NotFoundError
                let error = NSError(domain: "AppErrorDomain", code: errorCode, userInfo: [
                    NSLocalizedDescriptionKey: "Could not fetch user"
                ])
                completionHandler?(nil, error)
                return
            }
            
            completionHandler?(notificationSettings, nil)
        }
    }
    
    // MARK: - Users
    
    func getUser(_ userID: String, completionHandler: GetUserCompletionHandler? = nil) {
        guard userID.count > 0 else { return }
        
        db.collection(Users).document(userID).getDocument { (querySnapshot, error) in
            if let error = error {
                completionHandler?(nil, error)
                return
            }
            guard let snapshot = querySnapshot else {
                let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "No snapshot"
                ])
                completionHandler?(nil, error)
                return
            }
            guard let data = snapshot.data(), let user = User(JSON: data) else  {
                let errorCode: Int = snapshot.exists ? -1 : NotFoundError
                let error = NSError(domain: "AppErrorDomain", code: errorCode, userInfo: [
                    NSLocalizedDescriptionKey: "Could not fetch user"
                ])
                completionHandler?(nil, error)
                return
            }
            completionHandler?(user, nil)
        }
    }
    
    func fetchUsers(with query: String, completionHandler: FetchUsersCompletionHandler? = nil) {
        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard query.count > 0 else { return }
        
        let nameComps = query.components(separatedBy: " ")
        var firstName: String?
        var lastName: String?
        
        if nameComps.count >= 2 {
            firstName = nameComps[0]
            lastName = nameComps[1]
        } else {
            firstName = nameComps[0]
        }
        
        
        let fetchCompletionHandler: FIRQuerySnapshotBlock = { (querySnapshot, error) in
            if let error = error {
                completionHandler?(nil, error)
                return
            }
            guard let snapshot = querySnapshot else {
                let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Error fetching notifications"
                ])
                completionHandler?(nil, error)
                return
            }
            var users = [User]()
            for document in snapshot.documents {
            
                guard let user = User(JSON: document.data()) else { continue }
                
                if let lastName = lastName {
                    if let userLastName = user.lastName, userLastName.lowercased().contains(lastName.lowercased()) {
                        users.append(user)
                    }
                } else {
                    users.append(user)
                }
            }
            completionHandler?(users, nil)
        }
        
        if let firstName = firstName?.capitalized, let _ = lastName?.capitalized {
            // First name
            var query = db.collection(Users).whereField("firstName", isGreaterThanOrEqualTo: firstName)
            if let next = firstName.nextLetter(firstName.getInitial()) {
                query = query.whereField("firstName", isLessThan: next)
            }
            
            /*
            // Last name
            query = query.whereField("lastName", isGreaterThanOrEqualTo: lastName)
            if let next = lastName.nextLetter(lastName.getInitial()) {
                query = query.whereField("lastName", isLessThan: next)
            }
            */
            // Fetch
            query.getDocuments(completion: fetchCompletionHandler)

        } else if let firstName = firstName {
            // First name
            var query = db.collection(Users).whereField("firstName", isGreaterThanOrEqualTo: firstName)
            if let next = firstName.nextLetter(firstName.getInitial()) {
                query = query.whereField("firstName", isLessThan: next)
            }
            // Fetch
            query.getDocuments(completion: fetchCompletionHandler)
        } 
    }
    
    // MARK: User referrals
    
    func fetchUserReferral(for user: User, completionHandler: FetchUserReferralLinkCompletionHandler? = nil) {
        guard let userID = user.userID else { return }
        guard userID.count > 0 else { return }

        db.collection(UserReferralsCollection).whereField("userID", isEqualTo: userID).getDocuments { (querySnapshot, error) in
            if let error = error {
                completionHandler?(nil, error)
                return
            }
            
            guard let snapshot = querySnapshot else {
                let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not fetch snapshot"])
                completionHandler?(nil, error)
                return
            }
            
            guard let data = snapshot.documents.first?.data(), let userReferral = UserReferral(JSON: data) else  {
                let errorCode: Int = (snapshot.documents.first?.exists ?? false) ? -1 : NotFoundError
                let error = NSError(domain: "AppErrorDomain", code: errorCode, userInfo: [
                    NSLocalizedDescriptionKey: "Could not fetch user"
                ])
                completionHandler?(nil, error)
                return
            }
            
            completionHandler?(userReferral, nil)
        }

    }
    
    func updateUserReferral(_ userReferral: UserReferral, for user: User, completionHandler: UpdateUserReferralLinkCompletionHandler? = nil) {
        
        // Param checking
        guard let userID = user.userID else { return }
        guard userID.count > 0 else { return }
        
        guard let referralLink = userReferral.referralLink else { return }
        guard referralLink.count > 0 else { return }
        
        db.collection(UserReferralsCollection).whereField("userID", isEqualTo: userID).getDocuments { (querySnapshot, error) in
            if let error = error {
                completionHandler?(error)
                return
            }
            
            guard let snapshot = querySnapshot else {
                let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not fetch snapshot"])
                completionHandler?(error)
                return
            }
            
            if let document = snapshot.documents.first {
                document.reference.setData(userReferral.toJSON(), merge: true) { error in
                    completionHandler?(error)
                }
            } else {
                let document = self.db.collection(self.UserReferralsCollection).document()
                document.setData(userReferral.toJSON()) { error in
                    completionHandler?(error)
                }
            }
        }
    }
}
