//
//  AccountViewController.swift
//  BetIT
//
//  Created by OSX on 7/31/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import UIKit
import MessageUI
import SafariServices

typealias AccountItem = (title: String, segue: String?)

class AccountViewController: BaseViewController {
    @IBOutlet weak var tblAccount: UITableView!
    var accountItems: [AccountItem] = []

    override func configureUI() {
        super.configureUI()
        
        AccountCell.registerWithNib(to: tblAccount)
        accountItems = [
            (title: "edit_profile".localized(), segue: "sid_edit_profile"),
            (title: "notification_settings".localized(), segue: "sid_notification_settings"),
            (title: "invite_friends".localized(), segue: "sid_invite_friends"),
            (title: "support_faq".localized(), segue: nil),
            (title: "terms_conditions".localized(), segue: nil),
            (title: "privacy_policy".localized(), segue: nil),
            (title: "logout".localized(), segue: nil)
        ]
        tblAccount.reloadData()
    }
    
    func showLogOutPrompt() {
        let alertController = UIAlertController(title: "Are you sure?", message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let logOutAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            self.logOut()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(logOutAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func logOut() {
        AuthManager.shared.signOut { [weak self] (error) in
            if let error = error {
                self?.showAlert(error.localizedDescription)
                return
            }
            AppManager.shared.logoutUser()
            UIManager.showLogin(animated: true)
            DeepLinkManager.shared.untrackUser()
        }
    }
}


extension AccountViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accountItems.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AccountCell.height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AccountCell.identifier) as! AccountCell
        cell.reset(with: accountItems[indexPath.row].title)
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sid_edit_profile" {
            guard let editProfileVC = segue.destination as? EditProfileViewController else { return }
            guard let currentUser = AppManager.shared.currentUser else { return }
            editProfileVC.viewModel = EditProfileViewModel(user: currentUser)
        }
    }
}

extension AccountViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = accountItems[indexPath.row]
        if let sid = item.segue {
            self.performSegue(withIdentifier: sid, sender: self)
        }
        else {
            if item.title == "support_faq".localized() {
                presentMailViewController()
            }
            
            if item.title == "terms_conditions".localized() {
                presentWebViewController(Constant.URLs.termsConditions)
            }
            
            if item.title == "privacy_policy".localized() {
                presentWebViewController(Constant.URLs.privacyPolicy)
            }
            
            if item.title == "logout".localized() {
                showLogOutPrompt()
            }
        }
    }
}
