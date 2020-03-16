//
//  NotificationsViewController.swift
//  BetIT
//
//  Created by OSX on 8/6/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import UIKit

class NotificationsViewController: BaseViewController {
    @IBOutlet weak var tblNotification: UITableView!
    @IBOutlet weak var noNewNotificationsView: UIView!
    
    var refreshControl: UIRefreshControl!
    var viewModel: NotificationsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initial view state
        noNewNotificationsView.isHidden = false
        tblNotification.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)

        tblNotification.refreshControl = UIRefreshControl()
        tblNotification.refreshControl?.tintColor = .lightGray
        tblNotification.refreshControl?.addTarget(self,
                                                  action: #selector(refreshNotifications),
                                                  for: .valueChanged)
        // View model
        bind()
        viewModel.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.markNotificationsAsRead()
    }
    
    @objc func refreshNotifications() {
        viewModel.viewDidLoad()
    }
    
    override func configureUI() {
        super.configureUI()
        NotificationCell.registerWithNib(to: tblNotification)
    }
    
    private func bind() {
        viewModel.reloadData = { [weak self] in
            guard let strongSelf = self else { return }
            if strongSelf.viewModel.isEmpty() {
                strongSelf.noNewNotificationsView.isHidden = false
            } else {
                strongSelf.noNewNotificationsView.isHidden = true
                strongSelf.tblNotification.reloadData()
            }
            
            if (strongSelf.tblNotification.refreshControl?.isRefreshing ?? false) {
                strongSelf.tblNotification.refreshControl?.endRefreshing()
            }
        }
        
        viewModel.showError = { [weak self] (error) in
            // Do something with error
            guard let strongSelf = self else { return }
            if let error = error {
                strongSelf.showAlert(error.localizedDescription)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sid_bet_state", let indexPath = sender as? IndexPath {
            let controller = segue.destination as! BetStateViewController
            let bet = viewModel.notification(at: indexPath.row)?.bet ?? Bet()
            controller.viewModel = BetStateViewModel(bet: bet)
            controller.viewModel.shouldRefreshBet = true
            controller.refreshBetHandler = { [weak self] (bet, error) in
                
                if let error = error as? NSError, error.code == NotFoundError, let bet = bet {
                    print("[DEBUG] Deleting notifications for bet")
                    self?.viewModel.deleteNotifications(for: bet)
                }
            }
        }
    }
}

extension NotificationsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NotificationCell.identifier) as! NotificationCell
        if let notification = viewModel.notification(at: indexPath.row) {
            cell.reset(with: notification)
        }
        return cell
    }
}

extension NotificationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NotificationCell.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "sid_bet_state", sender: indexPath)
    }
}
