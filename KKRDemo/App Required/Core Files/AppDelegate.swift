//
//  AppDelegate.swift
//  KKR App
//
//  Created by Abhijeet Gawde on 20/12/22.
//

import UIKit
import IQKeyboardManagerSwift
import FirebaseCore
import FirebaseMessaging
import UserNotifications
import DropDown
import MoEngageSDK
import MoEngageAnalytics
import CometChatPro
import MoEngageMessaging
import FBSDKCoreKit
import FirebaseDynamicLinks

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var isAppInBackground = true
    var loginRedirection: LoginRedirectionType = .home
    var didInitialiseCometChat: Bool = false
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.initialSetup()
        
        // Facebook Setup
        FBSDKCoreKit.ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        
    }
}

// MARK: - FIREBASE
extension AppDelegate {
    fileprivate func initialSetup() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.resignOnTouchOutside = true
        IQKeyboardManager.shared.resignFirstResponder()
        
        DropDown.startListeningToKeyboard()
        CommonUtilities.shared.setBusterTimestampForFLRP(isChangeRequired: true)
        
        // Firebase Setup
        FirebaseApp.configure()
        
        // MoEngage Setup
        MoEngageManager.shared.initialiseMoEngageSDK()
        
        // Dynamic Links
        DynamicLinks.performDiagnostics(completion: nil)
        
        // UUID
        KkrUserDefaultsManager.shared.setDeviceToken(deviceToken: UIDevice.current.identifierForVendor?.uuidString ?? .blank)
    }
}

// MARK: - Notifications management
extension AppDelegate {
    
    func prepareForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { granted, _ in
            print("Permission granted:  \(granted)")
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                    if KkrUserDefaultsManager.shared.getNotificationToggleSwitchValue() == nil ||
                        KkrUserDefaultsManager.shared.getNotificationToggleSwitchValue() == false {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            let scene = UIApplication.shared.connectedScenes.first
                            if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
                                sd.subscribeNotifications(isSubscribe: true)
                            }
                        }
                    }
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    let scene = UIApplication.shared.connectedScenes.first
                    if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
                        if KkrUserDefaultsManager.shared.getNotificationToggleSwitchValue() == nil ||
                            KkrUserDefaultsManager.shared.getNotificationToggleSwitchValue() == true {
                            sd.subscribeNotifications(isSubscribe: false)
                        }
                        sd.promptToEnableNotifications()
                    }
                }
            }
        })
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let userDeviceToken = deviceToken.map({String(format: "%02.2hhx", $0)}).joined()
        KkrUserDefaultsManager.shared.setDeviceToken(deviceToken: userDeviceToken)
        print("User Device Token: \(userDeviceToken)")
        
        // MoEngage Config
        MoEngageManager.shared.setMoEngagePushToken(deviceToken: deviceToken)
        print("Device Token: \(deviceToken)")
        
#if DEBUG
        let token = Messaging.messaging().fcmToken
        print("Firebase registration token: \(token ?? .blank)")
#endif
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
        MoEngageManager.shared.didFailToRegisterForMoEngage()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Print full message.
        print(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    // Receive displayed notifications for iOS 10 devices.
    // This callback is received when notification is delivered when the application is in the foreground.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        guard let userInfo = notification.request.content.userInfo as? [String: Any] else { return }
        // Print full message.
        print(userInfo)
        
        // Received in Foreground
        // Change this to your preferred presentation option
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        print("\n Notification Body ----- \(response.notification.request.content.body)")
        print("\n Notification identifier ----- \(response.notification.request.identifier)")
        print("\n Notification userInfo ---- \(response.notification.request.content.userInfo)")
        
        switch UIApplication.shared.applicationState {
        case .active, .inactive:
            print("active/inactive mode")
        case .background:
            print("background mode")
        @unknown default:
            fatalError()
        }
        CommonUtilities.shared.handleNotificationResponse(response)
        
        MoEngageSDKMessaging.sharedInstance.userNotificationCenter(center, didReceive: response)
        completionHandler()
    }
}

// MARK: - Universal Links
extension AppDelegate {
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL else {
            return false
        }
        return FirebaseDynamicLinkManager().handleUniversalLink(url: url)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            guard let url = dynamicLink.url else {
                return false
            }
            _ = FirebaseDynamicLinkManager().handleUniversalLink(url: url)
            let urlString = url.absoluteString
            print("Dyanmic link url: \(urlString)")
            print("Dynamic link match type: \(dynamicLink.matchType.rawValue)")
            return true
        }
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
    }
}
