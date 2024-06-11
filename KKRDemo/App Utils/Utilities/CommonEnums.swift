//
//  CommonEnums.swift
//  KKR App
//
//  Created by Ajinkya Sonar on 02/01/23.
//

import UIKit

enum StoryboardNames: String {
    case storyboard_base = "Base"
    case storyboard_splash = "Splash"
    case storyboard_login = "Login"
    case storyboard_home = "Home"
    case storyboard_fanclub = "Fanclub"
    case storyboard_loyalty = "Loyalty"
    case storyboard_news = "News"
    case storyboard_photos = "Photos"
    case storyboard_videos = "Videos"
    case storyboard_more = "More"
    case storyboard_fixtures = "Fixtures"
    case storyboard_standings = "Standings"
    case storyboard_shop = "Shop"
    case storyboard_squad = "Squad"
    case storyboard_profile = "Profile"
    case storyboard_common = "Common"
    case storyboard_stories = "Stories"
    case storyboard_search = "Search"
    case storyboard_hallOfFans = "HallOfFans"
    case storyboard_redeem_knight_tokens = "RedeemKnightTokens"
    case storyboard_gaming = "Gaming"
    case storyboard_loyaltyPage = "LoyaltyPage"
    case storyboard_brightCovePlayer = "BrightCovePlayer"
    case storyboard_info = "InfoBtnVC"
    case storyboard_reels = "Reels"
    
    var name: String {self.rawValue}
}

enum AppColorName: String {
    case purple_191422
    case purple_4B16BB
    case purple_340D53
    case purple_553878
    case purple_5B2AC5
    case purple_3B215D
    case purple_2B1746
    case purple_301C4B
    case purple_270542
    case purple_220F39
    case purple_1D0E2F
    case purple_26123F
    case purple_2E0A37
    case purple_0B0013
    case black_000000
    case black_090909
    case black_1E1E1E
    case black_0D0314
    case black_0D0D0D
    case black_191919
    case white_F1F1F1
    case white_F5F5F5
    case white_FFFFFF
    case yellow_F2C029
    case green_1AB85B
    case grey_EFEFEF
    case grey_E2E2E2
    case grey_707070
    case red_EA3C3D
    case BAC6D5
    case purple_29144D
    case yellow_FFBA30
    case yellow_F2C028
    case purple_1C0A3B
    case pink_EFE4FF
    case purple_1B0739

    case grey_252525

    case purple_3A225D
    case grey_2A2A2A
    case purple_311059

    case purple_54367F

    case white_FAF6FF
    case white_D9BFFF
    case black_2A2A2A
    case purple_704FA1
    case black_3C3C3C
    case grey_676767
    
    case black_272727
    case purple_3A225D0D
    case grey_6B6B6B33
    case grey_B6B6B6
    case blue_1B0739
    case grey_F2F2F2
    case grey_6B6B6B
    case purple_250F45
    case purple_17082E
    case black_121212

    case editprofile_FAF6FF
    
//    TKR Colors
    case grey_5F5E60
    case red_D30212
    case red_DD0D1D
    case red_C0000F
    case red_6C0F1C
    case black_0E0E0E
    case black_1F1A24
    case grey_4F4F4F
    case brown_3D0F17
    
//    ADKR Colors
    case purple_39245E
    case purple_1D1130
    case purple_39225D
    case purple_241045
    case grey_828282
    
    case white_FFFDFD
    
    case grey_DEDEDE
    case purple_361D5A
    case grey_B0B0B0
    
    var name: String {self.rawValue}
}

enum AppImagesName: String {
    case logo_main
    case logo_circle_blue
    case logo_secondary_large
    case nav_share_icon
    case loyalty_icon
    case home_icon
    case fanclub_icon
    case news_icon
    case like_icon
    case Like
    case like_icon_active
    case time_clock_icon
    case share_icon
    case like_newsDetails
    case like_news_icon
    case play_icon
    case captain_icon
    case back_icon
    case arrow_left
    case video_icon
    case mega_store_icon
    case more_icon
    case downArrow
    case happy_icon_inactive
    case happy_icon_active
    case smile_icon_inactive
    case smile_icon_active
    case thumps_up_active
    case thumps_up_inactive
    case heart_icon_inactive
    case heart_icon_active
    case celeberation_icon_inactive
    case celeberation_icon_active
    case edit_profile
    case elipseSelected
    case elipse
    case Selectionbtn
    case delete_icon
    case restore_icon
    case badges
    case invite_friend
    case reedem_code
    case ledger
    case close_rounded_icon
    case settings_icon
    case batter
    case bowler
    case all_rounder
    case wicket_keeper
    case search_icon
    case no_data_icon
    case captain
    case plane
    case notification_bell_icon
    case reward_points_inactive
    case reward_points_active
    case fan_reward_badges
    case fan_reward_tokens
    case fan_rewards_xp_level
    case notification_status
    case closing_up_arrow
    case expanding_up_arrow
    case like_active
    case like_inactive
    case notification_bell_active
    case rewards_trophy
    case fan_ranking_points
    case tokensLeft_logo
    case token_logo
    case hof_popup_background
    case back
    case facebookIcon
    case instaIcon
    case twitterIcon
    case closeIcon
    case copy_text_icon
    case check_box_unselected
    case checkMark
    case un_check_box
    case add_club_icon
    case round_star_icon
    case leftArrow
    case send_icon
    case add_member_icon
    case message_delete_icon
    case profilePic
    case club_joined
    case cancel_btn_bg
    case la_logo_main
    case divider_image
    case news_divider_img
    case gaming_icon
    case up_arrow
    case get_started_right_arrow
    case la_video_bottom_img
    case tkr_logo_main
    case adkr_logo_main
    case kkr_circular_logo
    case la_circular_logo
    case tkr_circular_logo
    case adkr_circular_logo
    case toggle_women
    case toggle_men
    case tkr_download_photos
    case tkr_left_arrow
    case tkr_right_arrow
    case tkr_okbtn
    case info_icon
    case pin_icon
    case unpin_icon
    case adkr_download_photos
    case adkr_right_arrow
    case adkr_left_arrow
    case faq_button
    
    case rigtgrey_btn
    case rightyellow_btn
    case leftgrey_btn
    case leftyellow_btn
    

    case test_player
    case button_right_arrow
    case button_left_arrow
    case PhotoDetails_bg
    case btn_share
    case btn_like
    case test_listingImage

    case new_like_icon
    case new_share_icon
    case yellow_likebtn
    
    case view_all_arrow
    case btn_view_all_frame
    case player_card
    case view_all
    case btn_newplay
    case live_bg
    case new_bell_icon
    case new_search_icon
    case poll_answered_icon
    case poll_unanswered_icon
    case arrow_icon
    case new_backbtn

    case new_delete_icon
    case new_restore_icon
    case restoreRight_icon
    case lock
    case kkr_bell_icon
    case answered_icon
    case unanswered_icon
    case editProfile_icon
    case logout_icon
    case redCross_icon
    case greenRight_icon
    case circleCheck_icon
    
    case captain_new_icon
    case foreign_player_new
    case batter_new
    case all_rounder_new
    case bowler_new
    case wicket_keeper_new
    case riderLogoutProfile
    case userProfile_KKR
    case flrp_liked_icon
    case flrp_like_icon
    case drop_down_white_icon
    case calendar_dob_white_icon
    case fav_player_card
    case kyy_img
    
    case edit_action_icon
    case logout_action_icon
    case delete_action_icon
    
    case fixtures_icon
    case unchecked_btn
    
    case clips_selected_icon
    case clips_icon
    
    case notification_action
    case restore_profile_action
    
    case fan_knight_tokens
    
    case talk_central_icon
    case stopwatch_icon
    case close_icon
    case talk_central_lock_icon
    case fanChatDefaultGroupIcon
    case icon_close
    
    var name: String {self.rawValue}
}

enum AppTestAssetsName: String {
    case test_showcase
    case test_videos
    case test_advertisement
    case test_player
    case image_106
    var name: String {self.rawValue}
}

enum AppBackgroundImageName: String {
    case background_main
    case background_listing
    case yellow_padded_button_bg
    case purple_button_bg
    case menu_bg
    case videos_bg
    case background_splash
    case left_small_curve_bg
    case referral_popup_bg
    case fan_club_bg
    case live_bg
    case la_showcase_bg
    case la_gaming_hub_bg
    case la_videos_bg
    case la_news_bg
    case la_matchcard_result
    case la_more_menu_bg
    case la_gaming_bg
    case la_standing_listing_bg
    case la_squad_listing_bg
    case la_standings_background
    case la_matchcard_live
    case la_details_bg
    case la_stats_bg_img
    case la_other_article_bg
    case video_cell_bg
    case la_video_films_bg
    case la_video_showcase_bg
    case la_new_listing_bg
    case la_latest_news_bg
    case other_videos_bg
    case la_Highlights_BG
    case la_photo_showcase_bg
    case la_squad_news_bg
    case la_squad_video_detail_bg
    case la_poll_bg_gradient
    case la_left_small_curve_bg
    case la_contactus_bg
    case view_all
    case editprofile_bg
    case fixtures_bg

//    TKR
    case tkr_gaming_bg
    case tkr_showcase_bg
    case tkr_videos_bg
    case tkr_press_releases_bg
    case tkr_photos_bg
    case tkr_quiz_background
    case tkr_matches_live
    case tkr_squad_listing_bg
    case tkr_squad_details_bg
    case tkr_latest_news
    case tkr_polls
    case tkr_download_photos
    case tkr_left_arrow
    case tkr_right_arrow
    case tkr_fixture_upcoming
    case tkr_quiz_bg
    case tkr_related_news_bg
    case tkr_knights_insights_bg

    //    ADKR
    case adkr_home_showcase
    case adkr_fixtures_bg
    case adkr_news_bg
    case adkr_quiz_holder_bg
    case adkr_quiz_bg
    case adkr_quiz_left_corner_curve
    case adkr_gamehub_bg
    case adkr_photos_widget_bg
    case adkr_squad_widget_bg
    case adkr_videos_widget_bg
    case adkr_press_release_bg
    case adkr_standings_widget_bg
    case adkr_squad_listing_bg
    case adkr_standing_listing_bg
    case adkr_other_article_bg
    case adkr_match_photos_bg
    case adkr_behind_the_scene
    case adkr_training_photos_bg
    case adkr_squad_details_bg
    case adkr_related_photo_bg
    case adkr_download_photos
    case adkr_match_upcoming
    case adkr_match_live
    
    
    case fan_poll
    case login_bg
    case hiFan_logo
    case hiFan_bg
    case greenRight_icon
    case circleCheck_icon
    case menu_separator
    case redeem_bg
    
    case fan_club_bg_new
    var name: String {self.rawValue}
}

enum AppSocialIconsImageName: String {
    case social_icon_facebook
    case social_icon_twitter
    case social_icon_instagram
    case social_icon_youtube
    case social_icon_whatsapp
    case social_icon_linkedin
    case social_icon_tiktok
    case social_icon_threads
    var name: String {self.rawValue}
}

enum UserType: String {
   case guest = "1"
   case registered = "2"
}

enum AppGradientAssetName: String {
    case nav_bg_gradient
    case stories_bg_gradient
    case gamehub_bg_gradient
    case gamehub_display_bg_gradient
    case squad_bg_gradient
    case profileBackground
    case edit_profile_bg
    case widget_bottom_black_gradient
    case la_photos_bg
    case la_standings_background
    case widget_bottom_purple_gradient
    case la_squad_bg
    case squad_detail_player_bgimg
    case home_player_details_BG
    case squad_detail_gradient
    case player_details_BG
    case la_detail_squad_divider
    case la_squad_player_bg
    case la_gamehub_bg_gradient
    case tkr_gaming_bg
    case tkr_photos_bg
    case tkr_squad_listing_bg
    case tkr_stories_bg
    case adkr_stories_bg
    case adkr_squad_details_bg
    case adkr_squad_player_gradient
    case black_gradient
    var name: String {self.rawValue}
}

public enum Model : String {
    // Simulator
    case simulator     = "simulator/sandbox",
         
         // iPod
         iPod1              = "iPod 1",
         iPod2              = "iPod 2",
         iPod3              = "iPod 3",
         iPod4              = "iPod 4",
         iPod5              = "iPod 5",
         iPod6              = "iPod 6",
         iPod7              = "iPod 7",
         
         // iPad
         iPad2              = "iPad 2",
         iPad3              = "iPad 3",
         iPad4              = "iPad 4",
         iPadAir            = "iPad Air ",
         iPadAir2           = "iPad Air 2",
         iPadAir3           = "iPad Air 3",
         iPadAir4           = "iPad Air 4",
         iPadAir5           = "iPad Air 5",
         iPad5              = "iPad 5", // iPad 2017
         iPad6              = "iPad 6", // iPad 2018
         iPad7              = "iPad 7", // iPad 2019
         iPad8              = "iPad 8", // iPad 2020
         iPad9              = "iPad 9", // iPad 2021
         
         // iPad Mini
         iPadMini           = "iPad Mini",
         iPadMini2          = "iPad Mini 2",
         iPadMini3          = "iPad Mini 3",
         iPadMini4          = "iPad Mini 4",
         iPadMini5          = "iPad Mini 5",
         iPadMini6          = "iPad Mini 6",
         
         // iPad Pro
         iPadPro9_7         = "iPad Pro 9.7\"",
         iPadPro10_5        = "iPad Pro 10.5\"",
         iPadPro11          = "iPad Pro 11\"",
         iPadPro2_11        = "iPad Pro 11\" 2nd gen",
         iPadPro3_11        = "iPad Pro 11\" 3rd gen",
         iPadPro12_9        = "iPad Pro 12.9\"",
         iPadPro2_12_9      = "iPad Pro 2 12.9\"",
         iPadPro3_12_9      = "iPad Pro 3 12.9\"",
         iPadPro4_12_9      = "iPad Pro 4 12.9\"",
         iPadPro5_12_9      = "iPad Pro 5 12.9\"",
         
         // iPhone
         iPhone4            = "iPhone 4",
         iPhone4S           = "iPhone 4S",
         iPhone5            = "iPhone 5",
         iPhone5S           = "iPhone 5S",
         iPhone5C           = "iPhone 5C",
         iPhone6            = "iPhone 6",
         iPhone6Plus        = "iPhone 6 Plus",
         iPhone6S           = "iPhone 6S",
         iPhone6SPlus       = "iPhone 6S Plus",
         iPhoneSE           = "iPhone SE",
         iPhone7            = "iPhone 7",
         iPhone7Plus        = "iPhone 7 Plus",
         iPhone8            = "iPhone 8",
         iPhone8Plus        = "iPhone 8 Plus",
         iPhoneX            = "iPhone X",
         iPhoneXS           = "iPhone XS",
         iPhoneXSMax        = "iPhone XS Max",
         iPhoneXR           = "iPhone XR",
         iPhone11           = "iPhone 11",
         iPhone11Pro        = "iPhone 11 Pro",
         iPhone11ProMax     = "iPhone 11 Pro Max",
         iPhoneSE2          = "iPhone SE 2nd gen",
         iPhone12Mini       = "iPhone 12 Mini",
         iPhone12           = "iPhone 12",
         iPhone12Pro        = "iPhone 12 Pro",
         iPhone12ProMax     = "iPhone 12 Pro Max",
         iPhone13Mini       = "iPhone 13 Mini",
         iPhone13           = "iPhone 13",
         iPhone13Pro        = "iPhone 13 Pro",
         iPhone13ProMax     = "iPhone 13 Pro Max",
         iPhoneSE3          = "iPhone SE 3nd gen",
         iPhone14           = "iPhone 14",
         iPhone14Pro        = "iPhone 14 Pro",
         iPhone14Plus       = "iPhone 14 Plus",
         iPhone14ProMax     = "iPhone 14 Pro Max",
         
         // Apple Watch
         AppleWatch1         = "Apple Watch 1gen",
         AppleWatchS1        = "Apple Watch Series 1",
         AppleWatchS2        = "Apple Watch Series 2",
         AppleWatchS3        = "Apple Watch Series 3",
         AppleWatchS4        = "Apple Watch Series 4",
         AppleWatchS5        = "Apple Watch Series 5",
         AppleWatchSE        = "Apple Watch Special Edition",
         AppleWatchS6        = "Apple Watch Series 6",
         AppleWatchS7        = "Apple Watch Series 7",
         
         // Apple TV
         AppleTV1           = "Apple TV 1gen",
         AppleTV2           = "Apple TV 2gen",
         AppleTV3           = "Apple TV 3gen",
         AppleTV4           = "Apple TV 4gen",
         AppleTV_4K         = "Apple TV 4K",
         AppleTV2_4K        = "Apple TV 4K 2gen",
         
         unrecognized       = "?unrecognized?"
}

// Layout Builder Essentails
enum KKRLayoutWidgetType: String {
    case videos = "Videos"
    case fixtures = "Fixtures & Results"
    case liveFixture = "Live Fixture"
    case display_ad_banner = "Ad Banner"
    case gaming_hub = "Gaming Hub"
    case join_loyalty_program_custom_ad = "Join the Loyalty"
    case join_fanclub_custom_ad = "Join the Fan Club"
    case standings = "Standings"
    case photos = "Photos"
    case news = "News"
    case showcase = "Showcase"
    case stories = "Stories"
    case quiz = "KKR Quiz"
    case squad = "Squad"
    case shop = "Megastore"
    case ads_banner_carousel = "Ads Banner Carousel"
    
    // News Widgets
    case newsShowcase = "News Showcase"
    case news_featured_articles = "Features Articles"
    case news_latest_articles = "Latest Articles & Press"
    case press_release = "PRESS RELEASE"
    
    // Videos Widgets
    case videosShowCase = "Videos Showcase"
    case videosBehindScenes = "Behind The Scenes"
    case videosHighlights = "Highlights"
    case videosSuggested = "Suggested For You"
    case videosFilms = "Knights TV"
    case videosKnightsShorts = "Knights Shorts"
    
    // Photos Widget
    case latestVideos = "Latest Videos"
    case latestNews = "Latest News"
    
    case photosShowCase = "Photo Showcase"
    case matchPhotos = "Match Photos"
    case trainingPhotos = "Training Photos"
    case behindTheScenes = "Behind the scenes"
    
}

enum KKRCellWidgetType: String {
    case large_listing_tile
    case small_listing_tile
    case bannerAd
    case dependencyWidget
    case unknown
}

enum CustomPopupType: String {
    case deleteAccount
    case restoreAccount
    case deleteAccountOK
    case restoreAccountOK
    case info
    var name: String {self.rawValue}
}

enum AppUpdatePopupType: Int {
    case noUpdate = 0
    case optionalUpdate = 1
    case forceUpdate = 2
}

// MARK: - SI PARAMETER KEYS
enum SIParameterKeys: String {
    case seriesID = "{series_id}"
    case imagePath = "{image_path}"
    case imageName = "{image_name}"
    case countryID = "{country_id}"
    case playerID = "{player_id}"
    case staffID = "{staff_id}"
    case timeStamp = "{time_stamp}"
    case emailId = "{email_id}"
    case teamID = "{team_id}"
    case nationalityID = "{nationality_id}"
    case contentImageVersion = "{content_image_version}"
    case dataImageVersion = "{data_image_version}"
    case userGuid = "{userguid}"
    case platform_id = "{platform_id}"
    case page_number = "{page_no}"
    case page_count = "{count}"
    case entityID = "{entity_id}"
    case excludeEntity = "{exclude_entity}"
    case title_alias = "{title_alias}"
    case entity_category = "{entity_category}"
    case search_text = "{search_text}"
    case badgeLevel = "{level_number}"
    case token = "{token}"
    case videoUrl = "{video_url}"
    case team1 = "{team1}"
    case team2 = "{team2}"
    case gameId = "{game_id}"
    case stateID = "{state_id}"
    case referralCode = "{referral_code}"
    case flrpShopActivityID = "{shop_activity_id}"
    
    case layoutBuilderFinder = "{layout_builder_finder}"
    case videosPageListingFinder = "{videos_page_listing_finder}"
    case photosPageListingFinder = "{photos_page_listing_finder}"
    case videosEntity = "{videos_entity}"
    case photosEntity = "{photos_entity}"
    case newsEntity = "{news_entity}"
    case newsPageListingFinder = "{news_page_listing_finder}"
    case pressPageListingFinder = "{press_page_listing_finder}"
    case fixtureMethodType = "{fixture_method_type}"
    case fixtureClientId = "{fixture_client_id}"
    case fixtureSport = "{fixture_sport}"
    case fixtureLeague = "{fixture_league}"
    case fixtureTimeZone = "{fixture_time_zone}"
    case fixtureLanguage = "{fixture_language}"
    case fixtureTournamentId = "{fixture_tournament_id}"
    case playerImagePathFinder = "{player_image_path_finder}"
    case teamImagePathFinder = "{team_image_path_finder}"
    case pollEntity = "{entity_map_id}"
    
    case ig_handle_finder = "{ig_handle_finder}"
    case team_type_schedulr_fixture = "{team_type_schedulr_fixture}"
    case imgRatio = "/0/"
    
    
    case firstName = "{firstname}"
    case lastName = "{lastname}"
  
    
    var keyName: String {self.rawValue}
}

enum PhotosNewsCellType {
    case photos
    case articles
    case pressRelease
}

enum AssetType: Int {
    case article = 1
    case photos = 2
    case videos = 4
    case unknown
}

enum StaticText {
    static let title = "Edit Profile"
    static let ticketAndOfferText = "We want you to be the first to know about Ticket Availability and occasional offers from official sponsors and partners. To stay updated, select "
    static let disclaimerText = "Your information may be used by Knight Riders Sports Private Limited and made available to our sponsors and third-parties to provide you with news and promotional information about Kolkata Knight Riders and enhance your app experience. By submitting this form you agree to the collection and processing of the same. For further information, please consult our Online "
    static let privacyAckText = "I acknowledge that I have read and agree to the Privacy Policy"
    static let deleteAccountActionText = "To permanently delete your Knight Club account please "
    static let deleteAccountHeaderText = "Delete your Knight Club Account".uppercased()
    static let deleteAccountSubHeaderText = "Please read the below carefully."
    static let deleteAccountConfirmText = "To continue with your account deletion request, please click on the link sent to your email."
    static let restoreAccountActionText = "To restore your Knight Club account please "
    static let restoreAccountHeaderText = "Restore your Knight Club Account".uppercased()
    static let restoreAccountDescText = "Your request to delete your Knight Club account will now be cancelled and we will start with Restoring your account"
    static let restoreAccountConfirmText = "We have initiated the process to Restore your account. You will now not be able to delete your account for another 30 days."
    
    static let privacyPolicyText = "I acknowledge that I have read and agree to the "
}

enum ListingType {
    case players
    case staff
}

enum KKRDateFormats: String {
    case siListing = "yyyy-MM-dd HH:mm:ss"
    case siListing2 = "yyyy-MM-dd'T'HH:mm:Z"
    case siListing3 = "d MMM, yyyy"
    case ddMMMyyyy = "dd MMM, yyyy"
    case ddMMMMyyyy = "dd MMMM yyyy"
    case fixtures = "yyyy-MM-dd'T'HH:mmZ"
    case fixturesDisplay = "dd MMMM yyyy HH:mm"
    case monthDay = "MMM d"
    case dayMonth = "d MMM"
    case dayMonthYear = "d MMM yyyy"
    case time = "HH:mm a"
    case monthDayTime = "MMM d, hh:mm a"
    case dayMonthTime = "d MMM, h:mm a"
    case dateRange = "ddMMyyyy"
    case scorecardDateFormat = "M/d/yyyy"
    case scorecardDateFormatShortMonth = "dd MMM yyyy"
    case scorecardTimeFormat = "HH:mm"
    case scorecardTimeWithOffset = "HH:mmZ"
    case monthFullYear = "MMM yyyy"
    case monthDateYear = "MMM d, yyyy"
    case fullMonthFullYear = "MMMM yyyy"
    case dobSignup = "dd/MM/yyyy"
    case yyyyddHHmmssSSS = "yyyy-MM-dd HH:mm:ss.SSS"
    case dobProfile = "yyyy-MM-dd"
    case fanLoyalty = "dd MMM yyyy | HH:mm"
    case siListing4 = "yyyy-MM-dd'T'HH:mm:ss"
    case yyyyddTHHmmssSSS = "yyyy-MM-dd'T'HH:mm:ss.SSS"
    case ddMMMMyyyy_hhmma = "dd MMMM yyyy '|' hh:mm a"
    case fixturesDayFirstFormat = "MM/dd/yyyy'T'HH:mmZ"
}

enum WelcomeScreenNavigation {
    case rootHome
    case knowYourApp
}

enum JavascriptMethod: String {
    case fixturesPageWebView
//    case nativeLogin
    case dataTracking
    case gameHubDataTracking
    case redirectToNative
    case squadListingWebView
    case moengageEventTracking
}

enum PlayerSkill: String {
  case batter = "1"
  case bowler = "2"
  case allRounder = "3"
  case wicketKeeper = "4"
}

enum TrackEvent: String {
    case searchTerm = "Search Term"
    
}

enum NotificationPayloadKeys: String {
    case asset_type
    case asset_url
    case asset_title
    case asset_alias
    case game_name
    case game_url
    case home_team_short_name
    case away_team_short_name
    case home_team_full_name
    case away_team_full_name
    case is_webview
    case in_app_browser
    case is_external_webview
    case webview_url
    case guid
    case message_id
    
    var name: String {self.rawValue}
}

enum CometChatPopUpType {
    case leaveClub
    case deleteClub
}

enum CometChatClubRequestAction {
    case accept
    case reject
}

enum AdminActionPopUpType {
    case makeAdmin
    case moderator
    case removeMember
}

enum LoginPopUpType {
    case login
    case hallOfFans
}

//enum LoginRedirectionType {
//    case home
//    case hallOfFans
//    case redeemKnightTokens
//    case videoDetail(VideosDetailVC)
//    case newsDetail(NewsDetailsVC)
//    case updatedNewsDetailsVC(UpdatedNewsDetailsVC)
//    case photoDetail(PhotosDetailVC)
//    case story(StoriesDisplayParentVC)
//    case fanClub
//    case gaming
//    case matchCenter
//    case profile(ProfileVC)
//    case profileWithReferralPopUp(ProfileVC)
//
//}

enum ModuleListing {
    case photos(isArticle: Bool)
    case videos
    case news
    case squad
    case home
}

enum KKRCellBadgeType: String,CaseIterable {
    case unlocked
    case locked
    case progress
}

enum BannerRedirectionType: String {
    case home
    case videos
    case videos_subpage
    case video_details
    case clips
    case photos
    case photos_subpage
    case photodetail
    case news
    case news_subpage
    case news_detail
    case press_release
    case press_release_detail
    case fan_chat
    case loyalty
    case redeem_knight_tokens
    case gaming_hub
    case profile
    case search
    case notifications
    case badges
    case ledger
    case edit_profile
    case webview
}

enum TutorialNewFeatures: String {
    case Login
    case Loyalty
    case FanChat
    case Clips
}

