//
//  UIManager.swift
//  BetIT
//
//  Created by OSX on 6/12/19.
//  Copyright © 2019 Majestyk Apps. All rights reserved.
//

import UIKit

class UIManager {
    static let shared = UIManager()

    func initTheme() {
        UINavigationBar.appearance().tintColor = UIColor.darkBlue
        UINavigationBar.appearance().barTintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white];
        
        UITabBar.appearance().tintColor = UIColor.darkBlue
        UITabBar.appearance().backgroundColor = UIColor.white
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: AppFont.louisGeorgeCafe.regular(size: 10),
                                                          NSAttributedString.Key.foregroundColor: UIColor.darkBlue], for: .normal)

    }
}


//App View
extension UIManager {
    static func showMain(animated: Bool = false) {
        self.setRootViewController(controller: TabBarController(), animated: animated)
    }
    
    static func showLogin(animated: Bool = false) {
        if let controller = loadViewController(storyboard: "Auth") {
            self.setRootViewController(controller: controller, animated: animated)
        }
    }
}

//Safe area
extension UIManager {
    static func bottomPadding() -> CGFloat {
        guard #available(iOS 11.0, *), let window = UIApplication.shared.keyWindow else {
            return 0
        }
        return window.safeAreaInsets.bottom
    }
    
    static func topPadding() -> CGFloat {
        guard #available(iOS 11.0, *), let window = UIApplication.shared.keyWindow else {
            return 0
        }
        return window.safeAreaInsets.top
    }
    
    static func windowFrame(of view: UIView) -> CGRect {
        var maskRect = view.convert(view.frame, to: UIApplication.shared.keyWindow!)
        maskRect.origin.y = maskRect.origin.y + UIManager.topPadding()
        return maskRect
    }
}

//Primary
extension UIManager {
    static func showAlert(title: String, message: String, buttons: [String], completion: AlertCompletion? = nil, parentController: UIViewController? = nil) {
        guard let presenter = parentController ?? UIApplication.shared.keyWindow?.rootViewController else {
            return
        }

        let controller = AlertViewController(title: title, message: message, buttons: buttons, completion: completion)
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .overFullScreen
        presenter.present(controller, animated: true, completion: nil)
    }
    
    static func wrapNavigationController(controller: UIViewController) -> UINavigationController {
        return BaseNavigationController(rootViewController: controller)
    }
    
    static func loadViewController(storyboard name: String, controller identifier: String? = nil) -> UIViewController? {
        guard let identifier = identifier else {
            return UIStoryboard(name: name, bundle: nil).instantiateInitialViewController()
        }
        return UIStoryboard(name: name, bundle: nil).instantiateViewController(withIdentifier: identifier)
    }
    
    static func modal(controller: UIViewController, parentController: UIViewController? = nil) {
        guard let presenter = parentController ?? UIApplication.shared.keyWindow?.rootViewController else {
            return
        }
        
        guard let controller = controller as? ModalViewController else {
            return
        }
        
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        presenter.present(controller, animated: true, completion: nil)        
    }
    
/*
    //present view controller with Hero animation
    static func presentViewController(controller: UIViewController, animated: Bool = true, animationType: HeroDefaultAnimationType = .selectBy(presenting: .cover(direction: .left), dismissing: .uncover(direction: .right)), viewController: UIViewController? = nil) {
        
        if let viewController = viewController {
            controller.hero.isEnabled = true
            controller.hero.modalAnimationType = animationType
            viewController.present(controller, animated: animated, completion: nil)
            return
        }
        
        guard let window = UIApplication.shared.keyWindow, let rootViewController = window.rootViewController else {
            return
        }
        DispatchQueue.main.async {
            controller.hero.isEnabled = true
            controller.hero.modalAnimationType = animationType
            rootViewController.present(controller, animated: animated, completion: nil)
        }
    }
    
    static func presentFromLeft(controller: UIViewController, animated: Bool = true, viewController: UIViewController? = nil) {
        let animationType: HeroDefaultAnimationType = .selectBy(presenting: .push(direction: .right), dismissing: .pull(direction: .left))
        self.presentViewController(controller: controller, animated: animated, animationType: animationType, viewController: viewController)
    }
    
    static func presentFromRight(controller: UIViewController, animated: Bool = true, viewController: UIViewController? = nil) {
        let animationType: HeroDefaultAnimationType = .selectBy(presenting: .push(direction: .left), dismissing: .pull(direction: .right))
        self.presentViewController(controller: controller, animated: animated, animationType: animationType, viewController: viewController)
    }
    
    static func presentFromBottom(controller: UIViewController, animated: Bool = true, viewController: UIViewController? = nil) {
        let animationType: HeroDefaultAnimationType = .selectBy(presenting: .cover(direction: .up), dismissing: .uncover(direction: .down))
        self.presentViewController(controller: controller, animated: animated, animationType: animationType, viewController: viewController)
    }
 */
    
    //change root view controller
    static func setRootViewController(controller: UIViewController, animated: Bool = false) {
        DispatchQueue.main.async {
            if let window = UIApplication.shared.keyWindow {
                guard let rootViewController = window.rootViewController else {
                    return
                }
                
                controller.view.frame = rootViewController.view.frame
                controller.view.layoutIfNeeded()
                
                if animated {
                    UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                        window.rootViewController = controller
                    }, completion: nil)
                }
                else {
                    window.rootViewController = controller
                }
            }
            else {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window = UIWindow(frame: UIScreen.main.bounds)
                appDelegate.window?.backgroundColor = UIColor.white
                appDelegate.window?.rootViewController = controller
                appDelegate.window?.makeKeyAndVisible()
            }
        }
    }
}
