//
//  BetListViewModel.swift
//  BetIT
//
//  Created by joseph on 9/4/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import Foundation

internal final class BetListViewModel {
    var currentCategory: BetCategory = .live
    var reloadData: (() -> Void)!
    var showError: ((Error) -> Void )!
    var bets: [BetStatus: [Bet]] = [:]
    var sortedSection: [BetStatus] = []
    
    init() {
        setup()
    }
    
    init(currentCategory: BetCategory) {
        setup()
        self.currentCategory = currentCategory
    }
    
    private func setup() {
        // Subscribe to notifications
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didDeleteBet(_:)),
                                               name: .DidDeleteBet,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didConfirmBet(_:)),
                                               name: .DidConfirmBet,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didUpdateBetStatus(_:)),
                                               name: .DidUpdateBetStatus,
                                               object: nil)
        
        // When the user receives push notifications from within the app
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceiveBet(_:)),
                                               name: .DidReceiveBet,
                                               object: nil)
    }
    
    func viewDidLoad() {
        // TODO: Instead of loading bets for each view model in HomeViewController children view controllers,
        // just call it once, and add it to the appropriate view model
        loadBets()
    }
    
    @objc private func didReceiveBet(_ notification: Notification) {
        guard let bet = notification.userInfo?["bet"] as? Bet else { return }
        processBet(bet)
    }
    
    private func loadBets() {
        DatabaseManager.shared.fetchBets { [weak self] (bets, error) in
            guard let strongSelf = self else { return }

            if let error = error {
                strongSelf.showError(error)
                return
            }
            guard let bets = bets else {
                let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Could not fetch bets"
                ])
                strongSelf.showError(error)
                return
            }
            
            for bet in bets {
                strongSelf.processBet(bet, shouldReloadData: false)
            }
            // strongSelf.bets = bets
            strongSelf.reloadData()
        }
    }
    
    func numberOfItems(in section: Int) -> Int {
        return bets[sortedSection[section]]?.count ?? 0
    }
    
    var numberOfSections: Int {
        return bets.count
    }
    
    func bet(at indexPath: IndexPath) -> Bet {
        return bets[sortedSection[indexPath.section]]![indexPath.row]
    }
    
    func addBet(_ bet: Bet) {
        processBet(bet)
    }
    
    func removeBet(_ bet: Bet) {
        for (section, sectionBets) in bets {
            var sectionBets = sectionBets
            sectionBets.removeAll(where: {$0 == bet })
            if sectionBets.count == 0 {
                bets.removeValue(forKey: section)
            } else {
                bets[section] = sectionBets
            }
        }

        sortedSection = bets.keys.sorted(by: {$0.rawValue < $1.rawValue})
        reloadData()
    }
    
    func updateBet(_ bet: Bet, completionHandler: (() -> Void)? = nil) {
        bet.updatedAt = Date()
        DatabaseManager.shared.updateBet(bet) { [weak self] error in
            guard let strongSelf = self else { return }
            strongSelf.processBet(bet)
            completionHandler?()
        }
    }
    
    func title(at section: Int) -> String {
        return sortedSection[section].section
    }
    
    func processBet(_ bet: Bet, shouldReloadData: Bool = true) {
        // [START process_bet]
        for (section, sectionBets) in bets {
            var sectionBets = sectionBets
            sectionBets.removeAll(where: {$0 == bet })
            if sectionBets.count == 0 {
                bets.removeValue(forKey: section)
            } else {
                bets[section] = sectionBets
            }
        }
        
        
        // Process bet if current user did not `delete` this bet
        if let betStatus = bet.status, betStatus.category == currentCategory, !bet.currentUserDidDelete() {
            // Bets with overdue deadlines don't get processed
            if let deadline = bet.deadline, deadline < Date() {
                // If it isn't marked expired yet
                if betStatus != .expired {
                    bet.status = .expired
                    DatabaseManager.shared.updateBet(bet)
                }
            }
            
            var sectionStatus = betStatus
            // For closed / settled bets, use the appropriate section title
            if currentCategory == .settled && betStatus != .declined && betStatus != .expired {
                guard let targetUser = bet.targetUser, let currentUser = AppManager.shared.currentUser else { return }
                if targetUser == currentUser {
                    sectionStatus = .betWon
                } else {
                    sectionStatus = .betLost
                }
            }
            
            var existingBets = bets[sectionStatus] ?? []
            guard existingBets.contains(bet) == false else { return }
            existingBets.append(bet)
            existingBets.sort { (bet1, bet2) -> Bool in
                // Sort by updated first
                if let updated1 = bet1.updatedAt, let updated2 = bet.updatedAt {
                    return updated1 > updated2
                }
                
                // If not updated, sort by deadline if there is any
                if let deadline1 = bet1.deadline, let deadline2 = bet2.deadline {
                    return deadline1 > deadline2
                }
                
                // Sort by date created if none of the above
                if let dateCreated1 = bet1.createdAt, let dateCreated2 = bet2.createdAt {
                    return dateCreated1 > dateCreated2
                }
                return false
            }
            bets[sectionStatus] = existingBets
        }
        
        // sortedSection = bets.keys.sorted {$0.rawValue < $1.rawValue}
        sortedSection = bets.keys.sorted { getOrderingValue($0) < getOrderingValue($1) }
            
        if shouldReloadData {
            reloadData()
        }
        // [END process_bet]
    }
    
    private func getOrderingValue(_ betStatus: BetStatus) -> Int {
        if currentCategory == .settled {
            switch betStatus {
            case .betWon:
                return 1
            case .betLost:
                return 2
            case .declined:
                return 3
            case .expired:
                return 4
            default:
                break
            }
        }
        
        if currentCategory == .unsettled {
            switch betStatus {
            case .opponentClaimedWin, .youClaimedWin:
                return 1
            case .disputed:
                return 2
            case .endActionConfirmNeeded:
                return 3
            default:
                break
            }
        }
        
        if currentCategory == .live {
            switch betStatus {
            case .live:
                return 1
            case .pendingBetActionNeeded:
                return 2
            default:
                break
            }
        }
        
        return betStatus.rawValue
    }
    
    @objc func didDeleteBet(_ notification: Notification) {
        guard let bet = notification.userInfo?["bet"] as? Bet else { return }
        removeBet(bet)
    }
    
    @objc func didConfirmBet(_ notification: Notification) {
        guard let bet = notification.userInfo?["bet"] as? Bet else { return }
        processBet(bet)
    }
    
    @objc func didUpdateBetStatus(_ notification: Notification) {
        guard let bet = notification.userInfo?["bet"] as? Bet else { return }
        processBet(bet)
    }
    
    private func getNotificationType(for bet: Bet ) -> BetNotificationType? {
        guard let currentUser = AppManager.shared.currentUser,
              let currentUserID = currentUser.userID else { return nil }

        guard let betStatus = bet.status else { return nil }
        
        var notificationType: BetNotificationType?
        switch betStatus {
        case .betWon, .betLost:
            // TODO: Remove betLost
            notificationType = .betWon
        case .opponentClaimedWin, .youClaimedWin:
            // TODO: Change this to claimedWin and remove opponentClaimedLost
            notificationType = .opponentClaimedWin
        case .declined:
            notificationType = .declined
        case .disputed:
            guard let targetUserID = bet.targetUserID else { return nil }
            // Only send the other user a notification if the user who disputed the bet was the current user
            if targetUserID == currentUserID {
                notificationType = .disputed
            }
        case .endActionConfirmNeeded:
            // Make sure target user is set
            guard bet.targetUserID != nil else { return nil }
            notificationType = .endActionConfirmNeeded
        default:
            break
        }
        return notificationType
    }
    
    func sendNotification(for bet: Bet, completionHandler: (() -> Void)? = nil) {
        guard let otherUser = bet.otherUser else { return }
        guard let currentUser = AppManager.shared.currentUser,
                let _ = currentUser.userID else { return }
        // guard let betStatus = bet.status else { return }
        guard let notificationType = getNotificationType(for: bet) else { return }
        

        let notification = NotificationManager.shared.createNotification(with: bet,
                                                                         type: notificationType,
                                                                         sender: currentUser,
                                                                         recipient: otherUser)
        
        DatabaseManager.shared.addNotification(notification) { [weak self] (betNotification, error) in
            guard let strongSelf = self else { return }
            if let error = error {
                strongSelf.showError(error)
                return
            }
            guard let betNotification = betNotification else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Could not send notification"]
                )
                strongSelf.showError(error)
                return
            }
            
            /*
            // [START notification_settings]
            otherUser.getNotificationSettings() { settings in
                guard let settings = settings else { return }

                // If this is a bet request and other user explicitly specified that they do not want bet request notifications then don't send
                if betStatus == .pendingBetActionNeeded && !settings.isRequests {
                    return
                }
                
                if (betStatus == .youClaimedWin || betStatus == .opponentClaimedWin) && !settings.isClaimed {
                    return
                }
                
                if betStatus == .disputed && !settings.isDisputed {
                    return
                }
                
                NotificationManager.shared.sendNotification(betNotification)
            }
    
            // [END notification_settings]
            */
            NotificationManager.shared.sendNotification(betNotification)

        }
    }
    
    func isEmpty() -> Bool {
        for (_, sectionBets) in bets  {
            if sectionBets.count > 0 {
                return false
            }
        }
        return true
    }
}
