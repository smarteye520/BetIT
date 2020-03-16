//
//  NotificationManager.swift
//  BetIT
//
//  Created by joseph on 8/27/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import Foundation
import Firebase
import FirebaseMessaging
import ObjectMapper
import AlamofireObjectMapper
import Alamofire

typealias NotificationTopicSubscribeCompletionHandler = (Error?) -> Void

internal final class NotificationManager: NSObject {
    static let shared = NotificationManager()
    private let GCMMessageIDKey = "gcm.message_id"
    private let GCMNotificationDataKey = "gcm.notification.data"
    private let betDataKey = "bet"
    private let currentFCMTokenKey = "currentFCMTokenKey"
    private var sessionManager: SessionManager!
    private let fcmSendURL = "https://fcm.googleapis.com/fcm/send"
    
    
    private override init() {
        super.init()
        setup()
    }
    
    private func setup() {
        Messaging.messaging().delegate = self
        sessionManager = Alamofire.SessionManager(configuration: URLSessionConfiguration.default)
        getCurrentRegistrationToken()
    }
    
    func getCurrentRegistrationToken() {
        InstanceID.instanceID().instanceID { (result, error) in
            guard error == nil else { return }
            guard let result = result else { return }
            print("[DEBUG] NotificationManager.getCurrentRegistrationToken() - Remote InstanceID token: \(result.token)")
        }
    }
    
    func subscribe(user: User, completionHandler: NotificationTopicSubscribeCompletionHandler? = nil ) {
        guard let userNotificationTopic = getTopic(for: user) else { return }
        print("[DEBUG] NotificationManager.subscribe() - Subscribing user \(userNotificationTopic)")
        Messaging.messaging().subscribe(toTopic: userNotificationTopic) { error in
            if let error = error {
                print("[DEBUG] NotificationManager.subscribe() - ERROR: \(error.localizedDescription)")
            }
            completionHandler?(error)
            return
        }
        
        markUserAsSubscribed(user)
    }
    
    func isUserSubscribed(_ user: User) -> Bool {
        guard let userID = user.userID, userID.count > 0 else { return false }
        return UserDefaults.standard.bool(forKey: userID)
    }
    
    func markUserAsSubscribed(_ user: User) {
        guard let userID = user.userID, userID.count > 0 else { return }
        UserDefaults.standard.set(true, forKey: userID)
    }
    
    func markUserAsUnsubscribed(_ user: User) {
        guard let userID = user.userID, userID.count > 0 else { return }
        UserDefaults.standard.set(false, forKey: userID)
    }
    
    func unsubscribe(user: User, completionHandler: NotificationTopicSubscribeCompletionHandler? = nil) {
        guard let userNotificationTopic = getTopic(for: user) else { return }
        Messaging.messaging().unsubscribe(fromTopic: userNotificationTopic) { (error) in
            if let error = error {
                print("[DEBUG] NotificationManager.unsubscribe() - ERROR: \(error.localizedDescription)")
            }
            completionHandler?(error)
            return
        }
        markUserAsUnsubscribed(user)
    }
    
    func getTopic(for user: User) -> String? {
        guard let userID = user.userID else { return nil }
        return "topic_notifications_user_\(userID)"
    }
    
    func createNotification(with bet: Bet, type: BetNotificationType, sender: User? = nil, recipient: User? = nil) -> BetNotification {
        let notification = BetNotification()
        notification.bet = bet
        if let sender = sender {
            notification.sender = sender
            notification.senderID = sender.userID
        } else {
            notification.sender = bet.owner
            notification.senderID  = bet.ownerID
        }
        
        if let recipient = recipient {
            notification.recipient = recipient
            notification.recipientID = recipient.userID
        } else {
            notification.recipient = bet.opponent
            notification.recipientID = bet.opponentID
        }
        
        notification.createdAt = Date()
        notification.time = Date()
        notification.betID = bet.betID
        notification.type = type
        notification.isNew = true
        return notification
    }
    
    func sendNotification(_ notification: BetNotification) {
        
        guard let senderID = notification.senderID, let recipientID = notification.recipientID else { return }
        // guard senderID != recipientID else { return }
        guard senderID.count > 0, recipientID.count > 0 else { return }
        
        guard let recipient = notification.recipient else { return }

        recipient.getNotificationSettings { [weak self] (notificationSettings) in
            guard let strongSelf = self else { return }
            guard let settings = notificationSettings else { return }
            guard let betStatus = notification.bet?.status else { return }

            // If this is a bet request and other user explicitly specified that they do not want bet request notifications then don't send
            if betStatus == .pendingBetActionNeeded && !settings.isRequests {
                return
            }
            
            if (betStatus == .youClaimedWin || betStatus == .opponentClaimedWin) && !settings.isClaimed {
                return
            }
            
            if betStatus == .disputed && !settings.isDisputed {
                return
            }

            guard let targetTopic = strongSelf.getTopic(for: recipient) else { return }
            
            let headers: [String: String] = [
                "Content-Type": "application/json",
                "Authorization": "key=\(FirebaseGCM.LegacyAPIKey)"
            ]
            
            let body = strongSelf.getNotificationBody(for: notification)
            
            let notificationBody: [String: Any] = [
                "body": body ?? "",
                "data": notification.toJSON()
            ]
            
            // Since this is topic based notification,
            let params: [String: Any] = [
                "to": "/topics/\(targetTopic)",
                "priority": "high",
                "notification": notificationBody,
            ]
            
            let request = strongSelf.sessionManager.request(strongSelf.fcmSendURL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)

            request.response { (_) in }
            request.resume()

        }
        
        
    }
    
    func getNotificationBody(for notification: BetNotification) -> String? {
        guard let currentUser = AppManager.shared.currentUser else { return nil }
        guard notification.recipient != nil, let sender = notification.sender else { return nil }
        guard sender.userID != nil else { return nil }
        
        guard let bet = notification.bet else { return nil }
        guard let notificationType = notification.type else { return nil }
        var alertText: String?
        
        switch notificationType {
        case .accepted:
            alertText = "\(sender.fullName ?? "BetIT user") accepted your bet \(bet.title ?? "")"
        case .challengeRequested:
            alertText = "\(sender.fullName ?? "BetIT user") challenged you to a bet: \"\(bet.title ?? "")\""
        case .declined:
            alertText = "\(sender.fullName ?? "BetIT user") declined your bet request"
        case .disputed:
            alertText = "\(sender.fullName ?? "BetIT user") disputed your bet: \"\(bet.title ?? "")\""
        case .opponentClaimedLost, .opponentClaimedWin:
            guard let targetUserID = bet.targetUserID else { return nil }
            var textBody: String
            if targetUserID == sender.userID {
                textBody = "claimed a win on bet: \"\(bet.title ?? "")\""
            } else {
                textBody = "claimed a lost on bet: \"\(bet.title ?? "")\""
            }
            
            let username = sender.fullName ?? "BetIT user"
            alertText = "\(username) \(textBody)"
        case .betLost, .betWon:
            // If bet is won, send the notification to the loser (other user) saying that they lost
            guard let targetUserID = bet.targetUserID else { return nil }
            var textBody: String
            if targetUserID == sender.userID {
                textBody = "won on bet: \"\(bet.title ?? "")\""
            } else {
                textBody = "lost on bet: \"\(bet.title ?? "")\""
            }
            alertText = "\(sender.fullName ?? "BetIT user") \(textBody)"
        case .endActionConfirmNeeded:
            // User B (current user) confirmed User A (other user) won
            guard let targetUserID = bet.targetUserID else { return nil }
            guard let otherUser = bet.otherUser, let otherUserID = otherUser.userID else { return  nil }
            
            var username: String?
            // Get the loser of the bet ; note: target user id contains the winner
            if targetUserID == otherUserID {
                username = currentUser.fullName
            } else {
                username = otherUser.fullName
            }
            alertText = "\(username ?? "BetIT user") conceded on bet: \"\(bet.title ?? "")\""
        default:
            break
        }
        return alertText
    }
    
    
    func notification(from userInfo: [AnyHashable: Any]) -> BetNotification? {
        print("[DEBUG] UserInfo: \(userInfo)")
        print("[DEBUG] Notification: \(userInfo["gcm.notification"])")
        print("[DEBUG] Notification_Data: \(userInfo["gcm.notification.data"])")

        guard let notificationJSONString = userInfo["gcm.notification.data"] as? String else { return nil }
        guard let notificationData = notificationJSONString.data(using: .utf8) else { return nil }
        guard let notificationJSON = try? JSONSerialization.jsonObject(with: notificationData, options: []) as? [String: Any] else { return nil }
        return BetNotification(JSON: notificationJSON)
    }
    
    func handleRemoteNotification(_ userInfo: [AnyHashable: Any]) {
        guard let notification = notification(from: userInfo) else { return }
        
        NotificationCenter.default.post(name: .IncomingBetNotification,
                                        object: nil,
                                        userInfo: ["notification": notification])
        if let bet = notification.bet {
            NotificationCenter.default.post(name: .DidReceiveBet,
                                            object: nil,
                                            userInfo: ["bet": bet])
        }
    }
    
    func storeToken(_ token: String) {
        guard token.count > 0 else { return }
        UserDefaults.standard.set(token, forKey: currentFCMTokenKey)
    }
}

// MARK: - MessagingDelegate

extension NotificationManager: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        if let currentToken = UserDefaults.standard.string(forKey: currentFCMTokenKey) {
            if currentToken != fcmToken {
                storeToken(fcmToken)
            }
        } else {
            storeToken(fcmToken)
        }
        if let user = AppManager.shared.currentUser {
            subscribe(user: user)
        }
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        NotificationCenter.default.post(name: .NewFCMNotification, object: nil, userInfo: remoteMessage.appData)
    }
    
}
