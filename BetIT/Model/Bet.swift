//
//  Bet.swift
//  BetIT
//
//  Created by OSX on 8/2/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import UIKit
import ObjectMapper



class Bet: BaseObject {
    var betID: String?
    var title: String?
    var description: String?
    var wager: String?
    var status: BetStatus?
    var deadline: Date?
    var opponent: User?
    var owner: User?
    var ownerID: String?
    var opponentID: String?
    var targetUserID: String?
    var isInvite: Bool?
    var ownerDeleted: Bool = false
    var opponentDeleted: Bool = false
    
    func currentUserIsOwner() -> Bool {
        guard let currentUserID = AppManager.shared.currentUser?.userID else { return false }
        guard let ownerUserID = ownerID else { return false }
        return currentUserID == ownerUserID
    }
    
    func currentUserDidDelete() -> Bool {
        guard let currentUserID = AppManager.shared.currentUser?.userID else { return false }
        guard let ownerID = ownerID, let opponentID = opponentID else { return false }
        if currentUserID == ownerID {
            return ownerDeleted
        } else if currentUserID == opponentID {
            return opponentDeleted
        } else {
            return false
        }
    }
    
    func currentUserSetDelete() {
        guard let currentUserID = AppManager.shared.currentUser?.userID else { return }
        guard let ownerID = ownerID, let opponentID = opponentID else { return }
        if currentUserID == ownerID {
            ownerDeleted = true
        } else if currentUserID == opponentID {
            opponentDeleted = true
        }
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        betID                       <- map["betID"]
        title                       <- map["title"]
        wager                       <- map["wager"]
        description                 <- map["description"]
        status                      <- (map["status"], EnumTransform<BetStatus>())
        deadline                    <- (map["deadline"], DateTransform.shared)
        opponent                    <- map["opponent"]
        owner                       <- map["owner"]
        opponentID                  <- map["opponentID"]
        ownerID                     <- map["ownerID"]
        targetUserID                <- map["targetUserID"]
        isInvite                    <- map["invite"]
        if isInvite == nil {
            isInvite <- map["isInvite"]
        }
        ownerDeleted <- map["ownerDeleted"]
        opponentDeleted <- map["opponentDeleted"]
    }
    
    var otherUser: User? {
        guard let currentUser = AppManager.shared.currentUser else { return nil }
        guard let opponent = opponent, let owner = owner else { return nil }
        return (owner == currentUser) ? opponent : owner
    }
    
    var targetUser: User? {
        guard let targetUserID = self.targetUserID else { return nil }
        guard let opponentID = opponentID, let ownerID = ownerID else { return nil }
        if targetUserID == opponentID {
            return opponent
        } else if targetUserID == ownerID {
            return owner
        } else {
            return nil
        }
    }
    
    func getOtherUserID() -> String? {
        guard
            let currentUserID = AppManager.shared.currentUser?.userID,
            let opponentID = opponentID,
            let ownerID = ownerID
        else { return nil }
        
        if currentUserID == opponentID {
            return ownerID
        }
        
        if currentUserID == ownerID {
            return opponentID
        }
        
        return nil
    }
    
    var otherUserIsTarget: Bool {
        guard
            let targetUserID = self.targetUserID,
            let otherUserID = getOtherUserID()
        else { return false }
        return targetUserID == otherUserID
    }
    
    var currentUserIsTarget: Bool {
        guard
            let targetUserID = self.targetUserID,
            let currentUserID = AppManager.shared.currentUser?.userID
        else { return false }
        return targetUserID == currentUserID
    }
}



enum BetCategory: Int {
    case live = 0
    case unsettled = 1
    case settled = 2
    
    var title: String {
        switch self {
        case .live:
            return "live".localized()
        case .unsettled:
            return "unsettled".localized()
        case .settled:
            // return "settled".localized()
            return "closed".localized()
        }
    }
    
    static var all: [BetCategory] {
        return [.live, .unsettled, .settled]
    }
}


enum BetStatus: Int {
    case live = 0
    case pendingBetActionNeeded = 1
    case betWon = 2
    case opponentClaimedWin = 3
    case expired = 4
    case youClaimedWin = 5
    case betLost = 6
    case disputed = 7
    case declined = 8
    case endActionConfirmNeeded = 9

    var title: String? {
        switch self {
        case .live:
            return "live".localized()
        case .pendingBetActionNeeded:
            return "pending_bet_action_needed".localized()
        case .betWon:
            return "bet_won".localized()
        case .betLost:
            return "bet_lost".localized()
        case .opponentClaimedWin:
            return "claimed_win".localized()
        case .expired:
            return "expired".localized()
        case .youClaimedWin:
            return "claimed_win".localized()
        case .disputed:
            return "disputed".localized()
        case .declined:
            return "declined".localized()
        case .endActionConfirmNeeded:
            return "declined".localized()
        }
    }
    
    
    var color: UIColor {
        switch self {
        case .live:
            return #colorLiteral(red: 0.1215686275, green: 0.6156862745, blue: 0, alpha: 1)
        case .pendingBetActionNeeded:
            return #colorLiteral(red: 0.968627451, green: 0.7098039216, blue: 0, alpha: 1)
        case .betWon:
            return #colorLiteral(red: 0.6, green: 0.8274509804, blue: 0.9254901961, alpha: 1)
        case .opponentClaimedWin:
            return #colorLiteral(red: 0.4862745098, green: 0.2392156863, blue: 0.7882352941, alpha: 1)
        case .expired:
            return #colorLiteral(red: 0.462745098, green: 0.4588235294, blue: 0.462745098, alpha: 1)
        case .youClaimedWin:
            return #colorLiteral(red: 0.5960784314, green: 0.6549019608, blue: 0.08235294118, alpha: 1)
        case .betLost:
            return #colorLiteral(red: 0.06274509804, green: 0.1215686275, blue: 0.2901960784, alpha: 1)
        case .disputed:
            return #colorLiteral(red: 0.8784313725, green: 0.1254901961, blue: 0.1254901961, alpha: 1)
        case .declined:
            return #colorLiteral(red: 0.462745098, green: 0.4588235294, blue: 0.462745098, alpha: 1)
        case .endActionConfirmNeeded:
            return .clear
        }
    }
    
    var statusImage: UIImage? {
        switch self {
        case .live:
            return UIImage(named: "img_gradient_green_horz")
        case .pendingBetActionNeeded:
            return UIImage(named: "img_gradient_yellow_horz")
        case .betWon:
            return UIImage(named: "img_gradient_cyan_horz")
        case .opponentClaimedWin:
            return nil
        case .expired:
            return nil
        case .youClaimedWin:
            return UIImage(named: "img_gradient_cyan_horz")
        case .betLost:
            return nil
        case .disputed:
            return UIImage(named: "img_gradient_red_horz")
        case .declined:
            return UIImage(named: "img_gradient_vert_black")
        default:
            return nil
        }
    }
    
    var statusColor: UIColor? {
        switch self {
        case .live:
            return .darkForestGreen
        case .pendingBetActionNeeded:
            return .yellow
        case .betWon:
            return .lightCyan
        case .opponentClaimedWin:
            return .darkBlue
        case .expired:
            return .darkGray
        case .youClaimedWin:
            return .cyan
        case .betLost:
            return .darkBlue
        case .disputed:
            return .lightRed
        case .declined:
            return .black
        default:
            return nil
        }
    }
    
    var category: BetCategory {
        switch self {
        case .live, .pendingBetActionNeeded:
            return .live
        case .betWon, .betLost:
            return .settled
        case .declined, .expired:
            return .settled
        default:
            return .unsettled
        }
    }
    
    var section: String {
        switch self {
        case .live:
            return "active_bets".localized()
        case .pendingBetActionNeeded:
            return "bet_requests".localized()
        case .betWon:
            return "bets_won".localized()
        case .betLost:
            return "bets_lost".localized()
        case .opponentClaimedWin, .youClaimedWin:
            return "claims".localized()
        case .disputed:
            return "disputed".localized()
        // case .expired, .declined, .endActionConfirmNeeded:
        // case .expired, .endActionConfirmNeeded:
        case .endActionConfirmNeeded:
            return "wagers".localized()
        case .expired:
            return "expired".localized()
        case .declined:
            return "declined".localized()
        }
    }
    
    var gradientImage: UIImage? {
        switch self {
        case .live:
            return UIImage(named: "img_gradient_vert_green")
        case .pendingBetActionNeeded:
            return UIImage(named: "img_gradient_vert_yellow")
        case .betWon:
            return UIImage(named: "img_gradient_vert_cyan")
        case .opponentClaimedWin:
            return UIImage(named: "img_gradient_vert_purple")
        case .expired:
            return UIImage(named: "img_gradient_vert_gray")
        case .youClaimedWin:
            return UIImage(named: "img_gradient_vert_darkyellow")
        case .betLost:
            return UIImage(named: "img_gradient_vert_navy")
        case .disputed:
            return UIImage(named: "img_gradient_vert_red")
        case .declined:
            return UIImage(named: "img_gradient_vert_black")
        default:
            return nil
        }
    }
}

extension Bet {
    static func == (lhs: Bet, rhs: Bet) -> Bool {
        guard let lhsBetID = lhs.betID, let rhsBetID = rhs.betID else { return false }
        return lhsBetID == rhsBetID
    }
}
