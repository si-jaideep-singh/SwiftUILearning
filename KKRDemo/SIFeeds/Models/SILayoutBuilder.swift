//
//  SILayoutBuilder.swift
//  SIListing
//
//  Created by Siddharth Daga on 4/10/19.
//  Copyright © 2019 Sportz Interactive. All rights reserved.
//

import Foundation

public struct SILayoutBuilderModel: Codable {
    var status: Int?
    var content: SILayoutBuilderContent?
    var message: String?

    enum CodingKeys: String, CodingKey {
        case status
        case content
        case message
    }
}

public struct SILayoutBuilderContent: Codable {
    var html, title: String?
    var module: [SILayoutBuilderWidget]?
    var pageID: Int?
    var titleApp, titleWeb, titleMobile, masterhtml: String?
    var languageID: Int?
    var isredirect, redirecturl, redirectparent: String?
    var templateID: Int?
    var masterTemplateID: Int?
    var isProtected: Bool?
    var parentID: Int?
    var pageEntity: [Int]?
    var languageName: String?
    var showData, showContent: Bool?
    var statusCode: Int?

    enum CodingKeys: String, CodingKey {
        case html, title, module
        case pageID = "page_id"
        case titleApp = "title_app"
        case titleWeb = "title_web"
        case titleMobile = "title_mobile"
        case masterhtml
        case languageID = "language_id"
        case isredirect, redirecturl, redirectparent
        case templateID = "template_id"
        case masterTemplateID = "master_template_id"
        case isProtected = "is_protected"
        case parentID = "parent_id"
        case pageEntity = "page_entity"
        case languageName = "language_name"
        case showData = "show_data"
        case showContent = "show_content"
        case statusCode = "status_code"
    }

}

public struct SILayoutBuilderWidget: Codable {
    var title, selector: String
    var metaInfo: SILayoutBuilderModuleMetaInfo?
    var dependency: [SILayoutBuilderWidget]?
    var fetchFrom, templateID: Int?
    var widgetData: SILayoutBuilderWidgetData?
    var componentID: Int?
    var displayTitle: String?
    var otherEntities: [Int]?
    var requiredEntities: [Int]?
    var excludeEntities: [Int]?
    var templateComponentMapID, showInApp, showInWeb, showInMobile: Int?

    enum CodingKeys: String, CodingKey {
        case title, selector
        case metaInfo = "meta_info"
        case dependency
        case fetchFrom = "fetch_from"
        case templateID = "template_id"
        case widgetData = "widget_data"
        case componentID = "component_id"
        case displayTitle = "display_title"
        case otherEntities = "other_entities"
        case requiredEntities = "required_entities"
        case excludeEntities  = "exclude_entities"
        case templateComponentMapID = "template_component_map_id"
        case showInApp = "show_in_app"
        case showInWeb = "show_in_web"
        case showInMobile = "show_in_mobile"
    }

}

// MARK: - ModuleMetaInfo
struct SILayoutBuilderModuleMetaInfo: Codable {
    var view: String?
    var order: Int?
    var widgetOrder: Int?
//    var lgCol, lgRow, mdCol, mdRow: String?
//    var smCol, smRow, xlCol, xlRow: String?
//    var xsCol, xsRow
//    var extraData: String?
    var component: SIFeedsComponentName?
    var seriesID, showDate, showTitle, showAuthor: Int?
    var loadmoreType: String?
    var showCategory, showItemIcon, showDescription: Int?
    var widgetTitleTag, articleTitleTag: String?
    public var showWidgetTitle, showitemIconContent: Int?
    var articleDescriptionTag, widgetTitleTagAttributes, articleTitleTagAttributes, articleDescriptionTagAttributes: String?
    var fb: Int?
    var imgRatio: String?
    var isShare, showImage, isComments, isReactions: Bool?
    var showTagline, showTimestamp, showImageCount: Bool?
    var bannerLink: String?
    var bannerWidth, bannerHeight: Int?
    var adWidth, adHeight: Int?
    var adRatio: Double?
    var bannerImage: String?
    var formFields: [SILayoutBuilderModuleMetaInfoFormFieldDetail]?
    var formTitle: String?
    var apiConfig: SILayoutBuilderModuleMetaInfoApiConfig?
    var adUnitID: Int?
    var adUnitCode: String?
    var adPublisherCode: Int?
    var layoutdata:[SILayoutData]?
    var moreLinks: SIMoreLinkData?
    var webviewHeight: String?
    var webviewUrl: String?
    var bannerCarouselInfo: [BannerCarouselInfo]?
    var dependency: SILayoutBuilderDependency?
    var bannerInfo: BannerCarouselInfo?

    enum CodingKeys: String, CodingKey {
        case view, order
        case widgetOrder = "widget_order"
//        case lgCol = "lg_col"
//        case lgRow = "lg_row"
//        case mdCol = "md_col"
//        case mdRow = "md_row"
//        case smCol = "sm_col"
//        case smRow = "sm_row"
//        case xlCol = "xl_col"
//        case xlRow = "xl_row"
//        case xsCol = "xs_col"
//        case xsRow = "xs_row"
//        case extraData
        case component
        case seriesID = "series_id"
        case showDate = "show_date"
        case showTitle = "show_title"
        case showAuthor = "show_author"
        case loadmoreType = "loadmore_type"
        case showCategory = "show_category"
        case showItemIcon = "show_item_icon"
        case showDescription = "show_description"
        case widgetTitleTag = "widget_title_tag"
        case articleTitleTag = "article_title_tag"
        case showWidgetTitle = "show_widget_title"
        case showitemIconContent = "showitem_icon_content"
        case articleDescriptionTag = "article_description_tag"
        case widgetTitleTagAttributes = "widget_title_tag_attributes"
        case articleTitleTagAttributes = "article_title_tag_attributes"
        case articleDescriptionTagAttributes = "article_description_tag_attributes"
        case fb, imgRatio
        case isShare = "is_share"
        case showImage = "show_image"
        case isComments = "is_comments"
        case isReactions = "is_reactions"
        case showTagline = "show_tagline"
        case showTimestamp = "show_timestamp"
        case showImageCount = "show_image_count"
        case bannerLink = "banner_link"
        case bannerWidth = "banner_width"
        case bannerHeight = "banner_height"
        case adWidth = "ad_width"
        case adHeight = "ad_height"
        case adRatio = "ad_ratio"
        case bannerImage = "banner_image"
        case formFields = "form_fields"
        case formTitle = "form_title"
        case apiConfig = "api_config"
        case adUnitID = "ad_unit_id"
        case adUnitCode = "ad_unit_code"
        case adPublisherCode = "ad_publisher_code"
        case layoutdata = "layout_data"
        case moreLinks = "more_links"
        case webviewHeight = "webview_height"
        case webviewUrl = "webview_url"
        case bannerCarouselInfo = "banner_carousel_info"
        case dependency = "dependency"
        case bannerInfo = "banner_info"
    }
}

struct SIMoreLinkData: Codable {
    var more: String?
}

struct SILayoutData: Codable {
    var count: Int?
    var order: Int?
    var imgRatio: String?
    var aspect_ratio: String?
}

struct SILayoutBuilderModuleMetaInfoFormFieldDetail: Codable {
    var type: String?
    var order: Int?
    var title: String?
    var fieldName: String?
    var isRequired: Bool?

    enum CodingKeys: String, CodingKey {
        case type, order, title
        case fieldName = "field_name"
        case isRequired = "is_required"
    }
}

struct SILayoutBuilderModuleMetaInfoApiConfig: Codable {
    var feedpath: String?
    enum CodingKeys: String, CodingKey {
        case feedpath
    }
}

struct SILayoutBuilderDependency: Codable {
//    var lgCol, lgRow, mdCol, mdRow: String?
//    var smCol, smRow, xlCol, xlRow: String?
//    var xsCol, xsRow: String?
//    var extraData: String?
    var showDate, showTitle, showAuthor: Int?
    var loadmoreType: String?
    var showCategory, showItemIcon, showDescription: Int?
    var widgetTitleTag: String?
    var showitemIconContent: Int?
    var widgetTitleTagAttributes: String?
    var bannerCarouselData: [BannerCarouselInfo]?

    enum CodingKeys: String, CodingKey {
//        case lgCol = "lg_col"
//        case lgRow = "lg_row"
//        case mdCol = "md_col"
//        case mdRow = "md_row"
//        case smCol = "sm_col"
//        case smRow = "sm_row"
//        case xlCol = "xl_col"
//        case xlRow = "xl_row"
//        case xsCol = "xs_col"
//        case xsRow = "xs_row"
//        case extraData
        case showDate = "show_date"
        case showTitle = "show_title"
        case showAuthor = "show_author"
        case loadmoreType = "loadmore_type"
        case showCategory = "show_category"
        case showItemIcon = "show_item_icon"
        case showDescription = "show_description"
        case widgetTitleTag = "widget_title_tag"
        case showitemIconContent = "showitem_icon_content"
        case widgetTitleTagAttributes = "widget_title_tag_attributes"
        case bannerCarouselData = "banner_carousel_data"
    }
}

// MARK: - SILayoutBuilderWidgetData
struct SILayoutBuilderWidgetData: Codable {
    let data: SILayoutBuilderDataClass?
    let items: [SILayoutBuilderWidgetDataItem]?
}

// MARK: - DataClass
struct SILayoutBuilderDataClass: Codable {
    let guid, count: String?
    let status: Int?
    let assetMap: [SILayoutBuilderDataAssetMap]?
    let isTrashed, updatedBy: Int?
    let publishedDate: String?
    let templateComponentMapID: Int?

    enum CodingKeys: String, CodingKey {
        case guid, count, status
        case assetMap = "asset_map"
        case isTrashed = "is_trashed"
        case updatedBy = "updated_by"
        case publishedDate = "published_date"
        case templateComponentMapID = "template_component_map_id"
    }
}

// MARK: - SILayoutBuilderDataAssetMap
struct SILayoutBuilderDataAssetMap: Codable {
    let author: [SILayoutBuilderAuthor]?
    let assetID: Int?
    let assetMeta: SILayoutBuilderAssetMeta?
    let assetType: Int?
    let entitydata: [SILayoutBuilderAssetMapEntity]?
    let assetOrder: Int?
    let publishDate: String?
    let publishedVersionNumber: Int?
    let totalAssets : Int?
    let albumCount : Int?
    var entityRoleMapId: Int?

    enum CodingKeys: String, CodingKey {
        case author
        case assetID = "asset_id"
        case assetMeta = "asset_meta"
        case assetType = "asset_type"
        case entitydata
        case assetOrder = "asset_order"
        case publishDate = "publish_date"
        case publishedVersionNumber = "published_version_number"
        case totalAssets = "total_assets"
        case albumCount = "album_count"
        case entityRoleMapId = "entity_role_map_id"
        
    }
}

// MARK: - SILayoutBuilderAuthor
struct SILayoutBuilderAuthor: Codable {
    var assetID, authorID: Int?
    var fullName: String?
    var userName: String?
    var authorName: String?
    var assetTypeID: Int?

    enum CodingKeys: String, CodingKey {
        case assetID = "asset_id"
        case authorID = "author_id"
        case fullName = "full_name"
        case userName = "user_name"
        case authorName = "author_name"
        case assetTypeID = "asset_type_id"
    }
}

// MARK: - SILayoutBuilderAssetMeta
struct SILayoutBuilderAssetMeta: Codable {
    var url: String?
    var desc, title: String?
    var assetID: Int?
    var imageID: Int?
    var imageName, imagePath: String?
    var responsive: Int?
    var titleAlias: String?
    var videoEmbed: String?
    var contentType: Int?
    var mobImageID, scoreWicket, mobImageName, mobImagePath: String?
    var contentSourceID: String?
    var show_content: Bool?

    enum CodingKeys: String, CodingKey {
        case url, desc, title
        case assetID = "asset_id"
        case imageID = "image_id"
        case imageName = "image_name"
        case imagePath = "image_path"
        case responsive
        case titleAlias = "title_alias"
        case videoEmbed = "video_embed"
        case contentType = "content_type"
        case mobImageID = "mob_image_id"
        case scoreWicket = "score_wicket"
        case mobImageName = "mob_image_name"
        case mobImagePath = "mob_image_path"
        case contentSourceID = "content_source_id"
        case show_content = "show_content"
    }
}

// MARK: - SILayoutBuilderAssetMapEntity
struct SILayoutBuilderAssetMapEntity: Codable {
    var name: String?
    var isLang, assetID, priority: Int?
    var canonical: String?
    var entityURL: String?
    var isVisible, isLinkable, assetTypeID: Int?
    var entDispName: String?
    var entityRoleMapID: Int?

    enum CodingKeys: String, CodingKey {
        case name
        case isLang = "is_lang"
        case assetID = "asset_id"
        case priority, canonical
        case entityURL = "entity_url"
        case isVisible = "is_visible"
        case isLinkable = "is_linkable"
        case assetTypeID = "asset_type_id"
        case entDispName = "ent_disp_name"
        case entityRoleMapID = "entity_role_map_id"
    }
}

// MARK: - SILayoutBuilderWidgetDataItem
struct SILayoutBuilderWidgetDataItem: Codable, ContainsTitleAlias {
    var rno: Int?
    var tags: String?
    var assetID: Int?
    var duration: String?
    var authorID: Int?
    var fullName: String?
    var isActive: Int?
    var userName: String?
    var assetGUID: String?
    var createdBy: Int?
    var imagePath: String?
    var isDeleted, isTrashed: Int?
    var shortDesc: String?
    var description: String?
    var updatedBy: Int?
    var assetTitle: String?
    var shortTitle: String?
    var showInApp: Int?
    var showInWeb: Int?
    var titleAlias, createdDate: String?
    var displayName: String?
    var isPublished: Int?
    var orderNumber, totalAssets: Int?
    var updatedDate: String?
    var assetListID, assetTypeID: Int?
    var publishedDate: String?
    var showCopyright: Int?
    var showInMobile: Int?
    var imageFileName: String?
    var priEntDispName: String?
    var secEntDispName: String?
    var primaryEntityName: String?
    var secondaryEntityName: String?
    var secondaryEntityUrl: String?
    var publishedVersionNumber, primaryEntityRoleMapID, secondaryEntityRoleMapID: Int?
    var coverDetail: SIFeedsCoverDetail?
    var focusByKeyword: [SIFeedsDetailFocusByKeyword]?
    var discountPrice: String?
    var price: String?
    var offer: String?
    var externalLink: String?
    var infoKey: String?
    var custom_json: String?

    enum CodingKeys: String, CodingKey {
        case rno, tags
        case assetID = "asset_id"
        case duration
        case authorID = "author_id"
        case fullName = "full_name"
        case isActive = "is_active"
        case userName = "user_name"
        case assetGUID = "asset_guid"
        case createdBy = "created_by"
        case imagePath = "image_path"
        case isDeleted = "is_deleted"
        case isTrashed = "is_trashed"
        case shortDesc = "short_desc"
        case description
        case updatedBy = "updated_by"
        case assetTitle = "asset_title"
        case shortTitle = "short_title"
        case showInApp = "show_in_app"
        case showInWeb = "show_in_web"
        case titleAlias = "title_alias"
        case createdDate = "created_date"
        case displayName = "display_name"
        case isPublished = "is_published"
        case orderNumber = "order_number"
        case totalAssets = "total_assets"
        case updatedDate = "updated_date"
        case assetListID = "asset_list_id"
        case assetTypeID = "asset_type_id"
        case publishedDate = "published_date"
        case showCopyright = "show_copyright"
        case showInMobile = "show_in_mobile"
        case imageFileName = "image_file_name"
        case priEntDispName = "pri_ent_disp_name"
        case secEntDispName = "sec_ent_disp_name"
        case primaryEntityName = "primary_entity_name"
        case secondaryEntityName = "secondary_entity_name"
        case secondaryEntityUrl = "sec_ent_url"
        case publishedVersionNumber = "published_version_number"
        case primaryEntityRoleMapID = "primary_entity_role_map_id"
        case secondaryEntityRoleMapID = "secondary_entity_role_map_id"
        case coverDetail = "cover_detail"
        case focusByKeyword = "focus_by_keywords"
        case discountPrice = "discount_price"
        case price
        case offer
        case externalLink = "external_link"
        case infoKey = "info_url"
        case custom_json = "custom_json"
    }
}

// MARK: - SIFeedsAdUnit
public struct SIFeedsAdUnit: Codable {
    public let ios, android: String?
}

// MARK: - SIFeedsCoverDetail
public struct SIFeedsCoverDetail: Codable {
    let branding: String?
    let fieldBrightcoveIsLive: Bool?
    
    enum CodingKeys: String, CodingKey {
        case branding
        case fieldBrightcoveIsLive = "field_brightcove_is_live"
    }
}
struct BannerCarouselInfo: Codable {
    let isWebview: Bool?
    let bannerType, titleAlias: String?
    let webviewURL: String?
    let bannerImage: String?
    let bannerOrder: Int?
    let displayTitle: String?
    let inAppBrowser: Bool?
    let otherEntities: [Int]?
    let analyticsTitle: String?
    let excludeEntities, requiredEntities: [Int]?
    let isExternalWebview: Bool?
    let loginRequired: Bool?
    let isGaming: Bool?
    let infoUrl: String?

    enum CodingKeys: String, CodingKey {
        case isWebview = "is_webview"
        case bannerType = "banner_type"
        case titleAlias = "title_alias"
        case webviewURL = "webview_url"
        case bannerImage = "banner_image"
        case bannerOrder = "banner_order"
        case displayTitle = "display_title"
        case inAppBrowser = "in_app_browser"
        case otherEntities = "other_entities"
        case analyticsTitle = "analytics_title"
        case excludeEntities = "exclude_entities"
        case requiredEntities = "required_entities"
        case isExternalWebview = "is_external_webview"
        case loginRequired = "login_required"
        case isGaming = "is_gaming"
        case infoUrl = "info_url"
    }
}

// MARK: - BannerInfo
struct BannerInfo: Codable {
    var infoURL: String?
    var isGaming, isWebview: Bool?
    var bannerType, titleAlias, webviewURL: String?
    var bannerImage: String?
    var displayTitle: String?
    var inAppBrowser, loginRequired: Bool?
    var analyticsTitle: String?
    var excludeEntities, requiredEntities: [Int]?
    var isExternalWebview: Bool?

    enum CodingKeys: String, CodingKey {
        case infoURL = "info_url"
        case isGaming = "is_gaming"
        case isWebview = "is_webview"
        case bannerType = "banner_type"
        case titleAlias = "title_alias"
        case webviewURL = "webview_url"
        case bannerImage = "banner_image"
        case displayTitle = "display_title"
        case inAppBrowser = "in_app_browser"
        case loginRequired = "login_required"
        case analyticsTitle = "analytics_title"
        case excludeEntities = "exclude_entities"
        case requiredEntities = "required_entities"
        case isExternalWebview = "is_external_webview"
    }
}
