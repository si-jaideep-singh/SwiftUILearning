//
//  Constants.swift
//  KKR App
//
//  Created by Ajinkya Sonar on 14/02/23.
//

import Foundation

struct Constants {
    
    struct KKRHomeLayoutWidgetViewType {
        static let kkr_home_videos_widget = "widget_layout_01"
        static let kkr_home_fixtures_widget = "widget_layout_01"
        static let kkr_home_live_fixture_widget = "widget_layout_02"
        static let kkr_home_si_display_ads_widget = "widget_layout_01"
        static let kkr_home_join_loyalty_ad_widget = "widget_layout_02"
        static let kkr_home_join_fanclub_ad_widget = "widget_layout_03"
        static let kkr_home_standings_widget = "widget_layout_01"
        static let kkr_home_photos_widget = "widget_layout_03"
        static let kkr_home_news_widget = "widget_layout_02"
        static let kkr_home_showcase_widget = "widget_layout_01"
        static let kkr_home_stories_widget = "widget_layout_01"
        static let kkr_home_quiz_widget = "widget_layout_01"
        static let kkr_home_squad_widget = "widget_layout_01"
        static let kkr_home_shop_widget = "widget_layout_02"
        static let kkr_home_gaming_hub_widget = "kc01_widget_layout_02"
        static let kkr_home_press_release_widget = "widget_layout_08"
        static let lakr_banner = "widget_layout_04"
        static let kkr_home_ads_banner_carousel = "widget_layout_05"
    }
    
    struct KKRVideosLayoutWidgetViewType {
        static let kkr_videos_showcase_widget = "widget_layout_01"
        static let kkr_videos_behind_scenes_widget = "widget_layout_01"
        static let kkr_videos_films_widget = "widget_layout_02"
        static let kkr_videos_highlights_widget = "widget_layout_03"
        static let kkr_videos_suggestions_widget = "widget_layout_04"
        static let lakr_banner = "widget_layout_04"
        static let tkr_videos_knight_shorts_widget = "widget_layout_05"
    }
    
    struct KKRNewsLayoutWidgetViewType {
        static let kkr_news_showcase_widget = "widget_layout_01"
        static let kkr_news_latest_article_widget = "widget_layout_01"
        static let kkr_news_feature_article_widget = "widget_layout_02"
        static let lakr_press_release_widget = "widget_layout_08"
        static let lakr_banner = "widget_layout_04"
    }
    
    struct KKRPhotosLayoutWidgetViewType {
        static let kkr_photos_showcase_widget = "widget_layout_03"
        static let kkr_photos_match_photos_widget = "widget_layout_01"
        static let kkr_photos_training_photos_widget = "widget_layout_02"
        static let kkr_photos_behind_scenes_widget = "widget_layout_03"
        static let lakr_banner = "widget_layout_04"
    }
    
    struct KKRAppConstants {
        static let platformID = "3"
        static var cometChatCred: CometChatKeys?
    }
    
    struct CometChatKeys {
        let cometChatAppID: String
        let cometChatRegion: String
        let cometChatAuthKey: String
        
        init(cometChatAppID: String, cometChatRegion: String, cometChatAuthKey: String) {
            self.cometChatAppID = cometChatAppID
            self.cometChatRegion = cometChatRegion
            self.cometChatAuthKey = cometChatAuthKey
        }
    }
}
