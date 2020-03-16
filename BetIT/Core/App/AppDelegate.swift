//
//  AppDelegate.swift
//  BetIT
//
//  Created by OSX on 7/31/19.
//  Copyright © 2019 MajestykApps. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Firebase
import UserNotifications
import Branch

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // [START branch]
        DeepLinkManager.shared.configure(launchOptions)
        // [END branch]

        // Override point for customization after application launch.
        loadFramework()
        
        // Remote notifications
        registerForRemoteNotifications(application)
        handleRemoteNotificationAppLaunch(launchOptions)

        AppManager.shared.showNext()
        return true
    }
    
    // Respond to URI scheme links
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let branchHandled = DeepLinkManager.shared.open(application,
                                                        url: url,
                                                        sourceApplication: sourceApplication,
                                                        annotation: annotation)
        if !branchHandled {
            // If not handled by Branch, do other deep link routing for the Facebook SDK, Pinterest SDK, etc
        }
        // do other deep link routing for the Facebook SDK, Pinterest SDK, etc
        return true
    }

    // Respond to Universal Links
    
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        // handler for Universal Links
        // Branch.getInstance().continue(userActivity)
        DeepLinkManager.shared.continueActivity(userActivity)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        NotificationManager.shared.handleRemoteNotification(userInfo)
        DeepLinkManager.shared.handlePushNotification(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }

}

// MARK: - AppDelegate helper methods
extension AppDelegate {
    func loadFramework() {
        // Firebase
        FirebaseApp.configure()
        
        // IQKeyboardManager
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.previousNextDisplayMode = .alwaysHide
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
        
        UIManager.shared.initTheme()
        ProgressHUD.configure()
        
    }

    func registerForRemoteNotifications(_ application: UIApplication) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (granted, error) in
                if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
    }

    // [START handle_remote_notification_app_launch]
    func handleRemoteNotificationAppLaunch(_ launchOptions: [AnyHashable: Any]?) {
        guard let launchOptions = launchOptions else { return }
        guard let notificationInfo = launchOptions[UIApplication.LaunchOptionsKey.remoteNotification] as? [AnyHashable: Any] else { return }
        guard let notification = NotificationManager.shared.notification(from: notificationInfo) else { return }
        guard let bet = notification.bet else { return }
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 2.0) {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .PresentBetNotification,
                                                object: nil,
                                                userInfo: ["bet": bet])
            }
        }
    }
    // [END handle_remote_notification_app_launch]
}


// MARK: - UNUserNotificationDelegate

@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        NotificationManager.shared.handleRemoteNotification(userInfo)
        completionHandler(.alert)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        NotificationManager.shared.handleRemoteNotification(userInfo)
        completionHandler()
    }
    
}

