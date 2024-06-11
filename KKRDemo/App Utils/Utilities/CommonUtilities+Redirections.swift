////
////  CommonUtilities+Redirections.swift
////  KKR App
////
////  Created by Manann Sheth on 12/03/24.
////
//
//import UIKit
//import SafariServices
//
//// MARK: - Application Tabbar
//extension CommonUtilities {
//    func getAppRootTabbar() -> RootBaseTabbarController {
//        if let root_tabbar_controller = (UIApplication.shared.windows.first?.rootViewController as? RootBaseNavigationController)?.children[0] as? RootBaseTabbarController {
//            return root_tabbar_controller
//        }
//        let root_tabbar_controller: RootBaseTabbarController = .instantiateController(storyboard: .storyboard_base)
//        return root_tabbar_controller
//    }
//}
//
//// MARK: - Handle Login State
//extension CommonUtilities {
//    public func setLoginRedirection(loginRedirection: LoginRedirectionType) {
//        DispatchQueue.main.async {
//            (UIApplication.shared.delegate as? AppDelegate)?.loginRedirection = loginRedirection
//        }
//    }
//    
//    public func getLoginRedirection() -> LoginRedirectionType? {
//        return (UIApplication.shared.delegate as? AppDelegate)?.loginRedirection
//    }
//    
//    public func loginRedirection(tabbarRootVC: RootBaseTabbarController) {
//        if let loginRedirection = CommonUtilities.shared.getLoginRedirection() {
//            tabbarRootVC.loginRedirection = loginRedirection
//            switch loginRedirection {
//            case .home, .hallOfFans, .videoDetail, .newsDetail, .updatedNewsDetailsVC, .photoDetail, .story, .matchCenter, .profile, .profileWithReferralPopUp:
//                tabbarRootVC.selectedTabIndex = 0
//            case .fanClub:
//                tabbarRootVC.selectedTabIndex = 0
//            case .redeemKnightTokens:
//                tabbarRootVC.selectedTabIndex = 2
//            case.gaming :
//                tabbarRootVC.selectedTabIndex = 1
//            }
//            CommonUtilities.shared.setLoginRedirection(loginRedirection: .home)
//        }
//    }
//}
//
//// MARK: - Handle Notification Response
//extension CommonUtilities {
//    
//    func handleNotificationResponse(_ response: UNNotificationResponse?) {
//        if let userInfo = response?.notification.request.content.userInfo as? [String: Any] {
//            if let dataMoE = (userInfo["moengage"] as? [String: Any]) {
//                if let screenData = dataMoE["screenData"] as? [String: Any] {
//                    self.manageRedirectionScreens(screenData: screenData)
//                }
//            }
//        }
//    }
//    
//    func manageRedirectionScreens(screenData: [String : Any]) {
//        if let assetType = screenData[NotificationPayloadKeys.asset_type.name] as? String {
//            let assetUrl = screenData[NotificationPayloadKeys.asset_url.name] as? String
//            let assetTitle = screenData[NotificationPayloadKeys.asset_title.name] as? String
//            let assetAlias = screenData[NotificationPayloadKeys.asset_alias.name] as? String
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                let root_tabbar_controller = self.getAppRootTabbar()
////                let root_tabbar_controller: RootBaseTabbarController = .instantiateController(storyboard: .storyboard_base)
//                switch assetType {
//                case MoEngageNotificationAssetType.appLanding.assetID:
//                    NotificationCenter.default.post(name: .flrpMoEngageNotifiactionRedirectionInsertAction, object: nil)
//                    CommonUtilities.shared.setRootController(controller: root_tabbar_controller, storyboard: .storyboard_base)
//                    
//                case MoEngageNotificationAssetType.newsListing.assetID:
//                    NotificationCenter.default.post(name: .flrpMoEngageNotifiactionRedirectionInsertAction, object: nil)
//                    let newsListingVC: NewsListingVC = .instantiateController(storyboard: .storyboard_news)
//                    CommonUtilities.shared.setViewControllerForNotification(controllers: [root_tabbar_controller, newsListingVC])
//                    
//                case MoEngageNotificationAssetType.newsDetails.assetID:
//                    NotificationCenter.default.post(name: .flrpMoEngageNotifiactionRedirectionInsertAction, object: nil)
//                    
//                    if let alias = assetAlias {
//                        if ThemeManager.getCurrentTheme() == .KKR {
//                            let updatedNewsDetailsVC: UpdatedNewsDetailsVC = .instantiateController(storyboard: .storyboard_news)
//                            updatedNewsDetailsVC.viewModel.titleAlias = alias
//                            CommonUtilities.shared.setViewControllerForNotification(controllers: [root_tabbar_controller, updatedNewsDetailsVC])
//                        } else {
//                            let newsDetailVC: NewsDetailsVC = .instantiateController(storyboard: .storyboard_news)
//                            newsDetailVC.viewModel.titleAlias = alias
//                            CommonUtilities.shared.setViewControllerForNotification(controllers: [root_tabbar_controller, newsDetailVC])
//                        }
//                    }
//                    
//                case MoEngageNotificationAssetType.photoListing.assetID:
//                    NotificationCenter.default.post(name: .flrpMoEngageNotifiactionRedirectionInsertAction, object: nil)
//                    let photosListingVC: PhotosListingVC = .instantiateController(storyboard: .storyboard_photos)
//                    CommonUtilities.shared.setViewControllerForNotification(controllers: [root_tabbar_controller, photosListingVC])
//                    
//                case MoEngageNotificationAssetType.photoDetails.assetID:
//                    NotificationCenter.default.post(name: .flrpMoEngageNotifiactionRedirectionInsertAction, object: nil)
//                    let photoDetailVC: PhotosDetailVC = .instantiateController(storyboard: .storyboard_photos)
//                    if let alias = assetAlias {
//                        photoDetailVC.viewModel.titleAlias = alias
//                        CommonUtilities.shared.setViewControllerForNotification(controllers: [root_tabbar_controller, photoDetailVC])
//                    }
//                    
//                case MoEngageNotificationAssetType.videoListing.assetID:
//                    NotificationCenter.default.post(name: .flrpMoEngageNotifiactionRedirectionInsertAction, object: nil)
//                    let videosRootVC: VideosRootVC = .instantiateController(storyboard: .storyboard_videos)
//                    if ThemeManager.getCurrentTheme() == .KKR {
//                        videosRootVC.viewModel.showBackButton = true
//                    }
//                    CommonUtilities.shared.setViewControllerForNotification(controllers: [root_tabbar_controller, videosRootVC])
//                    
//                case MoEngageNotificationAssetType.videoDetails.assetID:
//                    NotificationCenter.default.post(name: .flrpMoEngageNotifiactionRedirectionInsertAction, object: nil)
//                    let videoDetailVC: VideosDetailVC = .instantiateController(storyboard: .storyboard_videos)
//                    if let alias = assetAlias {
//                        videoDetailVC.viewModel.titleAlias = alias
//                        CommonUtilities.shared.setViewControllerForNotification(controllers: [root_tabbar_controller, videoDetailVC])
//                    }
//                    
//                case MoEngageNotificationAssetType.matchCentre.assetID:
//                    NotificationCenter.default.post(name: .flrpMoEngageNotifiactionRedirectionInsertAction, object: nil)
//                    self.redirectMatchCentreWebview(screenData: screenData)
//                    
//                case MoEngageNotificationAssetType.gaming.assetID:
//                    if KkrUserDefaultsManager.shared.getUserID() != nil {
//                        NotificationCenter.default.post(name: .flrpMoEngageNotifiactionRedirectionInsertAction, object: nil)
//                        self.redirectAppWebview(screenData: screenData, isGaming: true)
//                    } else {
//                        CommonUtilities.shared.setLoginRedirection(loginRedirection: .home)
//                        if let vc = root_tabbar_controller.controllers.first as? RootBaseViewController {
//                            vc.showUserLogInPopupView()
//                        }
//                    }
//                    
//                case MoEngageNotificationAssetType.commonWebviews.assetID:
//                    NotificationCenter.default.post(name: .flrpMoEngageNotifiactionRedirectionInsertAction, object: nil)
//                    self.redirectAppWebview(screenData: screenData, isGaming: false)
//                    
//                case MoEngageNotificationAssetType.loyalty.assetID:
//                    NotificationCenter.default.post(name: .flrpMoEngageNotifiactionRedirectionInsertAction, object: nil)
//                    let loyaltyPageVC: LoyaltyPageVC = .instantiateController(storyboard: .storyboard_loyaltyPage)
//                    CommonUtilities.shared.setViewControllerForNotification(controllers: [root_tabbar_controller, loyaltyPageVC])
//                    break
//                    
//                case MoEngageNotificationAssetType.hallOfFans.assetID:
//                    NotificationCenter.default.post(name: .flrpMoEngageNotifiactionRedirectionInsertAction, object: nil)
//                    let isAcceptedTerms = KkrUserDefaultsManager.shared.getValue(forKey: .hallOfFansTermsnConditions) as? Bool
//                    if isAcceptedTerms ?? false {
//                        let fansRankingVC: FansRankingViewController = .instantiateController(storyboard: .storyboard_hallOfFans)
//                        CommonUtilities.shared.setViewControllerForNotification(controllers: [root_tabbar_controller, fansRankingVC])
//                    } else {
//                        let hallOfFansVC: HallOfFansViewController = .instantiateController(storyboard: .storyboard_hallOfFans)
//                        CommonUtilities.shared.setViewControllerForNotification(controllers: [root_tabbar_controller, hallOfFansVC])
//                    }
//                    break
//                    
//                case MoEngageNotificationAssetType.redeemTokens.assetID:
//                    NotificationCenter.default.post(name: .flrpMoEngageNotifiactionRedirectionInsertAction, object: nil)
//                    let redeemKnightTokensVC: RedeemKnightTokensVC = .instantiateController(storyboard: .storyboard_redeem_knight_tokens)
//                    CommonUtilities.shared.setViewControllerForNotification(controllers: [root_tabbar_controller, redeemKnightTokensVC])
//                    break
//                    
//                case MoEngageNotificationAssetType.clips.assetID:
//                    NotificationCenter.default.post(name: .flrpMoEngageNotifiactionRedirectionInsertAction, object: nil)
//                    CommonUtilities.shared.setRootController(controller: root_tabbar_controller, storyboard: .storyboard_base)
//                    
//                    if let views = root_tabbar_controller.viewControllers, views.count > 0 {
//                        var tabIndex = 0
//                        if let controllers = root_tabbar_controller.viewControllers {
//                            for (index, viewController) in controllers.enumerated() {
//                                if let reelsVC = viewController as? ReelsVC {
//                                    tabIndex = index
//                                    reelsVC.setForTabbarRoot = true
//                                    // reelsVC.viewModel.entityID = entityId ?? .blank
//                                    // reelsVC.viewModel.excludedEntityID = excludedEntityID ?? .blank
//                                    root_tabbar_controller.showMiddleButton = false
//                                    NotificationCenter.default.post(name: .middleBtnClickedNotification, object: nil, userInfo: ["toggleValue": false])
//                                    break
//                                }
//                            }
//                        }
//                        root_tabbar_controller.selectedIndex = tabIndex
//                    }
//                    break
//                    
//                case MoEngageNotificationAssetType.fanClub.assetID:
//                    NotificationCenter.default.post(name: .flrpMoEngageNotifiactionRedirectionInsertAction, object: nil)
//                    let fanClubRootVC: FanClubRootVC = .instantiateController(storyboard: .storyboard_fanclub)
//                    CommonUtilities.shared.setViewControllerForNotification(controllers: [root_tabbar_controller, fanClubRootVC])
//                    break
//                    
//                case FanClubNotificationAssetType.requestToJoin.assetID:
//                    // If admin/mod gets notification, has to go to accept/reject screen
//                    if let groupID = screenData[NotificationPayloadKeys.guid.name] as? String {
//                        self.launchCometChat(with: groupID) { group in
//                            NotificationCenter.default.post(name: .flrpMoEngageNotifiactionRedirectionInsertAction, object: nil)
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                                let addClubMemberVC: AddClubMemberVC = UIViewController.instantiateController(storyboard: .storyboard_fanclub)
//                                addClubMemberVC.set(group: group)
//                                CommonUtilities.shared.setViewControllerForNotification(controllers: [root_tabbar_controller, addClubMemberVC])
//                            }
//                        } onError: { error in
//                            print("Error: \(error?.errorDescription ?? .blank)")
//                        }
//                    }
//                    
//                case FanClubNotificationAssetType.acceptUser.assetID:
//                    // If user gets accept request, has to go chat screen
//                    if let groupID = screenData[NotificationPayloadKeys.guid.name] as? String {
//                        self.launchCometChat(with: groupID) { group in
//                            NotificationCenter.default.post(name: .flrpMoEngageNotifiactionRedirectionInsertAction, object: nil)
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                                let messageList = CometChatMessageList()
//                                messageList.isPinnedMessageList = false
//                                CommonUtilities.shared.setViewControllerForNotification(controllers: [root_tabbar_controller, messageList])
//                                messageList.set(conversationWith: group, type: .group)
//                            }
//                        } onError: { error in
//                            print("Error: \(error?.errorDescription ?? .blank)")
//                        }
//                    }
//                    
//                case FanClubNotificationAssetType.rejectUser.assetID:
//                    NotificationCenter.default.post(name: .flrpMoEngageNotifiactionRedirectionInsertAction, object: nil)
//                    // If user gets reject request, has to go fan club screen
//                    let fanClubRootVC: FanClubRootVC = .instantiateController(storyboard: .storyboard_fanclub)
//                    CommonUtilities.shared.setViewControllerForNotification(controllers: [root_tabbar_controller, fanClubRootVC])
//                    
//                case FanClubNotificationAssetType.mentioneUser.assetID:
//                    if let groupID = screenData[NotificationPayloadKeys.guid.name] as? String,
//                       let messageID = screenData[NotificationPayloadKeys.message_id.name] as? String {
//                        self.launchCometChat(with: groupID) { group in
//                            NotificationCenter.default.post(name: .flrpMoEngageNotifiactionRedirectionInsertAction, object: nil)
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                                let messageList = CometChatMessageList()
//                                messageList.isPinnedMessageList = false
//                                messageList.isMentionedMessageList = true
//                                messageList.messageID = messageID
//                                CommonUtilities.shared.setViewControllerForNotification(controllers: [root_tabbar_controller, messageList])
//                                messageList.set(conversationWith: group, type: .group)
//                            }
//                        } onError: { error in
//                            print("Error: \(error?.errorDescription ?? .blank)")
//                        }
//                    }
//                    
//                case FanClubNotificationAssetType.createPoll.assetID:
//                    if let groupID = screenData[NotificationPayloadKeys.guid.name] as? String,
//                       let messageID = screenData[NotificationPayloadKeys.message_id.name] as? String {
//                        self.launchCometChat(with: groupID) { group in
//                            NotificationCenter.default.post(name: .flrpMoEngageNotifiactionRedirectionInsertAction, object: nil)
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                                let messageList = CometChatMessageList()
//                                messageList.isPinnedMessageList = false
//                                messageList.isMentionedMessageList = true
//                                messageList.messageID = messageID
//                                CommonUtilities.shared.setViewControllerForNotification(controllers: [root_tabbar_controller, messageList])
//                                messageList.set(conversationWith: group, type: .group)
//                            }
//                        } onError: { error in
//                            print("Error: \(error?.errorDescription ?? .blank)")
//                        }
//                    }
//                case MoEngageNotificationAssetType.profile.assetID :
//                    if KkrUserDefaultsManager.shared.getUserID() != nil {
//                        NotificationCenter.default.post(name: .flrpMoEngageNotifiactionRedirectionInsertAction, object: nil)
//                        var profileVC: ProfileVC = .instantiateController(storyboard: .storyboard_profile)
//                        CommonUtilities.shared.setViewControllerForNotification(controllers: [root_tabbar_controller,profileVC])
//                    } else {
//                        CommonUtilities.shared.setLoginRedirection(loginRedirection: .home)
//                        var profileVC: ProfileVC = .instantiateController(storyboard: .storyboard_profile)
//                        if let vc = root_tabbar_controller.controllers.first as? RootBaseViewController {
//                            CommonUtilities.shared.setLoginRedirection(loginRedirection: .profileWithReferralPopUp(profileVC))
//                            vc.showUserLogInPopupView()
//                        }
//                    }
//                case MoEngageNotificationAssetType.profileWithRefferalPopup.assetID :
//                    if KkrUserDefaultsManager.shared.getUserID() != nil {
//                        NotificationCenter.default.post(name: .flrpMoEngageNotifiactionRedirectionInsertAction, object: nil)
//                        var profileVC: ProfileVC = .instantiateController(storyboard: .storyboard_profile)
//                        profileVC.displayReferralPopUp = true
//                        CommonUtilities.shared.setViewControllerForNotification(controllers: [root_tabbar_controller,profileVC])
//                    } else {
//                        CommonUtilities.shared.setLoginRedirection(loginRedirection: .home)
//                        if let vc = root_tabbar_controller.controllers.first as? RootBaseViewController {
//                            var profileVC: ProfileVC = .instantiateController(storyboard: .storyboard_profile)
//                            profileVC.displayReferralPopUp = true
//                            CommonUtilities.shared.setLoginRedirection(loginRedirection: .profileWithReferralPopUp(profileVC))
//                            vc.showUserLogInPopupView()
//                        }
//                    }
//                    
//                default:
//                    CommonUtilities.shared.setRootController(controller: root_tabbar_controller, storyboard: .storyboard_base)
//                    break
//                }
//            }
//        }
//    }
//    
//    fileprivate func redirectAppWebview(screenData: [String: Any], isGaming: Bool? = nil) {
//        let assetTitle = screenData[NotificationPayloadKeys.asset_title.name] as? String
//        let assetURL = screenData[NotificationPayloadKeys.asset_url.name] as? String
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            // let root_tabbar_controller: RootBaseTabbarController = .instantiateController(storyboard: .storyboard_base)
//            let root_tabbar_controller = self.getAppRootTabbar()
//            let commonWebViewVC: CommonWebViewVC = .instantiateController(storyboard: .storyboard_common)
//            commonWebViewVC.webviewTitle = assetTitle
//            commonWebViewVC.webViewUrl = assetURL
//            commonWebViewVC.isWebAuth = isGaming ?? false
//            CommonUtilities.shared.setViewControllerForNotification(controllers: [root_tabbar_controller, commonWebViewVC])
//        }
//    }
//    
//    fileprivate func redirectMatchCentreWebview(screenData: [String: Any]) {
//        let matchIdURL = screenData[NotificationPayloadKeys.asset_url.name] as? String ?? .blank
//        
//        var title = "Match Center"
//        if let homeTeamShortName = screenData[NotificationPayloadKeys.home_team_short_name.name] as? String,
//            !homeTeamShortName.isEmpty,
//            let awayTeamShortName = screenData[NotificationPayloadKeys.away_team_short_name.name] as? String,
//            !awayTeamShortName.isEmpty {
//            title = "\(homeTeamShortName) vs \(awayTeamShortName)"
//        }
//        
//        let homeTeamFullName = screenData[NotificationPayloadKeys.home_team_full_name.name] as? String ?? .blank
//        let awayTeamFullName = screenData[NotificationPayloadKeys.away_team_full_name.name] as? String ?? .blank
//        let participant1Name = (homeTeamFullName)
//            .replacingOccurrences(of: " ", with: "-")
//            .lowercased()
//        let participant2Name = (awayTeamFullName)
//            .replacingOccurrences(of: " ", with: "-")
//            .lowercased()
//        let matchCentreWebviewURL = (FirebaseModelConfig.sharedFirebaseConfig.appTypePath?[ThemeManager.getCurrentTheme().name]?.teamTypeSchedulrFixture ?? .blank)
//            .replacingOccurrences(of: SIParameterKeys.team1.keyName, with: participant1Name.lowercased())
//            .replacingOccurrences(of: SIParameterKeys.team2.keyName, with: participant2Name.lowercased())
//            .replacingOccurrences(of: SIParameterKeys.gameId.keyName, with: matchIdURL.lowercased())
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            // let root_tabbar_controller: RootBaseTabbarController = .instantiateController(storyboard: .storyboard_base)
//            let root_tabbar_controller = self.getAppRootTabbar()
//            let commonWebVC: CommonWebViewVC = .instantiateController(storyboard: .storyboard_common)
//            commonWebVC.webviewTitle = title
//            commonWebVC.webViewUrl = matchCentreWebviewURL
//            CommonUtilities.shared.setViewControllerForNotification(controllers: [root_tabbar_controller, commonWebVC])
//        }
//    }
//}
//
//// MARK: - Handle Deeplink Response
//extension CommonUtilities {
//    
//    func manageDeeplinkingRedirection(_ url: URL?) {
//        guard let url = url else { return }
//        let pathComponents = url.pathComponents.filter({ $0 != "/" })
//        var queryParameters: [String: String] = [:]
//        if let query = url.queryParameters {
//            queryParameters = query
//        }
//        if pathComponents.isEmpty {
//            print("Path not found")
//            return
//        }
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            // let root_tabbar_controller: RootBaseTabbarController = .instantiateController(storyboard: .storyboard_base)
//            let root_tabbar_controller = self.getAppRootTabbar()
//            if pathComponents.count == 1 {
//                // listing page || webviews
//                if let isExternalWebView = queryParameters["is_external_webview"], isExternalWebView == "true" {
//                    self.openExternalWebviewFromDeepLink(url.absoluteString)
//                } else if let isWebView = queryParameters["webview"], isWebView == "true" {
//                    // webviews
//                    if let isLogin = queryParameters["login"], isLogin == "true" {
//                        // webview with login
//                        self.openWebViewFromDeepLink(url.absoluteString, isAuthRequired: true)
//                    } else {
//                        // webview without login
//                        self.openWebViewFromDeepLink(url.absoluteString, isAuthRequired: false)
//                    }
//                } else {
//                    // listing page
//                    if let path = pathComponents.first?.lowercased(), path == "news" {
//                        let newsListingVC: NewsListingVC = .instantiateController(storyboard: .storyboard_news)
//                        CommonUtilities.shared.setViewControllerForNotification(controllers: [root_tabbar_controller, newsListingVC])
//                    } else if let path = pathComponents.first?.lowercased(), path == "videos" {
//                        let videosRootVC: VideosRootVC = .instantiateController(storyboard: .storyboard_videos)
//                        videosRootVC.viewModel.showBackButton = true
//                        CommonUtilities.shared.setViewControllerForNotification(controllers: [root_tabbar_controller, videosRootVC])
//                    } else if let path = pathComponents.first?.lowercased(), path == "podcast" {
//                        let videosRootVC: VideosRootVC = .instantiateController(storyboard: .storyboard_videos)
//                        videosRootVC.viewModel.showBackButton = true
//                        CommonUtilities.shared.setViewControllerForNotification(controllers: [root_tabbar_controller, videosRootVC])
//                    } else if let path = pathComponents.first?.lowercased(), path == "photos" {
//                        let photosListingVC: PhotosListingVC = .instantiateController(storyboard: .storyboard_photos)
//                        CommonUtilities.shared.setViewControllerForNotification(controllers: [root_tabbar_controller, photosListingVC])
//                    } else if let path = pathComponents.first?.lowercased(), path == "clips" {
//                        var tabIndex = 0
//                        if let controllers = root_tabbar_controller.viewControllers {
//                            for (index, viewController) in controllers.enumerated() {
//                                if let reelsVC = viewController as? ReelsVC {
//                                    tabIndex = index
//                                    reelsVC.setForTabbarRoot = true
//                                    root_tabbar_controller.showMiddleButton = false
//                                    NotificationCenter.default.post(name: .middleBtnClickedNotification, object: nil, userInfo: ["toggleValue": false])
//                                    break
//                                }
//                            }
//                        }
//                        root_tabbar_controller.selectedIndex = tabIndex
//                    } else {
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                            CommonUtilities.shared.setRootController(controller: root_tabbar_controller, storyboard: .storyboard_base)
//                        }
//                    }
//                }
//            } else if pathComponents.count > 1 {
//                // reels, video, news & photo details page || webviews
//                if let path = pathComponents.first?.lowercased(),
//                    path == "videos" || path == "podcast", let alias = pathComponents.last {
//                    // In case of Reels
//                    if queryParameters["clips"] == "1" {
//                        var sharingParams = queryParameters
//                        sharingParams["asset_slug"] = alias
//                        
//                        var tabIndex = 0
//                        if let controllers = root_tabbar_controller.viewControllers {
//                            for (index, viewController) in controllers.enumerated() {
//                                if let reelsVC = viewController as? ReelsVC {
//                                    tabIndex = index
//                                    reelsVC.setForTabbarRoot = true
//                                    reelsVC.isOpenFromShareLink = true
//                                    reelsVC.shareParams = sharingParams
//                                    // reelsVC.viewModel.title = bannerInfoData.titleAlias
//                                    // reelsVC.viewModel.entityID = entityId ?? .blank
//                                    // reelsVC.viewModel.excludedEntityID = excludedEntities ?? .blank
//                                    
//                                    root_tabbar_controller.showMiddleButton = false
//                                    NotificationCenter.default.post(name: .middleBtnClickedNotification, object: nil, userInfo: ["toggleValue": false])
//                                    break
//                                }
//                            }
//                        }
//                        root_tabbar_controller.selectedIndex = tabIndex
//                    } else {
//                        let videoDetailVC: VideosDetailVC = .instantiateController(storyboard: .storyboard_videos)
//                        videoDetailVC.viewModel.titleAlias = alias
//                        CommonUtilities.shared.setViewControllerForNotification(controllers: [root_tabbar_controller, videoDetailVC])
//                    }
//                } else if let path = pathComponents.first?.lowercased(),
//                            path == "news", let alias = pathComponents.last {
//                    if ThemeManager.getCurrentTheme() == .KKR {
//                        let updatedNewsDetailsVC: UpdatedNewsDetailsVC = .instantiateController(storyboard: .storyboard_news)
//                        updatedNewsDetailsVC.viewModel.titleAlias = alias
//                        CommonUtilities.shared.setViewControllerForNotification(controllers: [root_tabbar_controller, updatedNewsDetailsVC])
//                    } else {
//                        let newsDetailVC: NewsDetailsVC = .instantiateController(storyboard: .storyboard_news)
//                        newsDetailVC.viewModel.titleAlias = alias
//                        CommonUtilities.shared.setViewControllerForNotification(controllers: [root_tabbar_controller, newsDetailVC])
//                    }
//                } else if let path = pathComponents.first?.lowercased(),
//                            path == "photos", let alias = pathComponents.last {
//                    let photoDetailVC: PhotosDetailVC = .instantiateController(storyboard: .storyboard_photos)
//                    photoDetailVC.viewModel.titleAlias = alias
//                    CommonUtilities.shared.setViewControllerForNotification(controllers: [root_tabbar_controller, photoDetailVC])
//                } else if let path = pathComponents.first?.lowercased(),
//                            path == "live-scores", let alias = pathComponents.last {
//                    self.openMatchCentreWebviewFromDeepLink(matchCentreWebviewURL: alias, title: "Match Centre")
//                } else if let isExternalWebView = queryParameters["is_external_webview"],
//                            isExternalWebView == "true" {
//                    self.openExternalWebviewFromDeepLink(url.absoluteString)
//                } else if let isWebView = queryParameters["webview"], isWebView == "true" {
//                    // webviews
//                    if let isLogin = queryParameters["login"], isLogin == "true" {
//                        // webview with login
//                        self.openWebViewFromDeepLink(url.absoluteString, isAuthRequired: true)
//                    } else {
//                        // webview without login
//                        self.openWebViewFromDeepLink(url.absoluteString, isAuthRequired: false)
//                    }
//                }
//            } else {
//                // Home page
//                let root_tabbar_controller: RootBaseTabbarController = .instantiateController(storyboard: .storyboard_base)
//                root_tabbar_controller.selectedTabIndex = 0
//                CommonUtilities.shared.setRootController(controller: root_tabbar_controller, storyboard: .storyboard_base)
//            }
//        }
//    }
//    
//    fileprivate func openWebViewFromDeepLink(_ webURL: String?, isAuthRequired: Bool) {
//        var assetTitle: String?
//        if let assetURL = webURL,
//           let url = URL(string: assetURL),
//           let params = url.queryParameters,
//           let title = params["display_title"] {
//            assetTitle = title.replacingOccurrences(of: "_", with: " ").uppercased()
//            
//            // let root_tabbar_controller: RootBaseTabbarController = .instantiateController(storyboard: .storyboard_base)
//            let root_tabbar_controller = self.getAppRootTabbar()
//            var isAuthUser = false
//            if isAuthRequired {
//                if KkrUserDefaultsManager.shared.getUserID() != nil {
//                    isAuthUser = true
//                }
//            } else {
//                isAuthUser = true
//            }
//            
//            if isAuthUser {
//                let commonWebViewVC: CommonWebViewVC = .instantiateController(storyboard: .storyboard_common)
//                commonWebViewVC.webviewTitle = assetTitle
//                commonWebViewVC.webViewUrl = assetURL
//                commonWebViewVC.isWebAuth = isAuthRequired
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                    self.setViewControllerForNotification(controllers: [root_tabbar_controller, commonWebViewVC])
//                }
//            } else {
//                self.setLoginRedirection(loginRedirection: .home)
//                if let vc = root_tabbar_controller.controllers.first as? RootBaseViewController {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                        vc.showUserLogInPopupView()
//                    }
//                }
//            }
//        }
//    }
//    
//    fileprivate func openExternalWebviewFromDeepLink(_ webURL: String?) {
//        // let root_tabbar_controller: RootBaseTabbarController = .instantiateController(storyboard: .storyboard_base)
//        let root_tabbar_controller = self.getAppRootTabbar()
//        if let url = URL(string: webURL ?? .blank) {
//            let safariVC = SFSafariViewController(url: url)
//            safariVC.preferredBarTintColor = .getAppColor(colorName: .purple_340D53)
//            self.setViewControllerForNotification(controllers: [root_tabbar_controller])
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                root_tabbar_controller.present(safariVC, animated: true)
//            }
//        }
//    }
//    
//    fileprivate func openMatchCentreWebviewFromDeepLink(matchCentreWebviewURL: String, title: String) {
//        // let root_tabbar_controller: RootBaseTabbarController = .instantiateController(storyboard: .storyboard_base)
//        let root_tabbar_controller = self.getAppRootTabbar()
//        let commonWebVC: CommonWebViewVC = .instantiateController(storyboard: .storyboard_common)
//        commonWebVC.webviewTitle = title
//        commonWebVC.webViewUrl = matchCentreWebviewURL
//        CommonUtilities.shared.setViewControllerForNotification(controllers: [root_tabbar_controller, commonWebVC])
//    }
//}
//
//// MARK: - Handle Banner Redirection Response
//extension CommonUtilities {
//    func manageRedirectionFromBannerCarouselInfo(dataController: RootBaseViewController?, bannerInfoData: BannerCarouselInfo?) {
//        guard let bannerInfoData = bannerInfoData else { return }
//        
//        if let loginRequired = bannerInfoData.loginRequired, loginRequired {
//            if KkrUserDefaultsManager.shared.getUserID() == nil {
//                CommonUtilities.shared.setLoginRedirection(loginRedirection: .home)
//                dataController?.showUserLogInPopupView()
//                return
//            }
//        }
//        
//        var entityId: String? = .blank
//        var excludedEntities: String? = .blank
//        
//        if let requiredEntities = bannerInfoData.requiredEntities {
//            entityId = requiredEntities.map({String($0)}).joined(separator: ",")
//        }
//        if let excludedEntityID = bannerInfoData.excludeEntities {
//            excludedEntities = excludedEntityID.map({String($0)}).joined(separator: ",")
//        }
//        
//        let bannerType = BannerRedirectionType(rawValue: bannerInfoData.bannerType ?? .blank)
//        switch bannerType {
//        case .home:
//            let homeRootVC: HomeRootVC = .instantiateController(storyboard: .storyboard_home)
//            dataController?.navigationController?.pushViewController(homeRootVC, animated: true)
//            
//        case .videos:
//            let videosRootVC: VideosRootVC = .instantiateController(storyboard: .storyboard_videos)
//            dataController?.navigationController?.pushViewController(videosRootVC, animated: true)
//            
//        case .videos_subpage:
//            let videosListingVC: VideosListingVC = .instantiateController(storyboard: .storyboard_videos)
//            videosListingVC.viewModel.entityID = entityId ?? .blank
//            videosListingVC.viewModel.title = bannerInfoData.titleAlias ?? .blank
//            videosListingVC.viewModel.excludedEntityID = excludedEntities ?? .blank
//            dataController?.navigationController?.pushViewController(videosListingVC, animated: true)
//            
//        case .video_details:
//            let videosDetailVC: VideosDetailVC = .instantiateController(storyboard: .storyboard_videos)
//            videosDetailVC.viewModel.titleAlias = bannerInfoData.titleAlias ?? .blank
//            dataController?.navigationController?.pushViewController(videosDetailVC, animated: true)
//            
//        case .clips:
//            if let rootNavController = dataController?.navigationController as? RootBaseNavigationController {
//                if let rootTab = rootNavController.children[0] as? RootBaseTabbarController {
//                    var tabIndex = 0
//                    if let controllers = rootTab.viewControllers {
//                        for (index, viewController) in controllers.enumerated() {
//                            if let reelsVC = viewController as? ReelsVC {
//                                tabIndex = index
//                                reelsVC.setForTabbarRoot = true
//                                // reelsVC.viewModel.entityID = entityId ?? .blank
//                                // reelsVC.viewModel.excludedEntityID = excludedEntities ?? .blank
//                                
//                                rootTab.showMiddleButton = false
//                                NotificationCenter.default.post(name: .middleBtnClickedNotification, object: nil, userInfo: ["toggleValue": false])
//                                break
//                            }
//                        }
//                    }
//                    rootTab.selectedIndex = tabIndex
//                }
//            }
//            break
//            
//        case .photos:
//            let photosListingVC: PhotosListingVC = .instantiateController(storyboard: .storyboard_photos)
//            dataController?.navigationController?.pushViewController(photosListingVC, animated: true)
//            
//        case .photos_subpage:
//            let photosListingVC: PhotosListingVC = .instantiateController(storyboard: .storyboard_photos)
//            photosListingVC.viewModel.entityID = entityId ?? .blank
//            photosListingVC.viewModel.title = bannerInfoData.titleAlias ?? .blank
//            photosListingVC.viewModel.excludedEntityID = excludedEntities ?? .blank
//            dataController?.navigationController?.pushViewController(photosListingVC, animated: true)
//            
//        case .photodetail:
//            let photosDetailVC: PhotosDetailVC = .instantiateController(storyboard: .storyboard_photos)
//            photosDetailVC.viewModel.titleAlias = bannerInfoData.titleAlias ?? .blank
//            dataController?.navigationController?.pushViewController(photosDetailVC, animated: true)
//            
//        case .news:
//            let newsListingVC: NewsListingVC = .instantiateController(storyboard: .storyboard_news)
//            dataController?.navigationController?.pushViewController(newsListingVC, animated: true)
//            
//        case .news_subpage:
//            let newsListingLatestArticlesVC: NewsListingLatestArticlesVC = .instantiateController(storyboard: .storyboard_news)
//            newsListingLatestArticlesVC.viewModel.entityId = entityId ?? .blank
//            newsListingLatestArticlesVC.viewModel.title = bannerInfoData.titleAlias ?? .blank
//            newsListingLatestArticlesVC.viewModel.excludeEntityId = excludedEntities ?? .blank
//            dataController?.navigationController?.pushViewController(newsListingLatestArticlesVC, animated: true)
//            
//        case .news_detail:
//            let updatedNewsDetailsVC: UpdatedNewsDetailsVC = .instantiateController(storyboard: .storyboard_news)
//            updatedNewsDetailsVC.viewModel.titleAlias = bannerInfoData.titleAlias
//            dataController?.navigationController?.pushViewController(updatedNewsDetailsVC, animated: true)
//            
//        case .press_release:
//            let updatedNewsDetailsVC: UpdatedNewsDetailsVC = .instantiateController(storyboard: .storyboard_news)
//            //updatedNewsDetailsVC.viewModel.isPressRelease = true
//            //updatedNewsDetailsVC.cellType = .pressRelease
//            dataController?.navigationController?.pushViewController(updatedNewsDetailsVC, animated: true)
//            
//        case .press_release_detail:
//            let updatedNewsDetailsVC: UpdatedNewsDetailsVC = .instantiateController(storyboard: .storyboard_news)
//            dataController?.navigationController?.pushViewController(updatedNewsDetailsVC, animated: true)
//            
//        case .fan_chat:
//            let fanClubRootVC: FanClubRootVC = .instantiateController(storyboard: .storyboard_fanclub)
//            dataController?.navigationController?.pushViewController(fanClubRootVC, animated: true)
//            
//        case .loyalty:
//            let loyaltyPageVC: LoyaltyPageVC = .instantiateController(storyboard: .storyboard_loyalty)
//            dataController?.navigationController?.pushViewController(loyaltyPageVC, animated: true)
//            
//        case .redeem_knight_tokens:
//            let redeemKnightTokensVC: RedeemKnightTokensVC = .instantiateController(storyboard: .storyboard_redeem_knight_tokens)
//            dataController?.navigationController?.pushViewController(redeemKnightTokensVC, animated: true)
//            
//        case .gaming_hub:
//            let gamingViewController: GamingViewController = .instantiateController(storyboard: .storyboard_gaming)
//            dataController?.navigationController?.pushViewController(gamingViewController, animated: true)
//            
//        case .profile:
//            let profileVC: ProfileVC = .instantiateController(storyboard: .storyboard_profile)
//            dataController?.navigationController?.pushViewController(profileVC, animated: true)
//           
//        case .search:
//            let commonSearchVC: SearchRootVC = .instantiateController(storyboard: .storyboard_search)
//            dataController?.navigationController?.pushViewController(commonSearchVC, animated: true)
//            
//        case .notifications:
//            let notificationsViewController: NotificationsViewController = .instantiateController(storyboard: .storyboard_home)
//            notificationsViewController.viewModel = NotificationsVM(notificationsResponse: notificationsViewController.rootViewModel.flrpNotificationsResponse)
//            dataController?.navigationController?.pushViewController(notificationsViewController, animated: true)
//            
//        case .badges:
//            let badgesViewController: BadgesViewController = .instantiateController(storyboard: .storyboard_profile)
//            badgesViewController.userCurrentLevel = badgesViewController.rootViewModel.flpGetProfileResponse?.data?.levelNo ?? 1
//            dataController?.navigationController?.pushViewController(badgesViewController, animated: true)
//            
//        case .ledger:
//            let myLedgerViewController: MyLedgerViewController = .instantiateController(storyboard: .storyboard_profile)
//            dataController?.navigationController?.pushViewController(myLedgerViewController, animated: true)
//
//        case .edit_profile:
//            let editProfileVC: EditProfileVC = .instantiateController(storyboard: .storyboard_profile)
//            dataController?.navigationController?.pushViewController(editProfileVC, animated: true)
//            
//        case .webview:
//            if let isGaming = bannerInfoData.isGaming, isGaming {
//                let eventAttrDict : [String: Any] = ["game_name" : bannerInfoData.displayTitle ?? .blank]
//                CommonUtilities.shared.setBusterTimestampForFLRP(isChangeRequired: true)
//                MoEngageManager.shared.trackMoEngageEvent(event: Events.clicked_game.name, eventAttribute: eventAttrDict)
//                let lastSyncTime = CommonUtilities.shared.lastSyncTimestamp
//                let commonWebViewVC: CommonWebViewVC = .instantiateController(storyboard: .storyboard_common)
//                commonWebViewVC.webViewUrl = "\(bannerInfoData.webviewURL ?? .blank)&platform_type=3&v=\(lastSyncTime)"
//                
//                commonWebViewVC.webviewTitle = bannerInfoData.displayTitle ?? .blank
//                commonWebViewVC.isWebAuth = true
//                commonWebViewVC.isGaming = true
//                commonWebViewVC.infoKeyURL = bannerInfoData.infoUrl ?? .blank
//                dataController?.navigationController?.pushViewController(commonWebViewVC, animated: true)
//            } else {
//                if bannerInfoData.isExternalWebview ?? false {
//                    guard let webviewUrl = URL(string: bannerInfoData.webviewURL ?? .blank) else {return}
//                    UIApplication.shared.open(webviewUrl)
//                } else {
//                    let commonWebViewVC: CommonWebViewVC = .instantiateController(storyboard: .storyboard_common)
//                    commonWebViewVC.webViewUrl = bannerInfoData.webviewURL ?? .blank
//                    commonWebViewVC.webviewTitle = bannerInfoData.displayTitle
//                    dataController?.navigationController?.pushViewController(commonWebViewVC, animated: true)
//                }
//            }
//        default:
//            let homeRootVC: HomeRootVC = .instantiateController(storyboard: .storyboard_home)
//            dataController?.navigationController?.pushViewController(homeRootVC, animated: true)
//        }
//    }
//    
//    func manageRedirectionFromBanner(dataController: RootBaseViewController?,
//                                     bannerType: String?,
//                                     entityId: String?,
//                                     title: String?,
//                                     excludedEntityID: String?) {
//        let bannerType = BannerRedirectionType(rawValue: bannerType ?? .blank)
//        switch bannerType {
//        case .home:
//            let homeRootVC: HomeRootVC = .instantiateController(storyboard: .storyboard_home)
//            dataController?.navigationController?.pushViewController(homeRootVC, animated: true)
//            
//        case .videos:
//            let videosRootVC: VideosRootVC = .instantiateController(storyboard: .storyboard_videos)
//            dataController?.navigationController?.pushViewController(videosRootVC, animated: true)
//            
//        case .videos_subpage:
//            let videosListingVC: VideosListingVC = .instantiateController(storyboard: .storyboard_videos)
//            videosListingVC.viewModel.entityID = entityId ?? .blank
//            videosListingVC.viewModel.title = title ?? .blank
//            videosListingVC.viewModel.excludedEntityID = excludedEntityID ?? .blank
//            dataController?.navigationController?.pushViewController(videosListingVC, animated: true)
//            
//        case .video_details:
//            let videosDetailVC: VideosDetailVC = .instantiateController(storyboard: .storyboard_videos)
//            videosDetailVC.viewModel.titleAlias = title
//            dataController?.navigationController?.pushViewController(videosDetailVC, animated: true)
//            
//        case .clips:
//            if let rootNavController = dataController?.navigationController as? RootBaseNavigationController {
//                rootNavController.popToRootViewController(animated: false)
//                if let rootTab = rootNavController.children[0] as? RootBaseTabbarController {
//                    var tabIndex = 0
//                    if let controllers = rootTab.viewControllers {
//                        for (index, viewController) in controllers.enumerated() {
//                            if let reelsVC = viewController as? ReelsVC {
//                                tabIndex = index
//                                reelsVC.setForTabbarRoot = true
//                                // reelsVC.viewModel.entityID = entityId ?? .blank
//                                // reelsVC.viewModel.excludedEntityID = excludedEntityID ?? .blank
//                                
//                                rootTab.showMiddleButton = false
//                                NotificationCenter.default.post(name: .middleBtnClickedNotification, object: nil, userInfo: ["toggleValue": false])
//                                break
//                            }
//                        }
//                    }
//                    rootTab.selectedIndex = tabIndex
//                }
//            }
//            
//        case .photos:
//            let photosListingVC: PhotosListingVC = .instantiateController(storyboard: .storyboard_photos)
//            dataController?.navigationController?.pushViewController(photosListingVC, animated: true)
//            
//        case .photos_subpage:
//            let photosListingVC: PhotosListingVC = .instantiateController(storyboard: .storyboard_photos)
//            photosListingVC.viewModel.entityID = entityId ?? .blank
//            photosListingVC.viewModel.title = title ?? .blank
//            photosListingVC.viewModel.excludedEntityID = excludedEntityID ?? .blank
//            dataController?.navigationController?.pushViewController(photosListingVC, animated: true)
//            
//        case .photodetail:
//            let photosDetailVC: PhotosDetailVC = .instantiateController(storyboard: .storyboard_photos)
//            photosDetailVC.viewModel.titleAlias = title
//            dataController?.navigationController?.pushViewController(photosDetailVC, animated: true)
//            
//        case .news:
//            let newsListingVC: NewsListingVC = .instantiateController(storyboard: .storyboard_news)
//            dataController?.navigationController?.pushViewController(newsListingVC, animated: true)
//            
//        case .news_subpage:
//            let newsListingLatestArticlesVC: NewsListingLatestArticlesVC = .instantiateController(storyboard: .storyboard_news)
//            newsListingLatestArticlesVC.viewModel.entityId = entityId ?? .blank
//            newsListingLatestArticlesVC.viewModel.title = title ?? .blank
//            newsListingLatestArticlesVC.viewModel.excludeEntityId = excludedEntityID ?? .blank
//            dataController?.navigationController?.pushViewController(newsListingLatestArticlesVC, animated: true)
//            
//        case .news_detail:
//            let updatedNewsDetailsVC: UpdatedNewsDetailsVC = .instantiateController(storyboard: .storyboard_news)
//            updatedNewsDetailsVC.viewModel.titleAlias = title
//            dataController?.navigationController?.pushViewController(updatedNewsDetailsVC, animated: true)
//            
//        case .press_release:
//            let updatedNewsDetailsVC: UpdatedNewsDetailsVC = .instantiateController(storyboard: .storyboard_news)
//            //updatedNewsDetailsVC.viewModel.isPressRelease = true
//            //updatedNewsDetailsVC.cellType = .pressRelease
//            dataController?.navigationController?.pushViewController(updatedNewsDetailsVC, animated: true)
//            
//        case .press_release_detail:
//            let updatedNewsDetailsVC: UpdatedNewsDetailsVC = .instantiateController(storyboard: .storyboard_news)
//            dataController?.navigationController?.pushViewController(updatedNewsDetailsVC, animated: true)
//            
//        case .fan_chat:
//            let fanClubRootVC: FanClubRootVC = .instantiateController(storyboard: .storyboard_fanclub)
//            dataController?.navigationController?.pushViewController(fanClubRootVC, animated: true)
//            
//        case .loyalty:
//            let loyaltyPageVC: LoyaltyPageVC = .instantiateController(storyboard: .storyboard_loyalty)
//            dataController?.navigationController?.pushViewController(loyaltyPageVC, animated: true)
//            
//        case .redeem_knight_tokens:
//            let redeemKnightTokensVC: RedeemKnightTokensVC = .instantiateController(storyboard: .storyboard_redeem_knight_tokens)
//            dataController?.navigationController?.pushViewController(redeemKnightTokensVC, animated: true)
//            
//        case .gaming_hub:
//            let gamingViewController: GamingViewController = .instantiateController(storyboard: .storyboard_gaming)
//            dataController?.navigationController?.pushViewController(gamingViewController, animated: true)
//            
//        case .profile:
//            let profileVC: ProfileVC = .instantiateController(storyboard: .storyboard_profile)
//            dataController?.navigationController?.pushViewController(profileVC, animated: true)
//            
//        case .search:
//            let commonSearchVC: SearchRootVC = .instantiateController(storyboard: .storyboard_search)
//            dataController?.navigationController?.pushViewController(commonSearchVC, animated: true)
//            
//        case .notifications:
//            let notificationsViewController: NotificationsViewController = .instantiateController(storyboard: .storyboard_home)
//            notificationsViewController.viewModel = NotificationsVM(notificationsResponse: notificationsViewController.rootViewModel.flrpNotificationsResponse)
//            dataController?.navigationController?.pushViewController(notificationsViewController, animated: true)
//            
//        case .badges:
//            let badgesViewController: BadgesViewController = .instantiateController(storyboard: .storyboard_profile)
//            badgesViewController.userCurrentLevel = badgesViewController.rootViewModel.flpGetProfileResponse?.data?.levelNo ?? 1
//            dataController?.navigationController?.pushViewController(badgesViewController, animated: true)
//            
//        case .ledger:
//            let myLedgerViewController: MyLedgerViewController = .instantiateController(storyboard: .storyboard_profile)
//            dataController?.navigationController?.pushViewController(myLedgerViewController, animated: true)
//            
//        case .edit_profile:
//            let editProfileVC: EditProfileVC = .instantiateController(storyboard: .storyboard_profile)
//            dataController?.navigationController?.pushViewController(editProfileVC, animated: true)
//            
//        case .webview:
//            let commonWebViewVC: CommonWebViewVC = .instantiateController(storyboard: .storyboard_common)
//            dataController?.navigationController?.pushViewController(commonWebViewVC, animated: true)
//            
//        default:
//            let homeRootVC: HomeRootVC = .instantiateController(storyboard: .storyboard_home)
//            dataController?.navigationController?.pushViewController(homeRootVC, animated: true)
//        }
//    }
//}
//
//// MARK: - Generate Sharing URLs
//extension CommonUtilities {
//    func generateSharingURL(entityCategory: String,
//                            titleAlias: String,
//                            primaryRoleMapID: Int = 0,
//                            isClips: Bool? = nil,
//                            contentAssetType: Int? = 0,
//                            contentAssetId: String? = nil) -> String {
//        var baseUrl: String = FirebaseModelConfig.sharedFirebaseConfig.baseUrl ?? .blank
//        let contentSharingDetail = FirebaseModelConfig.sharedFirebaseConfig.contentSharingDetails
//        
//        if let matchedContentSharingDetail = contentSharingDetail?.sharingItems?.last(where: {$0.id == primaryRoleMapID}) {
//            baseUrl = matchedContentSharingDetail.domainValue ?? .blank
//        } else if let defaultSharingDomainId = contentSharingDetail?.sharingItems?.last(where: {$0.id == 0}) {
//            baseUrl = defaultSharingDomainId.domainValue ?? .blank
//        }
//        
//        var generatedSharing = baseUrl + (FirebaseModelConfig.sharedFirebaseConfig.contentSharingUrl ?? .blank)
//        generatedSharing = generatedSharing.replacingOccurrences(of: SIParameterKeys.entity_category.keyName, with: entityCategory)
//            .replacingOccurrences(of: SIParameterKeys.title_alias.keyName, with: titleAlias)
//        
//        if let clips = isClips, clips {
//            generatedSharing = generatedSharing.appending("&clips=1")
//            if let assetType = contentAssetType, assetType > 0,
//               let assetId = contentAssetId, !assetId.isEmpty {
//                generatedSharing = generatedSharing.appending("&asset_type=\(assetType)")
//                generatedSharing = generatedSharing.appending("&asset_id=\(assetId)")
//                generatedSharing = generatedSharing.appending("&slug=\(titleAlias)")
//            }
//        }
//        print("sharingLink : \(generatedSharing)")
//        return generatedSharing
//    }
//}
