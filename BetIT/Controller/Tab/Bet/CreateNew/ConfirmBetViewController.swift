//
//  ConfirmBetViewController.swift
//  BetIT
//
//  Created by OSX on 8/6/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import UIKit
import MessageUI

class ConfirmBetViewController: BaseViewController {
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var confirmBetButton: UIButton!
    @IBOutlet weak var opponentLabel: UILabel!
    @IBOutlet weak var betTitleLabel: UILabel!
    @IBOutlet weak var betDescriptionLabel: UILabel!
    @IBOutlet weak var betWagerLabel: UILabel!
    @IBOutlet weak var deadlineLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var viewModel: ConfirmBetViewModel!
    var isAnimated: Bool = false
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        loadBet()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Let the user know the view is scrollable as Ryan requested
        scrollView.flashScrollIndicators()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isAnimated == false {
            self.viewContainer.frame = CGRect(x: 0,
                                              y: self.view.bounds.height,
                                              width: viewContainer.bounds.width,
                                              height: viewContainer.bounds.height)
            UIView.animate(withDuration: 0.3) {
                self.viewContainer.frame = CGRect(x: 0,
                                                  y: (self.view.bounds.height - self.viewContainer.bounds.height) / 2,
                                                  width: self.viewContainer.bounds.width,
                                                  height: self.viewContainer.bounds.height)
            }
        }
    }

    // MARK: - IBActions
    
    @IBAction func confirmBetButtonPressed(_ sender: Any) {
        viewModel.addBet()
    }
    
    // MARK: - Helpers
    private func bind() {
        viewModel.showError = { [weak self] errorStr in
            self?.showAlert(errorStr)
        }
        
        viewModel.didDeleteBet = { [weak self] _ in
            self?.dismiss()
        }
        
        viewModel.didCreateShortURL = { [weak self] betURL in
            DispatchQueue.main.async {
                self?.showMessageUI(message: "Hey, I just challenged you to a bet! Click this link for more \(betURL)")
            }
        }
        
        viewModel.didSendNotification = { [weak self] notification in
            self?.dismiss()
        }
    }
    
    private func loadBet() {
        opponentLabel.text = viewModel.opponentName
        betTitleLabel.text = viewModel.title
        betDescriptionLabel.text = viewModel.description
        betWagerLabel.text = viewModel.wager
        deadlineLabel.text = viewModel.deadlineText
    }
    
    private func createBranch(_ bet: Bet) {
        viewModel.createShortURL()
    }
    
    private func showMessageUI(message: String) {
        guard MFMessageComposeViewController.canSendText() else { return }
        guard let phoneNumber = viewModel.phoneNumber else { return }
        let controller = MFMessageComposeViewController()
        if #available(iOS 13.0, *) {
            controller.overrideUserInterfaceStyle = .light
        }
        controller.body = message
        controller.recipients = [phoneNumber]
        controller.messageComposeDelegate = self
        self.present(controller, animated: true, completion: nil)
    }
    
    private func createNotification() {
        viewModel.sendNotification()
    }
    
    private func dismiss() {
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: false, completion: nil)
    }
}

// MARK: - MFMessageComposeViewControllerDelegate

extension ConfirmBetViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        if result == .failed || result == .cancelled {
            viewModel.deleteBet()
        } else {
            dismiss()
        }
    }
}
