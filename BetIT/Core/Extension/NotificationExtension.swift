//
//  NotificationExtension.swift
//  BetIT
//
//  Created by joseph on 8/25/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let DidConfirmBet = Notification.Name("DidConfirmBet")
    static let DidDeleteBet = Notification.Name("DidDeleteBet")
    static let DidSetDeadline = Notification.Name("DidSetDeadline")
    static let DidSelectUser = Notification.Name("DidSelectUser")
    static let NewFCMNotification = Notification.Name("NewFCMNotification")
    static let forceLogout = Notification.Name("forceLogout")
    static let DidUpdateBetStatus = Notification.Name("DidUpdateBetStatus")
    static let IncomingBetNotification = Notification.Name("IncomingBetNotification")
    static let DidReceiveBet = Notification.Name("DidReceiveBet")
    static let PresentBetNotification = Notification.Name("PresentBetNotification")
    static let DidSelectPhoneNumber = Notification.Name("DidSelectPhoneNumber")
}
