//
//  ConfirmBetViewModel.swift
//  BetIT
//
//  Created by joseph on 11/4/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import Foundation
import UIKit
import Branch

internal final class ConfirmBetViewModel: BetViewModel {
    
    var didAddBet: ((Bet) -> Void)?
    var didDeleteBet: ((Bet) -> Void)?
    var didCreateShortURL: ((String) -> Void)?
    var didSendNotification: ((BetNotification) -> Void)?
    var showError: ((String) -> Void)?
    
    var canCreateBet: Bool {
        if let ownerID = bet.ownerID, let opponentID = bet.opponentID, opponentID != ownerID {
            return true
        }
        return false
    }
    
    var hasPhoneNumber: Bool {
        return bet.opponent?.phoneNumber != nil
    }
    
    var phoneNumber: String? {
        return bet.opponent?.phoneNumber
    }
    
    var opponentName: String {
        return bet.opponent?.fullName ?? "BetIT User"
    }
    
    func addBet() {
        guard canCreateBet else {
            showError?("Could not create bet")
            return
        }
        
        if isInvitingBet {
            guard hasPhoneNumber else {
                showError?("No phone number for \(opponentName)")
                return
            }
        }
        
        DatabaseManager.shared.addBet(bet) { [weak self] (bet, error) in
            guard let strongSelf = self else { return }
            if let error = error {
                strongSelf.showError?(error.localizedDescription)
                return
            }
            guard let bet = bet else {
                strongSelf.showError?("Could not create bet")
                return
            }
            
            NotificationCenter.default.post(name: .DidConfirmBet,
                                            object: nil,
                                            userInfo: ["bet": bet])

            if strongSelf.isInvitingBet {
                guard strongSelf.hasPhoneNumber else {
                    strongSelf.showError?("No phone number for \(strongSelf.opponentName)")
                    return
                }
                strongSelf.createShortURL()
            } else {
                strongSelf.sendNotification()
            }

            strongSelf.didAddBet?(bet)
        }
    }
    
    func deleteBet() {
        DatabaseManager.shared.deleteBet(bet) { [weak self] (error) in
            guard let strongSelf = self else { return }
            NotificationCenter.default.post(name: .DidDeleteBet,
                                            object: nil,
                                            userInfo: ["bet": strongSelf.bet])
            self?.didDeleteBet?(strongSelf.bet)
        }
    }
    
    
    func createShortURL() {
        DeepLinkManager.shared.createShortURL(with: bet) { [weak self] (url, error) in
            guard let strongSelf = self else { return }
            if let error = error {
                strongSelf.showError?(error.localizedDescription)
                return
            }

            guard let url = url else {
                strongSelf.showError?("Could not create bet url")
                return
            }
            
            strongSelf.didCreateShortURL?(url)
        }

    }
    
    func sendNotification() {
        
        
        let notification = NotificationManager.shared.createNotification(with: bet, type: .challengeRequested)
        
        DatabaseManager.shared.addNotification(notification) { [weak self] (notification, error) in
            guard let strongSelf = self else { return }
            if let error = error {
                strongSelf.showError?(error.localizedDescription)
                return
            }
            guard let notification = notification else {
                strongSelf.showError?("Could not create notification")
                return
            }
            
            NotificationManager.shared.sendNotification(notification)
            strongSelf.didSendNotification?(notification)
        }
    }
}
