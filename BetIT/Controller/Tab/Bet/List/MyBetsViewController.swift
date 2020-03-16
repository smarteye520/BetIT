//
//  MyBetsViewController.swift
//  BetIT
//
//  Created by OSX on 7/31/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class MyBetsViewController: BaseViewController {
    @IBOutlet weak var segment: BarSegmentControl!
    @IBOutlet weak var viewStartBet: UIView!
    @IBOutlet weak var notificationIndicatorView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var createBetButton: UIButton!

    var notificationsViewModel: NotificationsViewModel!
    var liveBetsVC: BetListViewController!
    var unsettledBetsVC: BetListViewController!
    var settledBetsVC: BetListViewController!
    var prevOffset: CGFloat = 0

    private let betDetailSegue = "sid_bet_detail"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initial view state
        createBetButton.isEnabled = true
        createBetButton.addTarget(self,
                                  action: #selector(createBetButtonPressed(_:)),
                                  for: .touchUpInside)
        
        // Hide notification indicator
        notificationIndicatorView.isHidden = true
        notificationIndicatorView.isUserInteractionEnabled = false
        
        // Scroll view
        setupScrollView()
        
        // View model
        notificationsViewModel = NotificationsViewModel()
        bind()
        notificationsViewModel.viewDidLoad()
        
        // Register for notifications
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(presentBet(_:)),
                                               name: .PresentBetNotification,
                                               object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleBranch()
        reloadData()
        notificationIndicatorView.isHidden = !notificationsViewModel.hasNewNotifications

    }
    
    override func configureUI() {
        super.configureUI()
        
        segment.items = [
            (title: BetCategory.live.title.uppercased(), alignment: .left),
            (title: BetCategory.unsettled.title.uppercased(), alignment: .center),
            (title: BetCategory.settled.title.uppercased(), alignment: .right)
        ]
        segment.index = BetCategory.live.rawValue
        
        segment.selector = { [weak self] index in
            guard let strongSelf = self else { return }
            // weak_self.currentCategory = BetCategory(rawValue: index) ?? .live
            strongSelf.scrollView.contentOffset = CGPoint(x: CGFloat(index) * strongSelf.scrollView.frame.width, y: 0)
            if let betVC = strongSelf.getViewController(at: index) {
                if betVC.viewModel.isEmpty() {
                    strongSelf.showStartBetView()
                } else {
                    strongSelf.hideStartBetView()
                }
                betVC.viewModel.viewDidLoad()
            }
        }
    }
    
    
    @IBAction func onNotifications(_ sender: Any) {
        guard let controller = UIManager.loadViewController(storyboard: "Notifications", controller: "sid_notifications") as? NotificationsViewController else { return }
        // guard let viewModelCopy = notificationsViewModel.copy() as? NotificationsViewModel else { return }
        // controller.viewModel = viewModelCopy
        controller.viewModel = notificationsViewModel
        self.navigationController?.pushViewController(controller, animated: true)
        notificationIndicatorView.isHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == betDetailSegue {
            if let controller = segue.destination as? BetDetailViewController, let bet = sender as? Bet {
                controller.viewModel = BetDetailViewModel(bet: bet)
            }
        }
    }
    
    @objc func createBetButtonPressed(_ sender: Any) {
        guard let controller = UIManager.loadViewController(storyboard: "Bet", controller: "sid_create_new") as? CreateNewViewController else { return }
        controller.viewModel = CreateBetViewModel(bet: Bet())
        self.present(UIManager.wrapNavigationController(controller: controller), animated: true, completion: nil)
    }
    
    // MARK: - Helper methods
    
    private func bind() {
        notificationsViewModel.reloadData = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.notificationIndicatorView.isHidden = !strongSelf.notificationsViewModel.hasNewNotifications
        }
        
        notificationsViewModel.didReceiveNotification = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.notificationIndicatorView.isHidden = !strongSelf.notificationsViewModel.hasNewNotifications
        }
    }

    private func setupScrollView() {
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.setNeedsLayout()
        scrollView.layoutIfNeeded()
        
        let didSelectBetHandler: (Bet) -> Void = { [weak self] bet in
            DispatchQueue.main.async {
                self?.showBet(bet)
            }
        }
        
        let refreshStartBetViewHandler: () -> Void = { [weak self] in
            DispatchQueue.main.async {
                self?.refreshStartBetView()
            }
        }
        
        // Live bets
        liveBetsVC = (storyboard?.instantiateViewController(withIdentifier: "BetListViewController") as! BetListViewController)
        liveBetsVC.viewModel = BetListViewModel(currentCategory: .live)
        liveBetsVC.didSelectBet = didSelectBetHandler
        liveBetsVC.refreshStartBetView = refreshStartBetViewHandler
        
        // Unsettled bets
        unsettledBetsVC = (storyboard?.instantiateViewController(withIdentifier: "BetListViewController") as! BetListViewController)
        unsettledBetsVC.viewModel = BetListViewModel(currentCategory: .unsettled)
        unsettledBetsVC.didSelectBet = didSelectBetHandler
        unsettledBetsVC.refreshStartBetView = refreshStartBetViewHandler

        // Settled bets
        settledBetsVC = (storyboard?.instantiateViewController(withIdentifier: "BetListViewController") as! BetListViewController)
        settledBetsVC.viewModel = BetListViewModel(currentCategory: .settled)
        settledBetsVC.didSelectBet = didSelectBetHandler
        settledBetsVC.refreshStartBetView = refreshStartBetViewHandler

        // Add bet list view controller view's as subview
        let scrollWidth = scrollView.frame.width
        let scrollHeight = scrollView.frame.height
        var xPos: CGFloat = CGFloat(0)

        self.addChild(liveBetsVC)
        liveBetsVC.view.frame = CGRect(x: xPos, y: 0, width: scrollWidth, height: scrollHeight)
        scrollView.addSubview(liveBetsVC.view)
        liveBetsVC.loadViewIfNeeded()
        
        xPos += scrollWidth
        self.addChild(unsettledBetsVC)
        unsettledBetsVC.view.frame = CGRect(x: xPos, y: 0, width: scrollWidth, height: scrollHeight)
        scrollView.addSubview(unsettledBetsVC.view)
        unsettledBetsVC.loadViewIfNeeded()
        
        xPos += scrollWidth
        self.addChild(settledBetsVC)
        settledBetsVC.view.frame = CGRect(x: xPos, y: 0, width: scrollWidth, height: scrollHeight)
        scrollView.addSubview(settledBetsVC.view)
        settledBetsVC.loadViewIfNeeded()
        
        // Setting height to 0 prevents vertical scrolling
        scrollView.contentSize = CGSize(width: scrollWidth * CGFloat(3), height: 0)
    }
    
    func showStartBetView() {
        guard viewStartBet.isHidden else { return }
        
        self.viewStartBet.alpha = 0
        self.viewStartBet.isHidden = false
        UIView.animate(withDuration: 0.1, animations: {
            self.viewStartBet.alpha = 1.0
        }) { (finished) in
            
        }
    }
    
    func hideStartBetView() {
        guard viewStartBet.isHidden == false else { return }
        
        self.viewStartBet.alpha = 1.0
        UIView.animate(withDuration: 0.1, animations: {
            self.viewStartBet.alpha = 0.0
        }) { (finished) in
            self.viewStartBet.isHidden = true
            self.viewStartBet.alpha = 1.0
        }
    }
    
    func getViewController(at index: Int) -> BetListViewController? {
        guard index >= 0, index < 3 else { return nil }
        switch index {
        case 0:
            return liveBetsVC
        case 1:
            return unsettledBetsVC
        case 2:
            return settledBetsVC
        default:
            break
        }
        return nil
    }
    
    
    func getCurrentIndex() -> Int {
        var currentIndex = Int(scrollView.contentOffset.x / scrollView.contentSize.width * 3.0)
        // Upper and lower bounds
        currentIndex = max(0, currentIndex)
        currentIndex = min(currentIndex, 3)
        return currentIndex
    }

    func refreshStartBetView() {
        // viewStartBet.isHidden = liveBetsVC.viewModel.isEmpty() && unsettledBetsVC.viewModel.isEmpty() && settledBetsVC.viewModel.isEmpty()
        guard let currentViewController = getViewController(at: getCurrentIndex()) else { return }
        if currentViewController == liveBetsVC {
            viewStartBet.isHidden = !liveBetsVC.viewModel.isEmpty()
        } else if currentViewController == unsettledBetsVC {
            viewStartBet.isHidden = !unsettledBetsVC.viewModel.isEmpty()
        } else if currentViewController == settledBetsVC {
            viewStartBet.isHidden = !settledBetsVC.viewModel.isEmpty()
        }
    }
    
    func reloadData() {
        liveBetsVC.viewModel.reloadData()
        unsettledBetsVC.viewModel.reloadData()
        settledBetsVC.viewModel.reloadData()
    }
    
    func showBet(_ bet: Bet) {
        // [START show_bet]
        // TODO: Perform sid_detail_segue with bet
        guard let betStatus = bet.status else { return }
        // TODO: Only show bet detail if bet.status == pendingBetActionNeeded and
        // bet owner is the current user, otherwise show the bet state view controller
        if let currentUserID = AppManager.shared.currentUser?.userID, let ownerID = bet.ownerID, betStatus == .pendingBetActionNeeded, currentUserID == ownerID {
            performSegue(withIdentifier: betDetailSegue, sender: bet)
        } else {
            let storyboard = UIStoryboard(name: "Notifications", bundle: nil)
            let betStateVC = storyboard.instantiateViewController(withIdentifier: "sid_bet_state") as! BetStateViewController
            betStateVC.viewModel = BetStateViewModel(bet: bet)
            navigationController?.pushViewController(betStateVC, animated: true)
        }
        // [END show_bet]
    }
    
    @objc func presentBet(_ notification: Notification) {
        guard let bet = notification.userInfo?["bet"] as? Bet else { return }
        showBet(bet)
    }
    
    func handleBranch() {
        // TODO: Fix this
        guard let params = DeepLinkManager.shared.getParams() else { return }
        guard let betJSONString = params["bet"] as? String,
              let bet = Bet(JSONString: betJSONString) else { return }
        
        // Prevent current user from opening bet if they are the owner ; only opponent should be allowed to proceed
        if let owner = bet.owner, let currentUser = AppManager.shared.currentUser, currentUser == owner {
            return
        }
        
        let storyboard = UIStoryboard(name: "Notifications", bundle: nil)
        let betStateVC = storyboard.instantiateViewController(withIdentifier: "sid_bet_state") as! BetStateViewController
        betStateVC.viewModel = BetStateViewModel(bet: bet)
        self.navigationController?.pushViewController(betStateVC, animated: true)
        DeepLinkManager.shared.resetParams()
    }
}

// MARK: - UIScrollViewDelegate

extension MyBetsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // TODO: Update segment index based on scroll view content offset
        let currentIndex = getCurrentIndex()
        segment.index = currentIndex
        guard let betVC = getViewController(at: currentIndex) else { return }
        if betVC.viewModel.isEmpty() {
            showStartBetView()
        } else {
            hideStartBetView()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentIndex = getCurrentIndex()
        segment.index = currentIndex
        guard let betVC = getViewController(at: currentIndex) else { return }
        if betVC.viewModel.isEmpty() {
            showStartBetView()
        } else {
            hideStartBetView()
        }
    }
}


