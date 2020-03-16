//
//  BetViewModel.swift
//  BetIT
//
//  Created by joseph on 10/30/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import Foundation
import FirebaseUI


internal class BetViewModel {
    let maxTitleLength = 50
    internal var deadlineDate: Date?
    internal var bet: Bet

    var reloadData: (() -> Void)?

    init(bet: Bet) {
        self.bet = bet
    }
    
    var betID: String? {
        return bet.betID
    }
    
    func setTargetUserID(isOtherUser: Bool = false) {
        let targetUser = isOtherUser ? bet.otherUser : AppManager.shared.currentUser
        guard let targetUserID = targetUser?.userID else { return }
        bet.targetUserID = targetUserID
    }
    
    var isInvitingBet: Bool {
        return bet.isInvite ?? false 
    }
    
    var title: String {
        return bet.title ?? ""
    }
    
    var betStatus: BetStatus? {
        return bet.status
    }
    
    var thumbnail: String? {
        guard let thumbnail = bet.otherUser?.thumbnail, thumbnail.count > 0 else { return nil}
        return thumbnail
    }
    
    var usernameInitial: String? {
        return bet.otherUser?.fullName?.getInitial()
    }
    
    var photoReference: StorageReference? {
        guard let thumbnail = self.thumbnail else { return nil }
        return UploadManager.shared.getReference(for: thumbnail)
    }
    
    var usernameText: String? {
        return bet.opponent?.fullName
    }
    
    var description: String {
        return bet.description ?? ""
    }
    
    var wager: String {
        return bet.wager ?? ""
    }
    
    var hasDeadline: Bool {
        return bet.deadline != nil 
    }

    var deadlineText: String? {
        guard let deadline = bet.deadline else { return nil }
        return deadline.string(withFormat: Constant.Format.betTime)
    }
    
    func formatBetTimeRemaining(_ deadline: Date) -> String {
        let now = Date()
        let daysRemaining = deadline.daysSince(now)
        if daysRemaining > 0 {
            return "\(daysRemaining) \(daysRemaining == 1 ? "day" : "days")\n remaining"
        }
        
        // Hours
        let hoursRemaining = deadline.hoursSince(now)
        if hoursRemaining > 0 {
            return "\(hoursRemaining) \(hoursRemaining == 1 ? "hour" : "hours")\n remaining"
        }
        
        // Minutes
        let minsRemaining = max(0, deadline.minutesSince(now))
        return "\(minsRemaining) \(minsRemaining == 1 ? "min" : "mins")\n remaining"
    }
    
    var betTimeRemaining: String? {
        guard let deadline = bet.deadline else { return nil }
        return formatBetTimeRemaining(deadline)
    }
    
    var targetUserID: String? {
        return bet.targetUserID
    }

    func isValidTitle(_ title: String?) -> Bool {
        guard let title = title else { return false }
        return title.count <= maxTitleLength
    }
    
    func getTitleLimitAttributedText(_ betTitle: String?) -> NSAttributedString? {
        guard let betTitle = betTitle else { return nil }
        
        let labelText = "\(betTitle.count) / \(maxTitleLength)"

        let foregroundColor = betTitle.count > maxTitleLength ? UIColor.red : UIColor.black

        let attributedLabelText = NSMutableAttributedString(string: labelText)
        let defaultAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor:  UIColor(red: 199.0 / 255.0, green: 199.0 / 255.0, blue: 205.0 / 255.0, alpha: 1)
,
                                                                NSAttributedString.Key.font: UIFont(name: "Interstate-Light", size: 13) ?? UIFont.systemFont(ofSize: 13)]
        
        let selectedAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: foregroundColor,
                                                                 NSAttributedString.Key.font: UIFont(name: "Interstate-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)]
     
        guard let selectedRange = labelText.range(of: "\(betTitle.count)") else { return nil }
        guard let defaultRange = labelText.range(of: labelText) else { return nil }
        attributedLabelText.setAttributes(defaultAttributes, range: NSRange(defaultRange, in: labelText))
        attributedLabelText.setAttributes(selectedAttributes, range: NSRange(selectedRange, in: labelText))
        
        return attributedLabelText
    }
    
    
    func setDeadline(_ date: Date?) {
        deadlineDate = date
        reloadData?()
    }

}

