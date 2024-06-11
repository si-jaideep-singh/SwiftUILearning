//
//  SIFeedsDetailListing.swift
//  Bolts
//
//  Created by Siddharth Daga on 5/27/19.
//

import Foundation

// MARK: - SIFeedsDetailModel
public struct SIFeedsDetailModel: Codable {
    public var status: Int?
    public var content: SIFeedsDetailContent?
    public var imagesData: SIFeedsDetailImagesData?
    // public var authodata: SIFeedsDetailAuthodata? //Not Required
    public var nextPrev: SIFeedsDetailNextPrev?
    public var meta: SIFeedsDetailMeta?
    
    enum CodingKeys: String, CodingKey {
        case status
        case content
        case imagesData = "ImagesData"
        // case authodata = "Authodata" // Not Required
        case nextPrev = "NextPrev"
        case meta
    }
}

// MARK: - SIFeedsDetailAuthodata
public struct SIFeedsDetailAuthodata: Codable {
    public let authors: [SIFeedsDetailAuthor]?
}

// MARK: - SIFeedsDetailAuthor
public struct SIFeedsDetailAuthor: Codable {
    public let userID: Int?
    public let fullName, userName, displayName: String?
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case fullName = "full_name"
        case userName = "user_name"
        case displayName = "display_name"
    }
}

// MARK: - SIFeedsDetailContent
public struct SIFeedsDetailContent: Codable {
    public let data: SIFeedsDetailDataClass?
}

// MARK: - SIFeedsDetailDataClass
public struct SIFeedsDetailDataClass: Codable {
    public let contentSourceID, guid, assetType: String?
    public let articleID: Int?
    public let title, desc: String?
    public let titleAlias, videoUrl: String?
    public let duration: String?
    public let shortTitle: String?
    public let shortURL: String?
    public let browserTitle, introText, isPublish, fullText: String?
    public let place, country, imageThumb, mobileDescText: String?
    public let createdDate, modifiedDate: String?
    public let publishedDate: String?
    public let publishedDateIst: String?
    public let status: String?
    public let slugTitle: String?
    public let slugURL: String?
    public let authorURL, authorText: String?
    public let createdBy, editedBy, versionNumber, isTrashed: String?
    public let entitydata: [SIFeedsDetailEntityData]?
    public let showCopyright, showInWeb, showInMobile, contentSourceLink: String?
    public let imageFileName, imagePath, imageID: String?
    public let checkedOutBy, checkedOutByName: String?
    public let contentProviderName: String?
    public let contentProviderLogo: String?
    public let createdByName, imagedata, parentArticleID: String?
    public let focusByKeywords: [SIFeedsDetailFocusByKeyword]?
    public let parentArticleTitle, editedByName, isLiveBlog: String?
    public let assetTypeID: String?
    public let chkSendNotification: Bool?
    public let league: String?
    public let isFeaturedImage: String?
    public let isDefaultImage: String?
    public let albumDesc, albumType: String?
    public let albumId : Int?
    public let videoId: String?
    public let images: [SIFeedsDetailImagesData]?
    public let relatedData: SIFeedsDetailNextPrev?
    public let hlsVideoUrl: String?
    public let relatedItems: [SIFeedsListingItem]?
    public let coverDetails: SIFeedsDetailCoverDetails?
    public let additionalInfo: SIFeedsDetailAdditionalInfo?
    
    public var hashBig: Bool {
        if contentSourceID == "10" {
            return true
        }
        return false
    }
    
    enum CodingKeys: String, CodingKey {
        case articleID = "article_id"
        case desc
        case contentSourceID = "content_source_id"
        case guid
        case assetType = "asset_type"
        case duration
        case title
        case titleAlias = "title_alias"
        case videoUrl = "video_url"
        case shortTitle = "short_title"
        case shortURL = "short_url"
        case browserTitle = "browser_title"
        case introText = "intro_text"
        case isPublish = "is_publish"
        case fullText = "full_text"
        case place, country
        case imageThumb = "image_thumb"
        case mobileDescText = "mobile_desc_text"
        case createdDate = "created_date"
        case modifiedDate = "modified_date"
        case publishedDate = "published_date"
        case publishedDateIst = "published_date_ist"
        case status
        case slugTitle = "slug_title"
        case slugURL = "slug_url"
        case authorURL = "author_url"
        case authorText = "author_text"
        case createdBy = "created_by"
        case editedBy = "edited_by"
        case versionNumber = "version_number"
        case isTrashed = "is_trashed"
        case entitydata
        case showCopyright = "show_copyright"
        case showInWeb = "show_in_web"
        case showInMobile = "show_in_mobile"
        case contentSourceLink = "content_source_link"
        case imageFileName = "image_file_name"
        case imagePath = "image_path"
        case imageID = "image_id"
        case checkedOutBy = "checked_out_by"
        case checkedOutByName = "checked_out_by_name"
        case contentProviderName = "content_provider_name"
        case contentProviderLogo = "content_provider_logo"
        case createdByName = "created_by_name"
        case imagedata
        case focusByKeywords = "focus_by_keywords"
        case parentArticleID = "parent_article_id"
        case parentArticleTitle = "parent_article_title"
        case editedByName = "edited_by_name"
        case isLiveBlog = "is_live_blog"
        case assetTypeID = "asset_type_id"
        case chkSendNotification, league
        case isDefaultImage = "is_default_image"
        case isFeaturedImage = "is_featured_image"
        case albumId = "album_id"
        case albumDesc = "album_desc"
        case albumType = "album_type"
        case videoId = "video_id"
        case images
        case relatedData = "related_data"
        case hlsVideoUrl = "hls_url"
        case relatedItems = "related_items"
        case coverDetails = "CoverDetails"
        case additionalInfo = "AdditionalInfo"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.articleID = try container.decodeIfPresent(Int.self, forKey: .articleID)
        self.contentSourceID = try container.decodeIfPresent(String.self, forKey: .contentSourceID)
        self.guid = try container.decodeIfPresent(String.self, forKey: .guid)
        self.assetType = try container.decodeIfPresent(String.self, forKey: .assetType)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.desc = try container.decodeIfPresent(String.self, forKey: .desc)
        self.titleAlias = try container.decodeIfPresent(String.self, forKey: .titleAlias)
        self.videoUrl = try container.decodeIfPresent(String.self, forKey: .videoUrl)
        self.duration = try container.decodeIfPresent(String.self, forKey: .duration)
        
        self.shortTitle = try container.decodeIfPresent(String.self, forKey: .shortTitle)
        self.shortURL = try container.decodeIfPresent(String.self, forKey: .shortURL)
        
        self.browserTitle = try container.decodeIfPresent(String.self, forKey: .browserTitle)
        self.introText = try container.decodeIfPresent(String.self, forKey: .introText)
        self.isPublish = try container.decodeIfPresent(String.self, forKey: .isPublish)
        
        self.fullText = try container.decodeIfPresent(String.self, forKey: .fullText)
        self.place = try container.decodeIfPresent(String.self, forKey: .place)
        self.country = try container.decodeIfPresent(String.self, forKey: .country)
        
        self.imageThumb = try container.decodeIfPresent(String.self, forKey: .imageThumb)
        self.mobileDescText = try container.decodeIfPresent(String.self, forKey: .mobileDescText)
        self.createdDate = try container.decodeIfPresent(String.self, forKey: .createdDate)
        self.publishedDate = try container.decodeIfPresent(String.self, forKey: .publishedDate)
        
        self.modifiedDate = try container.decodeIfPresent(String.self, forKey: .modifiedDate)
        self.status = try container.decodeIfPresent(String.self, forKey: .status)
        self.publishedDateIst = try container.decodeIfPresent(String.self, forKey: .publishedDateIst)
        self.slugTitle = try container.decodeIfPresent(String.self, forKey: .slugTitle)
        
        self.slugURL = try container.decodeIfPresent(String.self, forKey: .slugURL)
        self.authorURL = try container.decodeIfPresent(String.self, forKey: .authorURL)
        self.authorText = try container.decodeIfPresent(String.self, forKey: .authorText)
        self.createdBy = try container.decodeIfPresent(String.self, forKey: .createdBy)
        
        self.editedBy = try container.decodeIfPresent(String.self, forKey: .editedBy)
        self.versionNumber = try container.decodeIfPresent(String.self, forKey: .versionNumber)
        self.isTrashed = try container.decodeIfPresent(String.self, forKey: .isTrashed)
        self.entitydata = try container.decodeIfPresent([SIFeedsDetailEntityData].self, forKey: .entitydata)
        
        self.showCopyright = try container.decodeIfPresent(String.self, forKey: .showCopyright)
        self.showInWeb = try container.decodeIfPresent(String.self, forKey: .showInWeb)
        self.showInMobile = try container.decodeIfPresent(String.self, forKey: .showInMobile)
        self.contentSourceLink = try container.decodeIfPresent(String.self, forKey: .contentSourceLink)
        
        self.imageFileName = try container.decodeIfPresent(String.self, forKey: .imageFileName)
        self.imagePath = try container.decodeIfPresent(String.self, forKey: .imagePath)
        self.imageID = try container.decodeIfPresent(String.self, forKey: .imageID)
        self.checkedOutBy = try container.decodeIfPresent(String.self, forKey: .checkedOutBy)
        self.checkedOutByName = try container.decodeIfPresent(String.self, forKey: .checkedOutByName)
        
        self.contentProviderName = try container.decodeIfPresent(String.self, forKey: .contentProviderName)
        self.contentProviderLogo = try container.decodeIfPresent(String.self, forKey: .contentProviderLogo)
        self.createdByName = try container.decodeIfPresent(String.self, forKey: .createdByName)
        self.imagedata = try container.decodeIfPresent(String.self, forKey: .imagedata)
        self.focusByKeywords = try container.decodeIfPresent([SIFeedsDetailFocusByKeyword].self, forKey: .focusByKeywords)
        self.parentArticleID = try container.decodeIfPresent(String.self, forKey: .parentArticleID)
        
        self.parentArticleTitle = try container.decodeIfPresent(String.self, forKey: .parentArticleTitle)
        self.editedByName = try container.decodeIfPresent(String.self, forKey: .editedByName)
        self.isLiveBlog = try container.decodeIfPresent(String.self, forKey: .isLiveBlog)
        self.assetTypeID = try container.decodeIfPresent(String.self, forKey: .assetTypeID)
        self.chkSendNotification = try container.decodeIfPresent(Bool.self, forKey: .chkSendNotification)
        
        self.league = try container.decodeIfPresent(String.self, forKey: .league)
        self.isFeaturedImage = try container.decodeIfPresent(String.self, forKey: .isFeaturedImage)
        self.isDefaultImage = try container.decodeIfPresent(String.self, forKey: .isDefaultImage)
        self.albumId = try container.decodeIfPresent(Int.self, forKey: .albumId)
        self.albumDesc = try container.decodeIfPresent(String.self, forKey: .albumDesc)
        self.albumType = try container.decodeIfPresent(String.self, forKey: .albumType)
        
        self.images = try container.decodeIfPresent([SIFeedsDetailImagesData].self, forKey: .images)
        self.relatedData = try container.decodeIfPresent(SIFeedsDetailNextPrev.self, forKey: .relatedData)
        self.hlsVideoUrl = try container.decodeIfPresent(String.self, forKey: .hlsVideoUrl)
        self.relatedItems = try container.decodeIfPresent([SIFeedsListingItem].self, forKey: .relatedItems)
        self.coverDetails = try container.decodeIfPresent(SIFeedsDetailCoverDetails.self, forKey: .coverDetails)
        self.additionalInfo = try container.decodeIfPresent(SIFeedsDetailAdditionalInfo.self, forKey: .additionalInfo)
        
        do {
            self.videoId = try container.decodeIfPresent(String.self, forKey: .videoId)
        } catch {
            let numberName = try container.decode(Int.self, forKey: .videoId)
            self.videoId = String(numberName)
        }
    }
}

// MARK: - FocusByKeyword
public struct SIFeedsDetailFocusByKeyword: Codable {
    let id, slno: Int?
    let text, assetID: String?
    let priority: Int?
    let selected: Bool?
    let entityName, canonicalURL: String?
    let entDispName: String?
    let entityTypeID: String?
    let entityMasterID: Int?
    let entityTypeName, sourceObjectID: String?
    let entityOtherNames: [String]?
    let entityRoleMapID, entityDisplayName: String?
    
    enum CodingKeys: String, CodingKey {
        case id, slno, text
        case assetID = "asset_id"
        case priority, selected
        case entityName = "entity_name"
        case canonicalURL = "canonical_url"
        case entDispName = "ent_disp_name"
        case entityTypeID = "entity_type_id"
        case entityMasterID = "entity_master_id"
        case entityTypeName = "entity_type_name"
        case sourceObjectID = "source_object_id"
        case entityOtherNames = "entity_other_names"
        case entityRoleMapID = "entity_role_map_id"
        case entityDisplayName = "entity_display_name"
    }
}

// MARK: - CoverDetails
public struct SIFeedsDetailCoverDetails: Codable {
    let url: String?
    let type: Int?
    let embededCode: String?
    let brightCodeVideoID: String?
    let wall: SIFeedsDetailCoverDetailsWall?
    
    enum CodingKeys: String, CodingKey {
        case url = "Url"
        case type = "Type"
        case embededCode = "Embed"
        case brightCodeVideoID = "VideoId"
        case wall
    }
}

enum SIFeedsDetailCoverDetailsWall: String, Codable {
    case subscriptionWall = "subscription_wall"
    case free = "free"
    case blank = ""
}

// MARK: - SIFeedsDetailEntityData
public struct SIFeedsDetailEntityData: Codable {
    public let priority, entityRoleMapID: Int?
    public let name: String?
    public let isVisible, isLinkable: String?
    public let assetID: Int?
    public let entDispName: String?
    public let isLang: String?
    public let canonical: String?
    public let contentCount: Int?
    public let entityTypeName: String?
    public let entityTypeId: Int?
    
    enum CodingKeys: String, CodingKey {
        case priority
        case entityRoleMapID = "entity_role_map_id"
        case name
        case isLinkable = "is_linkable"
        case isVisible = "is_visible"
        case assetID = "asset_id"
        case entDispName = "ent_disp_name"
        case isLang = "is_lang"
        case canonical
        case contentCount = "content_count"
        case entityTypeName = "entity_type_name"
        case entityTypeId = "entity_type_id"
    }
}

// MARK: - SIFeedsDetailImagesData
public struct SIFeedsDetailImagesData: Codable {
    public let data: SIFeedsDetailImageItem?
}

// MARK: - SIFeedsDetailImageItem
public struct SIFeedsDetailImageItem: Codable {
    public let title: String?
    public let status, imageID, isCover, imageName: String?
    public let imagePath: String?
    public let imageAlt: String?
    public let isActive, isDelete: String?
    public let imageDesc: String?
    public let phototypeid, positionID: Int?
    public let orderNumber: String?
    public let imageCaption: String?
    public let mobileImageID: String?
    public let imageCopyright: String?
    public let mobileImageName, mobileImagePath: String?
    
    enum CodingKeys: String, CodingKey {
        case title, status
        case imageID = "image_id"
        case isCover = "is_cover"
        case imageName, imagePath
        case imageAlt = "image_alt"
        case isActive = "is_active"
        case isDelete = "is_delete"
        case imageDesc = "image_desc"
        case phototypeid
        case positionID = "position_id"
        case orderNumber = "order_number"
        case imageCaption = "image_caption"
        case mobileImageID
        case imageCopyright = "image_copyright"
        case mobileImageName, mobileImagePath
    }
}

public struct SIFeedsDetailNextPrev: Codable {
    public let items: [SIFeedsListingItem]?
}

public struct SIFeedsDetailMeta: Codable {
    public let pagination: SIFeedsDetailPagination?
    public let message: String?
    
    enum CodingKeys: String, CodingKey {
        case pagination
        case message
    }
}

public struct SIFeedsDetailPagination: Codable {
    public let total, count, perPage, currentPage: Int?
    public let totalPages: Int?
    public let links: String?
    enum CodingKeys: String, CodingKey {
        case total
        case count
        case perPage
        case currentPage
        case totalPages
        case links
    }
}

// MARK: - AdditionalInfo
public struct SIFeedsDetailAdditionalInfo: Codable {
    public let customFieldValues: CustomFieldValues?
    
    enum CodingKeys: String, CodingKey {
        case customFieldValues = "custom_field_values"
    }
}

// MARK: - CustomFieldValues
public struct CustomFieldValues: Codable {
    let wall: SIFeedsDetailCoverDetailsWall?
    let branding, location, geoblockRestriction: String?
    let arenaMatchId: String?
    
    enum CodingKeys: String, CodingKey {
        case wall, branding, location
        case arenaMatchId = "arena_match_id"
        case geoblockRestriction = "geoblock_restriction"
    }
}
