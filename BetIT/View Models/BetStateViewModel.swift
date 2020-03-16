//
//  BetStateViewModel.swift
//  BetIT
//
//  Created by joseph on 10/30/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import Foundation
import UIKit

typealias AlertData = (title: String, message: String, buttons: [String], completion: (Int) -> Void)

protocol BetStateViewModelInputs: AnyObject {
    var canDeleteBet: Bool { get }
    var shouldRefreshBet: Bool { get set }

    func viewDidLoad()
    func refreshBet()
    func deleteBet()
    
    func currentUserDeclined()
    func currentUserDisputed()
    func currentUserConceded()
    func currentUserAccepted()
    func currentUserClaimedWin()
    func currentUserDidSettle()
    func currentUserConfirmedOpponentWon()
    
    func onDo()
    func onCancel()
    func onGreen()  // TODO: Change the name of this
    func onBlack()  // TODO: Change the name of this
    func onDelete()
}

protocol BetStateViewModelOutputs: AnyObject {
    var didAccept: ((Error?) -> Void) { get set }
    var didDelete: ((Error?) -> Void) { get set }
    var didUpdate: ((Error?) -> Void) { get set }
    var didRefresh: ((Error?) -> Void) { get set }
    var showCustomAlert: ((AlertData) -> Void) { get set }
}

protocol BetStateViewModelType {
    var inputs: BetStateViewModelInputs { get }
    var outputs: BetStateViewModelOutputs { get }
}

final class BetStateViewModel: BetViewModel, BetStateViewModelInputs, BetStateViewModelOutputs, BetStateViewModelType {
        
    var shouldHideDeadline: Bool {
        // Show deadline if deadline available and only for bet requests or expired bets
        if hasDeadline, statusIs([.pendingBetActionNeeded, .expired]) {
            return false
        } else {
            return true
        }
    }
    
    var betSentAttributedText: NSAttributedString? {
        // Joe sent this bet at 11:15 am 10/15/19
        guard
            let ownerName = bet.currentUserIsOwner() ? "You" : bet.owner?.fullName,
            let createdAt = bet.createdAt
        else { return nil }

        let result = NSMutableAttributedString(string: "\(ownerName) sent this bet at ")
    
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.dateFormat = "hh:mm a MM/dd/yy"
        
        let dateString = dateFormatter.string(from: createdAt)
        
        let attributedDateString = NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        result.append(attributedDateString)
        return result
    }
    
    override var usernameText: String? {
        return bet.otherUser?.fullName
    }

    override var betStatus: BetStatus? {
        guard var status = bet.status else { return nil }
        if status == .betLost || status == .betWon {
            if let currentUserID = AppManager.shared.currentUser?.userID,
                let targetUserID = bet.targetUserID {
                // Current bet status is win / lost, target user is current user which means current user won
                if targetUserID == currentUserID {
                    status = .betWon
                } else {
                    status = .betLost
                }
            }
        }
        return status
    }
            
    func getBet() -> Bet {
        return self.bet
    }
    
    // MARK: - BetStateViewModelInputs

    var shouldRefreshBet: Bool = false

    var canDeleteBet: Bool {
        guard let status = bet.status else { return false }
        let allowedDeleteOptions: [BetStatus] = [.expired, .betWon, .betLost, .declined]
        return allowedDeleteOptions.contains(status)
    }

    func viewDidLoad() {
        if shouldRefreshBet {
            refreshBet()
        } else {
            reloadData?()
        }
    }
    
    func refreshBet() {
        guard let betID = bet.betID else { return }
        
        DatabaseManager.shared.getBet(betID) { [weak self] (bet, error) in
            guard let `self` = self else { return }
            if let error = error as NSError? {
                self.didRefresh(error)
                return
            }
            
            guard let bet = bet else {
                self.didRefresh(NSError(domain: "AppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not fetch bet"]))
                return
            }
            self.bet = bet
            self.didRefresh(nil)
        }
    }
    
    func deleteBet() {
        bet.currentUserSetDelete()
        DatabaseManager.shared.updateBet(bet) { [weak self] (error) in
            guard let `self` = self else { return }
            if let error = error {
                print("Could not delete bet. Error: \(error.localizedDescription)")
                // self.showError("Could not delete bet")
                self.didDelete(error)
                return
            }
            NotificationCenter.default.post(name: .DidDeleteBet,
                                            object: nil,
                                            userInfo: ["bet": self.bet])
            self.didDelete(nil)
            // self?.navigationController?.popViewController(animated: true)
        }
    }

    func updateBet(status: BetStatus, completion: (() -> Void)? = nil) {
        if let betStatus = bet.status, betStatus == .pendingBetActionNeeded {
            guard let currentUser = AppManager.shared.currentUser else { return }
            
            let isInvite = bet.isInvite ?? false
            // If bet was sent from invitation, then ownerID cannot be the current user
            // Update the opponent, opponentID to the current user for this bet since the opponent and opponentID were set to temporary values when the other user invited the current user
            if isInvite, let owner = bet.owner, owner != currentUser {
                bet.opponent = currentUser
                bet.opponentID = currentUser.userID
                bet.isInvite = false
            }
        }
        
        if bet.isInvite ?? false, let status = bet.status, status == .pendingBetActionNeeded {
            // Do somehting if user is a native app user and not an invitee
        }

        bet.status = status
        bet.updatedAt = Date()
        
        DatabaseManager.shared.updateBet(bet) { [weak self] (error) in
            guard let `self` = self else { return }
            if let error = error {
                // self.showError(error.localizedDescription)
                self.didUpdate(error)
                return
            }

            // Post notification that the bet status was updated to any subscribers
            NotificationCenter.default.post(name: .DidUpdateBetStatus,
                                            object: nil,
                                            userInfo: ["bet": self.bet])

            self.sendNotification()
            self.didUpdate(nil)
            completion?()
        }
    }
    
    func currentUserDeclined() {
        guard statusIs(.pendingBetActionNeeded) else { return }
        setTargetUserID(isOtherUser: false)
        updateBet(status: .declined)
    }
    
    func currentUserClaimedWin() {
        guard statusIs([.live, .disputed]) else { return }
        setTargetUserID(isOtherUser: false)
        // doesn't matter if its .youClaimedWin or .opponentClaimedWin
        // as long as targetUserID is set
        updateBet(status: .opponentClaimedWin)
    }

    func currentUserDisputed() {
        guard statusIs([.opponentClaimedWin, .youClaimedWin]) else { return }
        setTargetUserID(isOtherUser: false)
        updateBet(status: .disputed)
    }
    
    func currentUserConceded() {
        // Maybe show error?
        guard statusIs([.live, .disputed]) else { return }
        setTargetUserID(isOtherUser: true)
        updateBet(status: .endActionConfirmNeeded)
    }
    
    func currentUserAccepted() {
        guard statusIs(.pendingBetActionNeeded) else { return }
        updateBet(status: .live) { [weak self] in
            self?.didAccept(nil)
        }
    }
    
    func currentUserDidSettle() {        
        guard
            statusIs(.endActionConfirmNeeded),
            bet.currentUserIsTarget
        else { return }
        updateBet(status: .betWon)
    }
    
    func currentUserConfirmedOpponentWon() {
        guard
            statusIs([.opponentClaimedWin, .youClaimedWin]),
            bet.targetUser == bet.otherUser
            // bet.otherUserIsTarget
        else { return }
        setTargetUserID(isOtherUser: true)
        updateBet(status: .endActionConfirmNeeded)
    }
    
    func onDo() {
        guard statusIs([.pendingBetActionNeeded, .opponentClaimedWin, .youClaimedWin]) else { return }
        if statusIs(.pendingBetActionNeeded) {
            self.inputs.currentUserAccepted()
        } else {
            self.inputs.currentUserConfirmedOpponentWon()
        }
    }
    
    func onCancel() {
        guard statusIs([.pendingBetActionNeeded, .opponentClaimedWin, .youClaimedWin]) else { return }
        if statusIs(.pendingBetActionNeeded) {
            let alertData = AlertData(title: "decline_bet".localized(),
                                      message: "winner_confirm_description".localized(),
                                      buttons: ["cancel".localized(), "decline".localized()],
                                      completion: { [weak self] index in
                                          guard index == 1 else { return }
                                          self?.inputs.currentUserDeclined()
                                      })
            self.outputs.showCustomAlert(alertData)
        } else {
            self.inputs.currentUserDisputed()
        }
    }
    
    func onGreen() {
        guard statusIs([.live, .disputed]) else { return }
        let alertData = AlertData(title: "winner".localized(),
                                  message: "winner_confirm_description".localized(),
                                  buttons: ["cancel".localized(), "yes".localized()],
                                  completion: { [weak self] (index) in
                                      guard index == 1 else { return }
                                      self?.inputs.currentUserClaimedWin()
                                  })
        self.outputs.showCustomAlert(alertData)
    }
    
    func onBlack() {
        guard statusIs([.live, .disputed]) else { return }
        let alertData = AlertData(title: "womp_womp".localized(),
                                  message: "loser_confirm_description".localized(),
                                  buttons: ["cancel".localized(), "yes".localized()],
                                  completion: { [weak self] (index) in
                                      guard index == 1 else { return }
                                      self?.inputs.currentUserConceded()
                                  })
        self.outputs.showCustomAlert(alertData)
    }
    
    func onDelete() {
        // Only delete if bet status is expired, won, lost, declined
        guard canDeleteBet else { return }
        let alertData = AlertData(title: "Delete Bet",
                                  message: "Are you sure you want to delete this bet?",
                                  buttons: ["cancel".localized(), "yes".localized()],
                                  completion: { [weak self] (index) in
                                      guard index == 1 else { return }
                                      self?.inputs.deleteBet()
                                  })
        self.outputs.showCustomAlert(alertData)

    }
    
    // MARK: - BetStateViewModelOutputs
    
    var didAccept: (Error?) -> Void = { _ in }
    var didDelete: (Error?) -> Void = { _ in }
    var didUpdate: (Error?) -> Void = { _ in }
    var didRefresh: (Error?) -> Void = { _ in }
    var showCustomAlert: (AlertData) -> Void = { _ in }
    
    // MARK: - BetStateViewModelType
    
    var inputs: BetStateViewModelInputs { return self }
    var outputs: BetStateViewModelOutputs { return self }

    // MARK: - Helpers
    
    func statusIs(_ status: BetStatus) -> Bool {
        guard let betStatus = self.betStatus else { return false }
        return status == betStatus
    }
    
    func statusIs(_ allowedBetStatusOptions: [BetStatus]) -> Bool {
        guard let status = betStatus else { return false }
        return allowedBetStatusOptions.contains(status)
    }

    private func sendNotification() {
        guard
            let betStatus = bet.status,
            let currentUser = AppManager.shared.currentUser,
            let currentUserID = currentUser.userID,
            let otherUser = bet.otherUser,
            otherUser.userID != nil
        else { return }

        guard let notification = buildNotification() else { return }
        
        DatabaseManager.shared.addNotification(notification) { (notification, error) in
            guard error == nil else { return }
            guard let notification = notification else { return }
            
            otherUser.getNotificationSettings() { settings in
                guard let settings = settings else { return }
                
                if betStatus == .pendingBetActionNeeded && !settings.isRequests {
                    return
                }
                
                if (betStatus == .youClaimedWin || betStatus == .opponentClaimedWin) && !settings.isClaimed {
                    return
                }
                
                if betStatus == .disputed && !settings.isDisputed {
                    return
                }
                
                NotificationManager.shared.sendNotification(notification)
            }
        }

    }
    
    private func buildNotification() -> BetNotification? {
        guard
            let betStatus = bet.status,
            let currentUser = AppManager.shared.currentUser,
            let currentUserID = currentUser.userID,
            let otherUser = bet.otherUser,
            otherUser.userID != nil
        else { return nil }
        
        // Create and send push notification
        
        var notification: BetNotification?
        switch betStatus {
        case .declined:
            notification = NotificationManager.shared.createNotification(with: bet,
                                                                         type: .declined,
                                                                         sender: currentUser,
                                                                         recipient: otherUser)
        case .live:
            notification = NotificationManager.shared.createNotification(with: bet,
                                                                         type: .accepted,
                                                                         sender: currentUser,
                                                                         recipient: otherUser)
        case .youClaimedWin, .opponentClaimedWin:
            guard let targetUserID = bet.targetUserID else { return nil }
            let notificationType: BetNotificationType = (targetUserID == currentUserID) ? .opponentClaimedWin : .opponentClaimedLost
            notification = NotificationManager.shared.createNotification(with: bet,
                                                                         type: notificationType,
                                                                         sender: currentUser,
                                                                         recipient: otherUser)
        case .disputed:
            notification = NotificationManager.shared.createNotification(with: bet, type: .disputed, sender: currentUser, recipient: otherUser)
        case .betWon, .betLost:
            guard let targetUserID = bet.targetUserID else { return nil }
            var notificationType: BetNotificationType
            if targetUserID == currentUserID {
                // Since the current user won, send the other user the notification that the current user won
                notificationType = .betWon
            } else {
                notificationType = .betLost
            }
            notification = NotificationManager.shared.createNotification(with: bet, type: notificationType, sender: currentUser, recipient: otherUser)
        case .endActionConfirmNeeded:
            notification = NotificationManager.shared.createNotification(with: bet, type: .endActionConfirmNeeded, sender: currentUser, recipient: otherUser)
        default:
            break
        }

        return notification
    }
}
