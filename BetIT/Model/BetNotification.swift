//
//  Bet.swift
//  BetIT
//
//  Created by OSX on 8/6/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import UIKit
import ObjectMapper

enum BetNotificationType: Int {
    case accepted = 0
    case challengeRequested = 1
    case opponentClaimedLost = 2
    case opponentClaimedWin = 3
    case expired = 4
    case disputed = 5
    case declined = 6
    case betWon = 7
    case betLost = 8
    case endActionConfirmNeeded = 9
    
    var format: String {
        switch self {
        case .accepted:
            return "notification_accepted".localized()
        case .challengeRequested:
            return "notification_challengeRequested".localized()
        case .opponentClaimedLost:
            return "notification_opponentClaimedLost".localized()
        case .opponentClaimedWin:
            return "notification_opponentClaimedWin".localized()
        case .expired:
            return "notification_expired".localized()
        case .disputed:
            return "notification_disputed".localized()
        case .declined:
            return "notification_declined".localized()
        case .betLost:
            return "notification_bet_lost".localized()
        case .betWon:
            return "notification_bet_won".localized()
        case .endActionConfirmNeeded:
            return "notification_end_action_confirm".localized()
        }
    }
}

class BetNotification: BaseObject {
    var notificationID: String?
    var senderID: String?
    var recipientID: String?
    var sender: User?
    var recipient: User?
    var betID: String?
    var isNew: Bool?
    
    var betId: Int!
    var type: BetNotificationType!
    var time: Date!
    var bet: Bet?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        betId                       <- map["betID"]
        type                        <- (map["type"], EnumTransform<BetNotificationType>())
        time                        <- (map["time"], DateTransform.shared)
        bet                         <- map["bet"]
        notificationID              <- map["notificationID"]
        senderID                    <- map["senderID"]
        recipientID                 <- map["recipientID"]
        sender                      <- map["sender"]
        recipient                   <- map["recipient"]
        isNew                       <- map["new"]
        if isNew == nil {
            isNew <- map["isNew"]
        }
    }
}

extension BetNotification {
    static func == (lhs: BetNotification, rhs: BetNotification) -> Bool {
        guard let lhsID = lhs.notificationID, let rhsID = rhs.notificationID else { return false}
        return lhsID == rhsID
    }
}
