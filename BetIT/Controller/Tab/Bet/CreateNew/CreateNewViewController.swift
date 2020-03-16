//
//  CreateNewViewController.swift
//  BetIT
//
//  Created by OSX on 7/31/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import UIKit
import ContactsUI
import IQKeyboardManagerSwift

class CreateNewViewController: BaseViewController {
    private let placeHolderText = "Search name or phone number"
    
    @IBOutlet weak var searchNamePhoneNumberField: UITextField!
    @IBOutlet weak var betTitleField: UITextField!
    @IBOutlet weak var betDescriptionPlaceholder: UILabel!
    @IBOutlet weak var betDescriptionTextView: UITextView!
    @IBOutlet weak var betWagerTextView: UITextView!
    @IBOutlet weak var betWagerPlaceholder: UILabel!
    @IBOutlet weak var deadlineButton: UIButton!
    @IBOutlet weak var sendBetButton: UIButton!
    @IBOutlet weak var promptAddNameButtonLabel: UIButton!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var promptAddNameError: UIImageView!
    @IBOutlet weak var titleLimitLabel: UILabel!
    
    var viewModel: CreateBetViewModel!
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.presentationController?.delegate = self
        setupUI()
        bind()
        viewModel.viewDidLoad()
    }
    
    // MARK: - Helper methods
    
    private func setupUI() {
        // Phone number field
        searchNamePhoneNumberField.delegate = self
        searchNamePhoneNumberField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        sendBetButton.isEnabled = false
        
        // Bet title
        betTitleField.delegate = self
        betTitleField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        // Bet wager
        betWagerTextView.delegate = self
        betWagerTextView.textContainer.lineFragmentPadding = 0
        betWagerTextView.textContainerInset = .zero
        
        // Bet description
        betDescriptionTextView.delegate = self
        betDescriptionTextView.textContainer.lineFragmentPadding = 0
        betDescriptionTextView.textContainerInset = .zero
        
        // Title limit
        titleLimitLabel.attributedText = viewModel.getTitleLimitAttributedText(betTitleField.text)
    }
    
    private func bind() {
        viewModel.didSelectDeadline = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.deadlineButton.setTitle(strongSelf.viewModel.deadlineText, for: .normal)
        }
        
        viewModel.didSelectUser = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.searchNamePhoneNumberField.text = strongSelf.viewModel.opponent?.fullName
            strongSelf.sendBetButton.isEnabled = true
        }
        
        viewModel.didSelectPhoneNumber = { [weak self] in
            guard let strongSelf = self else { return }
            if strongSelf.viewModel.hasPhoneNumber {
                strongSelf.searchNamePhoneNumberField.placeholder = ""
                strongSelf.searchNamePhoneNumberField.text = ""

                strongSelf.promptAddNameButtonLabel.isHidden = false
                strongSelf.phoneNumberLabel.text = strongSelf.viewModel.phoneNumber
                strongSelf.phoneNumberLabel.isHidden = false
                strongSelf.sendBetButton.isEnabled = true
            }
        }
        
        viewModel.didSelectContact = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.searchNamePhoneNumberField.text = strongSelf.viewModel.contactName
            if strongSelf.viewModel.hasPhoneNumber {
                strongSelf.phoneNumberLabel.text = strongSelf.viewModel.phoneNumber
                strongSelf.phoneNumberLabel.isHidden = false
            } else {
                strongSelf.phoneNumberLabel.isHidden = true
            }
            strongSelf.sendBetButton.isEnabled = true
        }
    }
    
    private func showDismissAlert() {
        UIManager.showAlert(title: "Discard Draft", message: "Are you sure you want to \n discard this?", buttons: ["Go Back", "Discard"], completion: { [weak self] (index) in
            //alert ended with index
            if index == 1 {
                self?.presentingViewController?.dismiss(animated: true)
            }
        }, parentController: self)
    }
    
    // MARK: - IBActions
    @IBAction func cancelButtonPressed(_ sender: Any) {
        showDismissAlert()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField == betTitleField {
            if let attributedBetTitleLimit = viewModel.getTitleLimitAttributedText(textField.text) {
                titleLimitLabel.attributedText = attributedBetTitleLimit
            }
            sendBetButton.isEnabled = viewModel.isValidTitle(betTitleField.text)
        }
    }

    @IBAction func addNameButtonPressed(_ sender: Any) {
        promptAddNameButtonLabel.isHidden = true
        searchNamePhoneNumberField.becomeFirstResponder()
    }
    
    @objc func didPressCancel(_ notification: Notification) {
        self.view.resignFirstResponder()
    }
    
    // MARK: - Segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueID = segue.identifier, segueID == "sid_confirm_bet" {
            if let controller = segue.destination as? ConfirmBetViewController {
                if let bet = self.viewModel.build(title: betTitleField.text,
                                               wager: betWagerTextView.text,
                                               description: betDescriptionTextView.text,
                                               inviteeUserName: searchNamePhoneNumberField.text)
                {
                    controller.viewModel = ConfirmBetViewModel(bet: bet)
                }
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "sid_add_opponent" {
            if viewModel.hasPhoneNumber {
                return false
            }
        }
        
        if identifier == "sid_confirm_bet" {
            guard let betTitle = betTitleField.text?.trimmingCharacters(in: .whitespacesAndNewlines), betTitle.count > 0 else { return false }

            guard let wager = betWagerTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines), wager.count > 0 else { return false }
            
            guard let name = searchNamePhoneNumberField.text?.trimmingCharacters(in: .whitespacesAndNewlines), name.count > 0 else { return false }
            guard viewModel.isValidTitle(betTitle) else { return false }
            guard viewModel.hasOpponent || viewModel.hasPhoneNumber else { return false }
        }
        return true
    }
}


extension CreateNewViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == searchNamePhoneNumberField {
            guard let searchNameText = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
            if searchNameText.count == 0 {
                promptAddNameButtonLabel.isHidden = false
                promptAddNameButtonLabel.setTitleColor(UIColor(red: 1.0, green: 52.0 / 255.0, blue: 77.0 / 255.0, alpha: 1.0), for: .normal)
                promptAddNameButtonLabel.setTitle(placeHolderText, for: .normal)
                sendBetButton.isEnabled = false
            } else {
                // promptAddNameButtonLabel.isHidden = true
                promptAddNameButtonLabel.isHidden = false
                promptAddNameButtonLabel.setTitleColor(.clear, for: .normal)
                promptAddNameButtonLabel.setTitle("", for: .normal)
                sendBetButton.isEnabled = true
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == betTitleField {
            betDescriptionTextView.becomeFirstResponder()
        }
        return false
    }
}

// MARK: - UITextViewDelegate

extension CreateNewViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView == betDescriptionTextView {
            betDescriptionPlaceholder.isHidden = betDescriptionTextView.text.count > 0
        }
        
        if textView == betWagerTextView {
            betWagerPlaceholder.isHidden = betWagerTextView.text.count > 0
        }
    }
}

// MARK: UIAdaptivePresentationControllerDelegate

extension CreateNewViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return false
    }
    
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        showDismissAlert()
    }
}
