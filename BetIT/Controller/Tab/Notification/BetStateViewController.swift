//
//  BetStateViewController.swift
//  BetIT
//
//  Created by OSX on 8/9/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import UIKit

class BetStateViewController: BaseViewController {
    
    var viewModel: BetStateViewModel!
    var refreshBetHandler: ((Bet?, Error?) -> Void)?
    
    //Bet property
    @IBOutlet weak var imgStatus: UIImageView!
    @IBOutlet weak var viewStatus: UIView!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblBetDescription: UILabel!
    @IBOutlet weak var lblWager: UILabel!
    @IBOutlet weak var viewDeadline: UIStackView!
    @IBOutlet weak var btnBetDeadline: UIButton!
    @IBOutlet weak var lblBetTimeRemaining: UILabel!
    @IBOutlet weak var deadlineDetailLabel: UILabel!
    @IBOutlet weak var deadlineTitleLabel: UILabel!
    
    //Containers
    @IBOutlet weak var viewDoOrCancel: UIStackView!
    @IBOutlet weak var btnDo: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var viewClaim: UIView!
    @IBOutlet weak var lblClaim: UILabel!
    @IBOutlet weak var lblClaimDescription: UILabel!
    @IBOutlet weak var viewCongratulations: UIStackView!
    @IBOutlet weak var viewAlert: UIStackView!
    @IBOutlet weak var lblAlertDescription: UILabel!
    @IBOutlet weak var viewBlackGreenButtons: UIStackView!
    @IBOutlet weak var btnBlack: UIButton!
    @IBOutlet weak var btnGreen: UIButton!
    @IBOutlet weak var viewBetSettle: UIStackView!
    @IBOutlet weak var settleButton: UIButton!
    @IBOutlet weak var initialNameLabel: UILabel!
    @IBOutlet weak var betSentLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        viewModel.inputs.viewDidLoad()
    }
    
    override func configureUI() {
        super.configureUI()
        imgUser.layer.cornerRadius = min(imgUser.frame.height, imgUser.frame.width) / CGFloat(2.0)
        resetUI()
    }
    
    private func bind() {
        viewModel.outputs.didDelete = { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        
        viewModel.outputs.didAccept = { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        
        viewModel.outputs.didUpdate = { [weak self] _ in
            self?.reloadData()
        }
            
        viewModel.outputs.didRefresh = { [weak self] error in
            guard let `self` = self else { return }
            if let error = error as NSError? {
                if error.code == NotFoundError {
                    self.refreshBetHandler?(self.viewModel.getBet(), error)
                    self.showDefaultCustomAlert(title: "Too Late", message: "Bet request was deleted by the sender", button: "Go Back")
                } else {
                    self.showDefaultCustomAlert(title: "Could not", message: "Bet request was deleted by the sender", button: "Go Back")
                }
                return
            }
            self.reloadData()
        }
        
        viewModel.reloadData = reloadData

        viewModel.showCustomAlert = { [weak self] alertData in
            self?.showCustomAlert(alertData)
        }
    }
    
    func reloadData() {
        self.loadBetInfo()
        self.loadActions()
        self.loadStatus()
    }
    
    func loadBetInfo() {
        self.title = viewModel.title
        lblUserName.text = viewModel.usernameText
        if let thumbnail = viewModel.thumbnail {
            imgUser.sd_setImage(with: UploadManager.shared.getReference(for: thumbnail))
            initialNameLabel.isHidden = true
        } else {
            initialNameLabel.isHidden = false
            initialNameLabel.text = viewModel.usernameInitial
        }
        lblBetDescription.text = viewModel.description
        lblWager.text = viewModel.wager
        btnBetDeadline.setTitle(viewModel.deadlineText, for: .normal)
        lblBetTimeRemaining.text = viewModel.betTimeRemaining
    }
    
    func loadStatus() {
        guard let status = viewModel.betStatus else { return }

        viewStatus.isHidden = true
        imgStatus.image = nil
        lblStatus.text = nil
        
        // If current user claimed a win, then hide the status
        if status == .opponentClaimedWin || status == .youClaimedWin {
            viewStatus.isHidden = true
            return
        }

        if status == .endActionConfirmNeeded {
            return
        }

        if let image = status.statusImage {
            viewStatus.isHidden = false
            imgStatus.image = image
        }
        
        if let color = status.statusColor {
            viewStatus.isHidden = false
            imgStatus.backgroundColor = color
        }
        
        if let statusTitle = status.title {
            lblStatus.text = "Status: " + statusTitle.uppercased()
        }
    }
    
    func resetUI() {
        viewDeadline.isHidden = true
        viewDoOrCancel.isHidden = true
        viewClaim.isHidden = true
        viewCongratulations.isHidden = true
        viewAlert.isHidden = true
        viewBlackGreenButtons.isHidden = true
        viewBetSettle.isHidden = true
        deleteButton.isHidden = true
        betSentLabel.attributedText = nil
    }
    
    func loadActions() {
        resetUI()
        
        viewDeadline.isHidden = viewModel.shouldHideDeadline
        betSentLabel.attributedText = viewModel.betSentAttributedText
        deleteButton.isHidden = !viewModel.inputs.canDeleteBet
        guard let status = viewModel.betStatus else { return }
        switch status {
        case .live:
            viewAlert.isHidden = false
            lblAlertDescription.text = "bet_accepted_description".localized()
            viewBlackGreenButtons.isHidden = false
            btnBlack.setTitle("i_lost".localized(), for: .normal)
            btnGreen.setTitle("i_won".localized(), for: .normal)
        case .pendingBetActionNeeded:
            viewDoOrCancel.isHidden = false
            btnDo.setTitle("accept_bet".localized(), for: .normal)
            btnCancel.setTitle("decline_bet".localized(), for: .normal)
        case .betWon, .betLost, .endActionConfirmNeeded:
            guard let currentUserID = AppManager.shared.currentUser?.userID else { return }
            guard let targetUserID = viewModel.targetUserID else { return }
            if targetUserID == currentUserID {
                // If current user claimed win and other user confirmed it, show the settle bet view
                if status == .endActionConfirmNeeded {
                    viewBetSettle.isHidden = false
                }
                viewCongratulations.isHidden = false
            } else {
                self.viewClaim.isHidden = false
                self.lblClaim.text = "YOU LOST ;(".localized()
                self.lblClaimDescription.text = "This won’t be the last time. Wipe those tears and quickly settle up!"
            }
        case .opponentClaimedWin, .youClaimedWin:
            guard let currentUserID = AppManager.shared.currentUser?.userID else { return }
            guard let targetUserID = viewModel.targetUserID else { return }
            // Opponent / owner claimed win, check the target user id
            if targetUserID == currentUserID {
                viewClaim.isHidden = false
                lblClaim.text = "winning_claimed".localized()
                lblClaimDescription.text = "winning_claimed_description".localized()
            } else {
                self.lblClaim.text = "lost_claimed".localized()
                self.lblClaimDescription.text = "lost_claimed_description".localized()
                viewDoOrCancel.isHidden = false
                btnDo.setTitle("confirm_their_win".localized(), for: .normal)
                btnCancel.setTitle("dispute".localized(), for: .normal)
            }
        case .disputed:
            viewClaim.isHidden = false
            lblClaim.text = "bet_disputed".localized()
            lblClaimDescription.text = "claim_again".localized()
            viewBlackGreenButtons.isHidden = false
            btnBlack.setTitle("i_lost".localized(), for: .normal)
            btnGreen.setTitle("i_won".localized(), for: .normal)
        case .expired:
            deadlineDetailLabel.text = "This bet is expired."
            deadlineTitleLabel.text = "DEADLINE"
        default:
            break
        }
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        viewModel.inputs.onDelete()
    }
    
    @IBAction func onBlack(_ sender: Any) {
        viewModel.inputs.onBlack()
    }
    
    @IBAction func onGreen(_ sender: Any) {
        viewModel.inputs.onGreen()
    }
    
    @IBAction func onDo(_ sender: Any) {
        viewModel.inputs.onDo()
    }
    
    @IBAction func onCancel(_ sender: Any) {
        viewModel.inputs.onCancel()
    }
    
    @IBAction func onSettle(_ sender: Any) {
        viewModel.inputs.currentUserDidSettle()
    }
        
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}
