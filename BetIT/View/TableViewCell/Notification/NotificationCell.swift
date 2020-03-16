//
//  BetCell.swift
//  BetIT
//
//  Created by OSX on 8/2/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import UIKit

class NotificationCell: BaseTableViewCell {
    override class var identifier: String {
        return "notification_cell"
    }
    
    override class var height: CGFloat {
        return 80
    }
    
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblContent: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var initialNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgUser.layer.cornerRadius = min(imgUser.frame.width, imgUser.frame.height) / CGFloat(2.0)
    }
    
    func reset(with notification: BetNotification) {
        
        if let thumbnail = notification.bet?.otherUser?.thumbnail, thumbnail.count > 0 {
            imgUser.sd_setImage(with: UploadManager.shared.getReference(for: thumbnail))
            initialNameLabel.isHidden = true
        } else {
            imgUser.image = UIImage(named: "img_profile_placeholder")
            initialNameLabel.text = notification.bet?.otherUser?.fullName?.getInitial()
            initialNameLabel.isHidden = false
        }
        
        let isNew = notification.isNew ?? false
        if isNew {
            self.contentView.backgroundColor = UIColor(red: 237.0 / 255.0,
                                                       green: 245.0 / 255.0,
                                                       blue: 251.0 / 255.0, alpha: 1.0)
        } else {
            self.contentView.backgroundColor = .white
        }

        lblContent.attributedText = notification.attributedContentForNotificationCell()
        
        lblTime.text = notification.time.periodStringSince()
    }
}

//Attributed string for NotificationCell
extension BetNotification {
    func attributedContentForNotificationCell() -> NSAttributedString {
        guard let bet = self.bet else { return NSAttributedString(string: "") }
        guard let type = self.type else { return NSAttributedString(string: "") }
        guard let currentUser = AppManager.shared.currentUser else { return NSAttributedString(string: "") }
        
        // [START get_full_text]
        let betTitle = bet.title
        var username: String?
        if type == .betWon || type == .betLost {
            username = bet.targetUser?.fullName
        } else if type == .opponentClaimedWin || type == .opponentClaimedLost {
            username = bet.targetUser?.fullName
        }
        
        if username != nil, currentUser.fullName != nil, username! == currentUser.fullName! {
            username = "You"
        }
        
        // TODO: Remove type.format and use create format string
        // let fullText = String(format: type.format, username ?? "", betTitle ?? "")
        
        let fullText = NotificationManager.shared.getNotificationBody(for: self) ?? "N/A"
        
        // [END get_full_text]

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.lineHeightMultiple = 1.4
        let attributeForAll = [NSAttributedString.Key.paragraphStyle: paragraphStyle,
                               NSAttributedString.Key.foregroundColor: UIColor.black,
                               NSAttributedString.Key.font: AppFont.interstate.light(size: 12)]
        
        let attributedString = NSMutableAttributedString(string: fullText, attributes: attributeForAll)
        if let rangeUserName = fullText.range(of: username ?? "INVALID_STRING") {
            attributedString.addAttributes([NSAttributedString.Key.font: AppFont.interstate.regular(size: 12)], range: NSRange(rangeUserName, in: fullText))
        }
        
        if let rangeBetTitle = fullText.range(of: betTitle ?? "INVALID_STRING") {
            attributedString.addAttributes([NSAttributedString.Key.font: AppFont.interstate.regular(size: 12)], range: NSRange(rangeBetTitle, in: fullText))
        }
        return attributedString
    }
}
