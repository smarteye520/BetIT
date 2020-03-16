//
//  NotificationsViewModel.swift
//  BetIT
//
//  Created by joseph on 8/30/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import Foundation

internal final class NotificationsViewModel {
    private var notifications = [BetNotification]()
    
    var reloadData: (() -> Void)?
    var didReceiveNotification: (() -> Void)?
    var showError: ((Error?) -> Void)?
    
    init() {
        setup()
    }
    
    init(notifications: [BetNotification]) {
        self.notifications = notifications
    }
    
    private func setup() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(incomingBet(_:)),
                                               name: .IncomingBetNotification,
                                               object: nil)
    }
    
    @objc private func incomingBet(_ notification: Notification) {
        guard let betNotification = notification.userInfo?["notification"] as? BetNotification else { return }
        DispatchQueue.main.async {
            self.didReceiveNotification?()
        }
        processNotification(betNotification)
    }
    
    @objc private func didDeleteBet(_ notification: Notification) {
        guard let bet = notification.userInfo?["bet"] as? Bet else { return }
        deleteNotifications(for: bet)
    }
    
    func deleteNotifications(for bet: Bet) {
        guard let betID = bet.betID else { return }
        
        let deleteBetNotifications = notifications.filter { (betNotification) -> Bool in
            guard let notificationBetID = betNotification.betID ?? betNotification.bet?.betID else { return false }
            return notificationBetID == betID
        }

        for betNotificationToDelete in deleteBetNotifications {
            notifications.removeAll(where: {$0 == betNotificationToDelete})
            DatabaseManager.shared.deleteNotification(betNotificationToDelete)
        }
    

        NotificationCenter.default.post(name: .DidDeleteBet, object: nil, userInfo: ["bet": bet])

        reloadData?()
    }
    
    private func processNotification(_ notification: BetNotification) {
        guard notifications.contains(where: {$0 == notification}) == false else { return }
        notifications.insert(notification, at: 0)
        notifications.sort { (notification1, notification2) -> Bool in
            guard let date1 = notification1.time, let date2 = notification2.time else { return false }
            return date1 > date2
        }
        reloadData?()
    }
    
    func viewDidLoad() {
        guard notifications.isEmpty else {
            reloadData?()
            return
        }
        loadData()
    }
    
    private func loadData() {
        DatabaseManager.shared.fetchNotifications { [weak self] (notifications, error) in
            guard let strongSelf = self else { return }
            if let error = error {
                strongSelf.showError?(error)
                return
            }
            guard let notifications = notifications else {
                let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Could not fetch notifications"
                ])
                strongSelf.showError?(error)
                return
            }
            // TODO: Paginate this
            
            for notification in notifications {
                guard strongSelf.notifications.contains(where: {$0 == notification}) == false else { continue }
                strongSelf.notifications.append(notification)
            }
            
            // strongSelf.notifications = notifications
            strongSelf.notifications.sort { (notification1, notification2) -> Bool in
                guard let date1 = notification1.time, let date2 = notification2.time else { return false }
                return date1 > date2
            }
            strongSelf.reloadData?()
        }
    }
    
    var hasNewNotifications: Bool {
        // return notifications.filter({ $0.isNew ?? false }).count > 0
        for notification in notifications {
            if notification.isNew ?? false {
                return true
            }
        }
        return false
    }
    
    func markNotificationsAsRead() {
        for notification in notifications {
            let isNew = notification.isNew ?? false
            if isNew {
                notification.isNew = false
                DatabaseManager.shared.updateNotificationRead(notification)
            }
        }
    }
    
    var numberOfItems: Int {
        return notifications.count
    }
    
    var numberOfSections: Int {
        return 1
    }
    
    func notification(at index: Int) -> BetNotification? {
        guard index >= 0 else { return nil }
        return notifications[index]
    }
    
    func isEmpty() -> Bool {
        return notifications.isEmpty
    }
    
    func copy(with: NSZone? = nil) -> Any {
        return NotificationsViewModel(notifications: notifications)
    }
}
