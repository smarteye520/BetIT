//
//  BetListViewController.swift
//  BetIT
//
//  Created by joseph on 9/4/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import UIKit


class BetListViewController: UIViewController {
    var viewModel: BetListViewModel!
    var didSelectBet: ((Bet) -> Void)!
    var refreshStartBetView: (() -> Void)!
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear

        // Setup table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.tintColor = .white
        tableView.refreshControl?.addTarget(self,
                                            action: #selector(refreshBets),
                                            for: .valueChanged)
        
        // TODO: Uncomment this if you want to hide table view section headers when scrolling
        // [START hide_table_view_section_header]
        // tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: CGFloat(40)))
        // tableView.contentInset = UIEdgeInsets(top: -CGFloat(40), left: 0, bottom: 0, right: 0)
        // [END hide_table_view_section_header]

        BetCell.registerWithNib(to: tableView)
        BetCell.registerWithNib(to: tableView, nibName: "BetCellConfirm", identifier: "bet_cell_confirm")
        BetCell.registerWithNib(to: tableView, nibName: "BetCellSettle", identifier: "bet_cell_settle")
        BetCell.registerWithNib(to: tableView, nibName: "BetCellRequest", identifier: "bet_cell_request")
        BetCell.registerWithNib(to: tableView, nibName: "BetCellSimple", identifier: "bet_cell_simple")
        BetCell.registerWithNib(to: tableView, nibName: "BetCellConfirmOwner", identifier: "bet_cell_confirm_owner")
        BetCell.registerWithNib(to: tableView, nibName: "BetCellSettleOwner", identifier: "bet_cell_settle_owner")
        
        bind()
        viewModel.viewDidLoad()
    }
    
    // MARK: - Helper
    
    private func bind() {
        viewModel.showError = { [weak self] error in
            guard let strongSelf = self else { return }
            strongSelf.showAlert(error.localizedDescription)
        }
        
        viewModel.reloadData = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.tableView.reloadData()
            strongSelf.refreshStartBetView()
            if (strongSelf.tableView.refreshControl?.isRefreshing ?? false) {
                strongSelf.tableView.refreshControl?.endRefreshing()
            }
        }
    }
    
    @objc func refreshBets() {
        viewModel.viewDidLoad()
    }
}

// MARK: - UITableViewDataSource

extension BetListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let bet = viewModel.bet(at: indexPath)
        guard let status = bet.status, let currentUserID = AppManager.shared.currentUser?.userID else { return UITableViewCell() }
        var cell: BetCell

        if status == .youClaimedWin || status == .opponentClaimedWin, let targetUserID = bet.targetUserID, targetUserID == currentUserID {
            cell = tableView.dequeueReusableCell(withIdentifier: "bet_cell_confirm_owner", for: indexPath) as! BetCell
        } else if status == .endActionConfirmNeeded, let targetUserID = bet.targetUserID, targetUserID != currentUserID {
            cell = tableView.dequeueReusableCell(withIdentifier: "bet_cell_settle_owner", for: indexPath) as! BetCell
        } else if status == .pendingBetActionNeeded, let ownerID = bet.ownerID, ownerID != currentUserID {
            cell = tableView.dequeueReusableCell(withIdentifier: "bet_cell_request", for: indexPath) as! BetCell
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: status.cellIdentifier) as! BetCell
        }
        cell.delegate = self
        cell.reset(with: bet)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension BetListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectBet(viewModel.bet(at: indexPath))
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let count = self.tableView(tableView, numberOfRowsInSection: section)
        return (count > 0) ? 30 : 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = BetSectionHeader(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 30))
        headerView.setTitle(viewModel.title(at: section))
        return headerView
    }
}

// MARK: - BetCellDelegate

extension BetListViewController: BetCellDelegate {
    
    func betCell(_ betCell: BetCell, didPressAcceptBetRequestButton acceptButton: UIButton) {
        guard let indexPath = tableView.indexPath(for: betCell) else { return }
        guard AppManager.shared.currentUser?.userID != nil else { return }
        let bet = viewModel.bet(at: indexPath)
        guard let betStatus = bet.status, betStatus == .pendingBetActionNeeded else { return }
        bet.status = .live
        viewModel.updateBet(bet)
        viewModel.sendNotification(for: bet)
        
        NotificationCenter.default.post(name: .DidUpdateBetStatus,
                                        object: nil,
                                        userInfo: ["bet": bet])

    }
    
    func betCell(_ betCell: BetCell, didPressDeclineBetRequestButton declineButton: UIButton) {
        guard let indexPath = tableView.indexPath(for: betCell) else { return }
        guard AppManager.shared.currentUser?.userID != nil else { return }
        let bet = viewModel.bet(at: indexPath)
        guard let betStatus = bet.status, betStatus == .pendingBetActionNeeded else { return }
        bet.status = .declined
        viewModel.updateBet(bet)
        viewModel.sendNotification(for: bet)
        
        NotificationCenter.default.post(name: .DidUpdateBetStatus,
                                        object: nil,
                                        userInfo: ["bet": bet])
    }
    
    
    func betCell(_ betCell: BetCell, didPressDenyButton denyButton: UIButton) {
        guard let indexPath = tableView.indexPath(for: betCell) else { return }
        guard let currentUserID = AppManager.shared.currentUser?.userID else { return }
        let bet = viewModel.bet(at: indexPath)
        guard let betStatus = bet.status, betStatus == .opponentClaimedWin || betStatus == .youClaimedWin else { return }
        bet.status = .disputed
        bet.targetUserID = currentUserID
        viewModel.updateBet(bet)
        viewModel.sendNotification(for: bet)
        
        // TODO: Might not need this
        NotificationCenter.default.post(name: .DidUpdateBetStatus,
                                        object: nil,
                                        userInfo: ["bet": bet])

    }
    
    func betCell(_ betCell: BetCell, didPressConfirmButton confirmButton: UIButton) {
        guard let indexPath = tableView.indexPath(for: betCell) else { return }
        let bet = viewModel.bet(at: indexPath)
        guard let betStatus = bet.status, betStatus == .opponentClaimedWin || betStatus == .youClaimedWin else { return }
        // Opponent claimed the win, and we're confirming they won
        guard let otherUserID = bet.otherUser?.userID else { return }
        bet.targetUserID = otherUserID
        bet.status = .endActionConfirmNeeded
        viewModel.updateBet(bet)
        viewModel.sendNotification(for: bet)

        // TODO: Might not need this
        NotificationCenter.default.post(name: .DidUpdateBetStatus,
                                        object: nil,
                                        userInfo: ["bet": bet])

    }
    
    func betCell(_ betCell: BetCell, didPressSettledButton settledButton: UIButton) {
        guard let indexPath = tableView.indexPath(for: betCell) else { return }
        let bet = viewModel.bet(at: indexPath)
        guard let betStatus = bet.status, betStatus == .endActionConfirmNeeded else { return }
        bet.status = .betWon
        viewModel.updateBet(bet)
        viewModel.sendNotification(for: bet)
        
        // TODO: Might not need this
        NotificationCenter.default.post(name: .DidUpdateBetStatus,
                                        object: nil,
                                        userInfo: ["bet": bet])
    }
}


// MARK: BetStatus Cell Identifier

extension BetStatus {
    var cellIdentifier: String {
        switch self {
        case .live, .pendingBetActionNeeded:
            return "bet_cell"
        case .opponentClaimedWin, .youClaimedWin:
            return "bet_cell_confirm"
        case .disputed, .betLost, .betWon, .declined, .expired:
            return "bet_cell_simple"
        default:
            return "bet_cell_settle"
        }
    }
}
