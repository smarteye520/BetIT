//
//  TabBarViewController.swift
//  BetIT
//
//  Created by OSX on 7/31/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import UIKit

extension UITabBar {
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        super.sizeThatFits(size)
        guard let window = UIApplication.shared.keyWindow else {
            return super.sizeThatFits(size)
        }
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = window.safeAreaInsets.bottom + Constant.UI.TAP_BAR_HEIGHT
        return sizeThatFits
    }
}

class TabBarController: UITabBarController {
    
    static var shared = TabBarController()
    
    private var btnCreate: UIButton!
    //MARK:- Methods
    //MARK:-
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TabBarController.shared = self
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }

        buildControllers()
        buildCreateNewButton()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        var newFrame = tabBar.frame
        newFrame.size.height = Constant.UI.TAP_BAR_HEIGHT + (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0.0)
        newFrame.origin.y = view.frame.size.height - newFrame.size.height
        
        tabBar.frame = newFrame
        if let btnCreate = btnCreate {
            self.view.bringSubviewToFront(btnCreate)
        }
    }
    
    func buildControllers() {
        let controllerAssets: [(icon: String, title: String, storyboardId: String, horzOffset: Int)] = [
            (icon: "icon_my_bets_blue", title: "My Bets", storyboardId: "Bet", horzOffset: -30),
            (icon: "icon_profile_blue", title: "My Account", storyboardId: "Account", horzOffset: 30),
        ]
        
        var childControllers: [UIViewController] = []
        for i in 0..<controllerAssets.count {
            let asset = controllerAssets[i]
            if let navigationController = UIManager.loadViewController(storyboard: asset.storyboardId) {
                let image = UIImage(named: asset.icon)
                let tabBarItem = UITabBarItem(title: asset.title, image: image?.withRenderingMode(.alwaysOriginal), tag: i)
                tabBarItem.selectedImage = image?.withRenderingMode(.alwaysTemplate)
                tabBarItem.titlePositionAdjustment = UIOffset(horizontal: CGFloat(asset.horzOffset), vertical: 0)
                
                navigationController.tabBarItem = tabBarItem
                childControllers.append(navigationController)
            }
        }
        self.viewControllers = childControllers
    }
    
    func buildCreateNewButton() {
        let buttonSize: CGFloat = 66
        btnCreate = UIButton(image: UIImage(named: "icon_plus_thick_white"), selectedImage: nil, action: #selector(onCreateNew), target: self, superView: self.view)
        btnCreate.backgroundColor = .darkBlue
        btnCreate.cornerRadius = buttonSize / 2
        btnCreate.snp.makeConstraints {
            $0.width.height.equalTo(buttonSize)
            $0.centerY.equalTo(self.tabBar.snp.top)
            $0.centerX.equalToSuperview()
        }
        
        let lblCreateNew = UILabel(font: AppFont.louisGeorgeCafe.regular(size: 10), color: .darkBlue)
        lblCreateNew.text = "Create New Bet"
        self.view.addSubview(lblCreateNew)
        lblCreateNew.snp.makeConstraints {
            $0.centerX.equalTo(btnCreate)
            $0.top.equalTo(btnCreate.snp.bottom).offset(5)
        }
    }
    
    @objc
    func onCreateNew() {
        guard let controller = UIManager.loadViewController(storyboard: "Bet", controller: "sid_create_new") as? CreateNewViewController else {
            return
        }
        controller.viewModel = CreateBetViewModel(bet: Bet())
        self.present(UIManager.wrapNavigationController(controller: controller), animated: true, completion: nil)
    }
    
}

