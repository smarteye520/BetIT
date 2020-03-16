//
//  CreateBetViewModel.swift
//  BetIT
//
//  Created by joseph on 10/30/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import Foundation
import ContactsUI

internal final class CreateBetViewModel: BetViewModel {
    
    private(set) var phoneNumber: String?
    private(set) var opponent: User?
    private(set) var contact: CNContact?
    
    var didSelectPhoneNumber: (() -> Void)?
    var didSelectUser: (() -> Void)?
    var didSelectContact: (() -> Void)?
    var didSelectDeadline: (() -> Void)?
    
    override var deadlineText: String? {
        if let deadline = deadlineDate {
            return deadline.string(withFormat: Constant.Format.betTime)
        }
        return super.deadlineText
    }

    var hasOpponent: Bool {
        return opponent != nil
    }
    
    var hasPhoneNumber: Bool {
        return phoneNumber != nil
    }
    
    var hasContact: Bool {
        return contact != nil
    }
    
    var contactName: String? {
        guard let contact = contact else { return "No contact name" }
        return "\(contact.givenName) \(contact.familyName)"
    }
    
    func viewDidLoad() {
        observeNotifications()
    }

    
    private func observeNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didSelectUser(_:)),
                                               name: .DidSelectUser,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didSelectPhoneNumber(_:)),
                                               name: .DidSelectPhoneNumber,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didSetDeadline(_:)),
                                               name: .DidSetDeadline,
                                               object: nil)

    }
    
    @objc func didSelectPhoneNumber(_ notification: Notification) {
        guard let phoneNumber = notification.userInfo?["phoneNumber"] as? String else { return }

        // TODO: Add phoneNumber.isValidPhoneNumber()
        guard phoneNumber.count > 0 else { return }
        self.phoneNumber = phoneNumber
                
        // DEBUG:
        self.contact = nil
        self.opponent = nil
        
        didSelectPhoneNumber?()
    }
    
    @objc func didSelectUser(_ notification: Notification) {
        guard let user = notification.userInfo?["user"] else { return }
        guard let currentUser = AppManager.shared.currentUser else { return }

        if let user = user as? User {
            guard opponent != currentUser else { return }
            opponent = user
            self.phoneNumber = nil
            self.contact = nil
            didSelectUser?()
        } else if let contact = user as? CNContact {
            self.opponent = nil
            self.contact = contact
            self.phoneNumber = contact.phoneNumbers.first?.value.stringValue.formattedNumber()
            didSelectContact?()
        }
    }

    @objc func didSetDeadline(_ notification: Notification) {
        print("didSetDeadlines is called")
        guard let deadline = notification.userInfo?["deadline"] as? Date else { return }
        // setDeadline(deadline)
        deadlineDate = deadline
        didSelectDeadline?()
    }
    
    func build(title: String? = nil, wager: String? = nil, description: String? = nil, inviteeUserName: String?) -> Bet? {
        if let title = title?.trimmingCharacters(in: .whitespacesAndNewlines) {
            bet.title = title
        }
        
        if let wager = wager?.trimmingCharacters(in: .whitespacesAndNewlines) {
            bet.wager = wager
        }

        if let description = description?.trimmingCharacters(in: .whitespacesAndNewlines) {
            bet.description = description
        }
        
        if let deadline = deadlineDate {
            bet.deadline = deadline
        }
        
        bet.status = .pendingBetActionNeeded
        
        if let opponent = opponent {
            bet.opponent = opponent
            bet.opponentID = opponent.userID
        } else {
            // If no opponent, then the opponent (invitee's) phone number must be available
            guard self.hasPhoneNumber else { return nil }
            bet.isInvite = true
            let invitee = createInviteeUser(withGivenName: inviteeUserName)
            bet.opponent = invitee
            bet.opponentID = invitee.userID
        }
        
        bet.owner = AppManager.shared.currentUser
        bet.ownerID = AppManager.shared.currentUser?.userID
        bet.createdAt = Date()
        
        return bet
    }
    
    private func createInviteeUser(withGivenName inviteeUserName: String?) -> User {
        let invitee = User()
        // Use random uuid has userID, will get updated once they sign up for app
        invitee.userID = UUID().uuidString
        invitee.createdAt = Date()
        invitee.fullName = inviteeUserName?.trimmingCharacters(in: .whitespacesAndNewlines)
        invitee.phoneNumber = self.phoneNumber
        return invitee
    }
}

