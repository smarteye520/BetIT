//
//  InviteFriendsViewController.swift
//  BetIT
//
//  Created by OSX on 7/31/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import UIKit
import MessageUI
import Branch
import ContactsUI

class InviteFriendsViewController: BaseViewController {
    
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var userLink: UIButton!
    @IBOutlet weak var sendInviteButton: UIButton!
    
    var url: String?
    var phoneNumber: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    @IBAction func shareLinkButtonPressed(_ sender: Any) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = userLink.titleLabel?.text
        
        let alert = UIAlertController(title: "Link copied", message: "", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        
        let when = DispatchTime.now() + 0.75
        DispatchQueue.main.asyncAfter(deadline: when) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func sendInviteButtonPressed(_ sender: Any) {
        guard let url = url else { return }
        showMessageUI(message: "Click here to join BetIT \(String(describing: url))")
    }
    
    @IBAction func searchFieldButtonPressed(_ sender: Any) {
        guard let addOpponentVC = UIManager.loadViewController(storyboard: "Bet", controller: "AddOpponentViewController") as? AddOpponentViewController else {
            return
        }
        
        addOpponentVC.isContactsOnly = true
        addOpponentVC.mode = .inviteFriends
        
        addOpponentVC.modalPresentationStyle = .overCurrentContext
        addOpponentVC.modalTransitionStyle = .crossDissolve
        
        self.present(addOpponentVC, animated: true, completion: nil)
        
    }
    
    private func setup() {
        sendInviteButton.isEnabled = false

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didSelectUser(_:)),
                                               name: .DidSelectUser,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didSelectPhoneNumber(_:)),
                                               name: .DidSelectPhoneNumber,
                                               object: nil)
        
        guard let currentUser = AppManager.shared.currentUser else { return }
        currentUser.getUserReferral { [weak self] (userReferral) in
            guard let userReferral = userReferral else { return }
            guard let strongSelf = self else { return }
            strongSelf.url = userReferral.referralLink
            strongSelf.sendInviteButton.isEnabled = userReferral.referralLink != nil
            strongSelf.userLink.setTitle(userReferral.referralLink ?? "N/A", for: .normal)
        }
    }
    
    
    private func showMessageUI(message: String) {
        guard MFMessageComposeViewController.canSendText() else { return }
        guard let phoneNumber = phoneNumber else { return }
        
        let controller = MFMessageComposeViewController()
        controller.body = message
        controller.recipients = [phoneNumber]
        controller.messageComposeDelegate = self
        self.present(controller, animated: true, completion: nil)
    }
    
    @objc func didSelectPhoneNumber(_ notification: Notification) {
        guard let phoneNumber = notification.userInfo?["phoneNumber"] as? String else { return }
        guard AppManager.shared.currentUser != nil else { return }
        self.phoneNumber = phoneNumber
        searchField.text = phoneNumber

    }
    
    @objc func didSelectUser(_ notification: Notification) {
        guard let user = notification.userInfo?["user"] else { return }
        guard AppManager.shared.currentUser != nil else { return }
    
        if let contact = user as? CNContact {
            // TODO: Get the opponent from contact
            searchField.text = "\(contact.givenName) \(contact.familyName)"
            if let phoneNumber = contact.phoneNumbers.first?.value.stringValue.formattedNumber() {
                self.phoneNumber = phoneNumber
            }
        }
        sendInviteButton.isEnabled = true
    }
}

// MARK: - MFMessageComposeViewControllerDelegate

extension InviteFriendsViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        dismiss(animated: true)
    }
}
