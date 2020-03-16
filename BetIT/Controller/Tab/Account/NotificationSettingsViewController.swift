//
//  NotificationSettingsViewController.swift
//  BetIT
//
//  Created by OSX on 7/31/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import UIKit

class NotificationSettingsViewController: BaseViewController {

    @IBOutlet weak var remindersToggle: UISwitch!
    @IBOutlet weak var betRequestsToggle: UISwitch!
    @IBOutlet weak var claimedBetsToggle: UISwitch!
    @IBOutlet weak var disputedBetsToggle: UISwitch!
    @IBOutlet weak var emailToggle: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        guard AppManager.shared.currentUser != nil else {
            showAlert("Not logged in")
            return
        }
        
        loadCurrentUserNotificationSettings()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }

    @IBAction func onToggle(_ sender: Any) {
        
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        // Update changes
        guard let currentUser = AppManager.shared.currentUser else { return }
        currentUser.getNotificationSettings { [weak self] (notificationSettings) in
            guard let strongSelf = self else { return }
            guard let notificationSettings = notificationSettings else {
                strongSelf.showAlert("Could not save notification settings")
                return
            }
            notificationSettings.occasionalReminders = strongSelf.remindersToggle.isOn
            notificationSettings.requests = strongSelf.betRequestsToggle.isOn
            notificationSettings.claimed = strongSelf.claimedBetsToggle.isOn
            notificationSettings.disputed = strongSelf.disputedBetsToggle.isOn
            notificationSettings.email = strongSelf.emailToggle.isOn
            currentUser.updateNotificationSettings(notificationSettings) { [weak self] error in
                guard let strongSelf = self else { return }
                if let error = error {
                    strongSelf.showAlert(error.localizedDescription)
                    return
                }
                strongSelf.showSavedAnimation()
                
            }
        }
    }
    
    private func loadCurrentUserNotificationSettings() {
        guard let currentUser = AppManager.shared.currentUser else { return }
        currentUser.getNotificationSettings { [weak self] (notificationSettings) in
            guard let strongSelf = self else { return }
            guard let notificationSettings = notificationSettings else {
                strongSelf.showAlert("Could not load notification settings")
                return
            }
            strongSelf.updateUI(notificationSettings)
        }
    }
    
    private func updateUI(_ notificationSettings: NotificationSettings) {
        remindersToggle.isOn = notificationSettings.isOccasionalReminders
        betRequestsToggle.isOn = notificationSettings.isRequests
        claimedBetsToggle.isOn = notificationSettings.isClaimed
        disputedBetsToggle.isOn = notificationSettings.isDisputed
        emailToggle.isOn = notificationSettings.isEmail
    }
    
    private func showSavedAnimation() {
         let origin = CGPoint(x: (self.view.frame.width - CustomSaveView.defaultSize.width) / 2.0, y: 120)
         let savedViewFrame = CGRect(origin: origin, size: CustomSaveView.defaultSize)
         
         let savedView = CustomSaveView(frame: savedViewFrame)
         savedView.center = self.view.center
         savedView.delegate = self
         self.view.addSubview(savedView)
         savedView.startAnimation()
     }
}

extension NotificationSettingsViewController: CustomSaveViewDelegate {
    func customSaveViewAnimationDidStop(_ customSaveView: CustomSaveView) {
        self.navigationController?.popViewController(animated: true)
    }
}
