//
//  SceneDelegate.swift
//  KKR App
//
//  Created by Abhijeet Gawde on 20/12/22.
//

import UIKit
import AppTrackingTransparency
import FBSDKCoreKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        let splashStoryboard = UIStoryboard(name: "Splash", bundle: .main)
        guard let splashVC = splashStoryboard.instantiateViewController(withIdentifier: "SplashVC") as? SplashVC else {return}
        window.rootViewController = splashVC
        self.window = window
        window.makeKeyAndVisible()
        
        if let notificationResponse = connectionOptions.notificationResponse {
//            if KkrUserDefaultsManager.shared.getUserID() != nil {
                let root_splash_controller: SplashVC = .instantiateController(storyboard: .storyboard_splash)
                let notificationData = NotificationData(isFromNotification: true, notificationResponse: notificationResponse)
                root_splash_controller.notificationData = notificationData
                CommonUtilities.shared.setRootController(controller: root_splash_controller, storyboard: .storyboard_splash)
//            }
        } else if let userActivity = connectionOptions.userActivities.first {
            if let url = userActivity.webpageURL {
                _ = FirebaseDynamicLinkManager().handleUniversalLink(url: url)
            }
        } else if let urlContext = connectionOptions.urlContexts.first {
            _ = FirebaseDynamicLinkManager().handleUniversalLink(url: urlContext.url)
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        requestIDFA()
        
        // Reset Application Notification Badge Count
        if #available(iOS 16.0, *) {
            UNUserNotificationCenter.current().setBadgeCount(0, withCompletionHandler: nil)
        } else {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
    
    func requestIDFA() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                    // Tracking authorization completed. Start loading ads here.
                })
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            (UIApplication.shared.delegate as? AppDelegate)?.prepareForPushNotifications()
        }
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}

extension SceneDelegate {
    
    func promptToEnableNotifications() {
        if let lastOpenedDate = UserDefaults.standard.value(forKey: "LastOpenedDate") as? Date {
            let timeInterval: CGFloat = CGFloat(FirebaseModelConfig.sharedFirebaseConfig.appStaticText?.app_enable_notification_dialogue_time_interval ?? 72)
            if Date().timeIntervalSince1970 - lastOpenedDate.timeIntervalSince1970 < (timeInterval * 60 * 60) {
                return
            }
        }
        UserDefaults.standard.set(Date(), forKey: "LastOpenedDate")
        UserDefaults.standard.synchronize()
        let alertTitle = FirebaseModelConfig.sharedFirebaseConfig.appStaticText?.app_enable_notification_title ?? Bundle.main.infoDictionary?["CFBundleName"] as? String
        let alertMessage = FirebaseModelConfig.sharedFirebaseConfig.appStaticText?.app_enable_notification_message ??
        "This app doesn't have permissions for notifications. You would be missed important updates. Do you want to enable it now?"
        
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "YES", style: .destructive, handler: { _ in
            self.openDeviceAppSettingsPage()
        }))
        alertController.addAction(UIAlertAction(title: "NO", style: .cancel, handler: nil))
        DispatchQueue.main.async {
            self.window?.rootViewController?.present(alertController, animated: true)
        }
    }
    
    private func openDeviceAppSettingsPage() {
        DispatchQueue.main.async {
            if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                UIApplication.shared.open(appSettings)
            }
        }
    }
    
    func subscribeNotifications(isSubscribe: Bool) {
        if let deviceToken = KkrUserDefaultsManager.shared.getDeviceToken(), !deviceToken.isEmpty {
            DispatchQueue.main.async {
                KkrUserDefaultsManager.shared.setNotificationToggleSwitchValue(notificationSwitchValue: isSubscribe)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadMenuPage"), object: nil)
            }
        }
    }
}

// MARK: - Handle Universal Links
extension SceneDelegate {
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL else {
            return
        }
        _ = FirebaseDynamicLinkManager().handleUniversalLink(url: url)
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }
        
        ApplicationDelegate.shared.application(
            UIApplication.shared,
            open: url,
            sourceApplication: nil,
            annotation: [UIApplication.OpenURLOptionsKey.annotation]
        )
    }
}
