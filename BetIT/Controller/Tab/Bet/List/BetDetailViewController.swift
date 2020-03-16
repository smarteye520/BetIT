
//
//  BetDetailViewController.swift
//  BetIT
//
//  Created by OSX on 7/31/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import UIKit
import FirebaseUI

class BetDetailViewController: BaseViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var txtTitleOfBet: UITextField!
    @IBOutlet weak var lblBetWager: UILabel!
    @IBOutlet weak var txtBetWager: UITextView!
    @IBOutlet weak var btnBetDeadline: UIButton!
    @IBOutlet weak var lblBetTimeRemaining: UILabel!
    @IBOutlet weak var lblBetStatus: UILabel!
    @IBOutlet weak var btnEditBet: UIButton!
    @IBOutlet weak var stackSaveEdit: UIStackView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var initialNameLabel: UILabel!
    @IBOutlet weak var titleLimitLabel: UILabel!
    @IBOutlet weak var saveEditButton: UIButton!
    @IBOutlet weak var deadlineView: UIView!
    @IBOutlet weak var betDescriptionTextView: UITextView!
    
    @IBOutlet weak var betDescriptionPlaceholder: UILabel!
    // MARK: - Variables
    
    var viewModel: BetDetailViewModel!
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(didSetDeadline(_:)), name: .DidSetDeadline, object: nil)
        bind()
        viewModel.viewDidLoad()
        setupUI()
    }

    // MARK: - Helpers
    
    private func setupUI() {
        txtTitleOfBet.delegate = self
        txtTitleOfBet.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        txtBetWager.delegate = self
        imgUser.layer.cornerRadius = min(imgUser.frame.width, imgUser.frame.height) / CGFloat(2.0)
        titleLimitLabel.attributedText = viewModel.getTitleLimitAttributedText(txtTitleOfBet.text)
        
        betDescriptionTextView.delegate = self
        betDescriptionTextView.textContainer.lineFragmentPadding = 0
        betDescriptionTextView.textContainerInset = .zero
        
        txtBetWager.delegate = self
        txtBetWager.textContainer.lineFragmentPadding = 0
        txtBetWager.textContainerInset = .zero
    }
    
    private func bind() {
        viewModel.disableBetEditing = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.btnEditBet.isHidden = true
            strongSelf.stackSaveEdit.isHidden = true
            strongSelf.deleteButton.isHidden = true
        }
        
        viewModel.enableBetEditing = { [weak self] in
            guard let strongSelf = self else { return }

            strongSelf.deleteButton.isHidden = false
            strongSelf.btnEditBet.isHidden = strongSelf.viewModel.mode == .editing
            strongSelf.stackSaveEdit.isHidden = strongSelf.viewModel.mode != .editing
            strongSelf.btnBetDeadline.isEnabled = strongSelf.viewModel.mode == .editing
        }
        
        viewModel.reloadData = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.title = strongSelf.viewModel.title
            // Image view
            if let photoRef = strongSelf.viewModel.photoReference {
                strongSelf.imgUser.sd_setImage(with: photoRef)
                strongSelf.initialNameLabel.isHidden = true
            } else {
                strongSelf.initialNameLabel.isHidden = false
                strongSelf.initialNameLabel.text = strongSelf.viewModel.usernameInitial
            }
            
            strongSelf.lblUsername.text = strongSelf.viewModel.usernameText
            strongSelf.txtTitleOfBet.text = strongSelf.viewModel.title
            strongSelf.betDescriptionTextView.text = strongSelf.viewModel.description
            strongSelf.betDescriptionPlaceholder.isHidden = strongSelf.betDescriptionTextView.text.count > 0

            // self.txtBetDescription.text = self.viewModel.description
            strongSelf.txtBetWager.text = strongSelf.viewModel.wager
            strongSelf.lblBetWager.isHidden = strongSelf.txtBetWager.text.count > 0

            strongSelf.deadlineView.isHidden = true
            if let deadline = strongSelf.viewModel.deadlineText, let timeRemaining = strongSelf.viewModel.betTimeRemaining {
                strongSelf.deadlineView.isHidden = false
                strongSelf.btnBetDeadline.setTitle(deadline, for: .normal)
                strongSelf.lblBetTimeRemaining.text = timeRemaining
            }
        }
        
        viewModel.onDelete = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.performSegue(withIdentifier: "unwindSegue", sender: strongSelf)
        }
    }
        
    private func toggleViewsForEditing() {
        btnEditBet.isHidden = viewModel.mode == .editing
        stackSaveEdit.isHidden = viewModel.mode == .normal
        btnBetDeadline.isEnabled = viewModel.mode == .editing
        txtBetWager.isEditable = viewModel.mode == .editing
    }
    
    // MARK: - IBActions
    @objc func textFieldDidChange(_ textField: UITextField) {
        titleLimitLabel.attributedText = viewModel.getTitleLimitAttributedText(textField.text)
        self.title = textField.text
        saveEditButton.isEnabled = viewModel.isValidTitle(txtTitleOfBet.text)
    }
    
    @IBAction func onDeadlineChange(_ sender: Any) {
        guard viewModel.canEditBet else { return }
        guard let controller = UIManager.loadViewController(storyboard: "Bet", controller: "sid_select_datetime") as? SelectDateTimeViewController else { return }
        
        UIManager.modal(controller: controller, parentController: self)
    }
    
    @IBAction func onDelete(_ sender: Any) {
        guard viewModel.canEditBet else { return }
        
        UIManager.showAlert(title: "Delete Bet", message: "Are you sure you want to \n delete this bet?", buttons: ["Cancel", "Delete"], completion: { [weak self] (index) in
            if index == 1 {
                self?.viewModel.deleteBet()
            }
        }, parentController: self)
    }
    
    @IBAction func onEditBet(_ sender: Any) {
        guard viewModel.canEditBet else { return }
        viewModel.mode = .editing
        toggleViewsForEditing()
    }
    
    @IBAction func onSaveEdit(_ sender: Any) {
        guard viewModel.canEditBet else { return }
        viewModel.mode = .normal
        viewModel.updateBet(title: txtTitleOfBet.text,
                            description: betDescriptionTextView.text,
                            wager: txtBetWager.text)
        toggleViewsForEditing()
    }
    
    @IBAction func onCancelEdit(_ sender: Any) {
        viewModel.mode = .normal
        viewModel.setDeadline(nil)
        toggleViewsForEditing()
    }
    
    @objc func didSetDeadline(_ notification: Notification) {
        guard let deadline = notification.userInfo?["deadline"] as? Date else { return }
        viewModel.setDeadline(deadline)
    }
        
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: - UITextFieldDelegate
extension BetDetailViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return viewModel.shouldBeginEditing
    }
}

// MARK: - UITextViewDelegate

extension BetDetailViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return viewModel.shouldBeginEditing
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == betDescriptionTextView {
            betDescriptionPlaceholder.isHidden = betDescriptionTextView.text.count > 0
        }
        
        if textView == txtBetWager {
            lblBetWager.isHidden = txtBetWager.text.count > 0 
        }
    }
}
