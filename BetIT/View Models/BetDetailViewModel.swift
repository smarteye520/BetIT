//
//  BetDetailViewModel.swift
//  BetIT
//
//  Created by joseph on 10/30/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import Foundation
import UIKit

internal final class BetDetailViewModel: BetViewModel {
    enum Mode {
        case normal, editing
    }
    
    private(set) var canEditBet = false
    var enableBetEditing: (() -> Void)?
    var disableBetEditing: (() -> Void)?
    var onDelete: (() -> Void)?
    var mode: Mode = .normal
    
    override var deadlineText: String? {
        if let deadline = deadlineDate {
            return deadline.string(withFormat: Constant.Format.betTime)
        }
        return super.deadlineText
    }
    
    override var betTimeRemaining: String? {
        if let deadline = deadlineDate {
            return formatBetTimeRemaining(deadline)
        }
        return super.betTimeRemaining
    }
    
    var shouldBeginEditing: Bool {
        return self.canEditBet && self.mode == .editing
    }
    
    func viewDidLoad() {
        reloadData?()
        
        disableBetEditing?()
        
        guard let currentUserID = AppManager.shared.currentUser?.userID, let ownerID = bet.ownerID else { return  }
        
        if currentUserID == ownerID, let betStatus = bet.status, betStatus == .pendingBetActionNeeded {
            canEditBet = true
            enableBetEditing?()
        }
    }

    func deleteBet() {
        DatabaseManager.shared.deleteBet(bet) { [weak self] (error) in
            guard let strongSelf = self else { return }
            NotificationCenter.default.post(name: .DidDeleteBet, object: nil, userInfo: ["bet": strongSelf.bet])
            strongSelf.onDelete?()
        }
    }
    
    func updateBet(title: String? = nil, description: String? = nil, wager: String? = nil, updatedAt: Date = Date(), completion: ((Bet?, Error?) -> Void)? = nil) {
        
        if let title = title?.trimmingCharacters(in: .whitespacesAndNewlines) {
            guard isValidTitle(title) else { return }
            bet.title = title
        }
        
        if let description = description?.trimmingCharacters(in: .whitespacesAndNewlines) {
            bet.description = description
        }
        
        if let wager = wager?.trimmingCharacters(in: .whitespacesAndNewlines) {
            bet.wager = wager
        }
        
        if let deadline = deadlineDate {
            bet.deadline = deadline
        }
        
        bet.updatedAt = updatedAt

        DatabaseManager.shared.updateBet(bet) { [weak self] error in
            if let error = error {
                completion?(nil, error)
                return
            }
            DispatchQueue.main.async {
                completion?(self?.bet, nil)
            }
        }
    }
}
