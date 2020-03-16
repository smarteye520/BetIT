//
//  BetCell.swift
//  BetIT
//
//  Created by OSX on 8/2/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import UIKit

protocol BetCellDelegate: AnyObject {
    func betCell(_ betCell: BetCell, didPressConfirmButton confirmButton: UIButton)
    func betCell(_ betCell: BetCell, didPressDenyButton denyButton: UIButton)
    func betCell(_ betCell: BetCell, didPressSettledButton settledButton: UIButton)

    func betCell(_ betCell: BetCell, didPressDeclineBetRequestButton declineButton: UIButton)
    func betCell(_ betCell: BetCell, didPressAcceptBetRequestButton acceptButton: UIButton)
}

class BetCell: BaseTableViewCell {
    override class var identifier: String {
        return "bet_cell"
    }
    
    override class var height: CGFloat {
        return 135
    }
    
    weak var delegate: BetCellDelegate?
    @IBOutlet weak var imgStatus: UIImageView!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var initialNameLabel: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblBetTitle: UILabel!
    @IBOutlet weak var lblBetDescription: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var denyButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var settledButton: UIButton!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var stackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var acceptBetRequestButton: UIButton!
    @IBOutlet weak var declineBetRequestButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgUser.layer.cornerRadius = min(imgUser.frame.width, imgUser.frame.height) / CGFloat(2.0)
    }
    
    func reset(with bet: Bet) {
        // imgUser.layer.cornerRadius = min(imgUser.frame.height, imgUser.frame.width) / CGFloat(2.0)

        guard let currentUser = AppManager.shared.currentUser else { return }
        guard let currentUserID = currentUser.userID else { return }
        
        // guard let opponent = bet.opponent, let owner = bet.owner else { return }
        guard let otherUser = bet.otherUser else { return }
        
        if let url = otherUser.thumbnail, url.count > 0 {
            imgUser?.sd_setImage(with: UploadManager.shared.getReference(for: url))
            initialNameLabel.isHidden = true
        } else {
            imgUser?.sd_setImage(with: nil, placeholderImage: UIImage(named: "img_profile_placeholder"))
            initialNameLabel.isHidden = false
            initialNameLabel.text = otherUser.fullName?.getInitial()
        }
        
        lblUserName?.text = otherUser.fullName
        
        guard let status = bet.status else { return }
        imgStatus?.image = status.gradientImage
        lblBetTitle?.text = bet.title
        /*
        if let updatedAtStr = bet.updatedAt?.periodStringSince() {
            lblTime.text = updatedAtStr
        } else {
            lblTime.text = bet.createdAt?.periodStringSince()
        }
        */
        if let dateString = bet.updatedAt?.homeBetCellString() {
            lblTime.text = dateString
        } else {
            lblTime.text = bet.createdAt?.homeBetCellString()
        }
        
        switch status {
        case .live, .pendingBetActionNeeded, .expired:
            lblStatus?.text = bet.status?.title
            lblStatus?.textColor = bet.status?.color
        case .opponentClaimedWin, .youClaimedWin:
            guard let targetUser = bet.targetUser else { return }
            guard let otherUser = bet.otherUser else { return }
            if let url = otherUser.thumbnail, url.count > 0 {
                imgUser?.sd_setImage(with: UploadManager.shared.getReference(for: url))
                initialNameLabel.isHidden = true
            } else {
                imgUser?.sd_setImage(with: nil, placeholderImage: UIImage(named: "img_profile_placeholder"))
                initialNameLabel.isHidden = false
                initialNameLabel.text = otherUser.fullName?.getInitial()
            }

            var betDescription: String
            if targetUser == currentUser {
                betDescription = "You" + " " + "claimed_win".localized()
            } else {
                betDescription = (targetUser.fullName ?? "") + " " + "claimed_win".localized()
            }
            lblBetDescription.text = betDescription
        case .disputed:
            guard let targetUser = bet.targetUser else { return }
            if let url = targetUser.thumbnail, url.count > 0 {
                imgUser?.sd_setImage(with: UploadManager.shared.getReference(for: url))
                initialNameLabel.isHidden = true
            } else {
                imgUser?.image = UIImage(named: "img_profile_placeholder")
                initialNameLabel.isHidden = false
                initialNameLabel.text = targetUser.fullName?.getInitial()
            }

            var betDescription: String
            if targetUser == currentUser {
                betDescription = "You" + " " + "denied \(otherUser.fullName ?? "BetIT user")'s claim"
            } else {
                betDescription = "\(targetUser.fullName ?? "BetIT user") denied your claim"
            }
            lblBetDescription?.text = betDescription
        case .endActionConfirmNeeded:
            guard let targetUser = bet.targetUser else { return }
            var betDescription: String
            // If current user is winner of this bet, set the bet description to show the other user lost
            // If other user is winner of this bet, set the bet description to show the other won
            if targetUser == currentUser {
                betDescription = "\(otherUser.fullName ?? "BetIT user") lost this bet"
            } else {
                betDescription = "\(otherUser.fullName ?? "BetIT user") won this bet"
            }

            lblBetDescription?.text = betDescription
        case .betLost, .betWon:
            // Regardless of betLost, betWon, the userID of the winner is set to targetUserID
            guard let targetUserID = bet.targetUserID else { return }
            if targetUserID == currentUserID {
                imgStatus?.image = UIImage(named: "img_gradient_vert_cyan")
            } else {
                imgStatus?.image = UIImage(named: "img_gradient_vert_navy")
            }
        default:
            break
        }
    }
    
    @IBAction func denyButtonPressed(_ sender: Any) {
        delegate?.betCell(self, didPressDenyButton: denyButton)
    }
    
    @IBAction func confirmButtonPressed(_ sender: Any) {
        delegate?.betCell(self, didPressConfirmButton: confirmButton)
    }
    
    @IBAction func settledButtonPressed(_ sender: Any) {
        delegate?.betCell(self, didPressSettledButton: settledButton)
    }
    
    @IBAction func acceptBetRequestButtonPressed(_ sender: Any) {
        delegate?.betCell(self, didPressAcceptBetRequestButton: acceptBetRequestButton)
    }
    
    @IBAction func declineBetRequestButtonPressed(_ sender: Any) {
        delegate?.betCell(self, didPressDeclineBetRequestButton: declineBetRequestButton)
    }
}
