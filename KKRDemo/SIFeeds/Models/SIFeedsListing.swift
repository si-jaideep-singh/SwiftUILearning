//
//  SIFeedsListing.swift
//  SIFeedsListing
//
//  Created by Siddharth Daga on 4/10/19.
//  Copyright © 2019 Sportz Interactive. All rights reserved.
//

import Foundation

public struct SIFeedsListingModel: Codable {
    public var status: Int?
    public var content: SIFeedsListingContent?
    public var imagesData, authodata, nextPrev, entityData: String?
    public var relatedArticle, message: String?
    public var meta: SIFeedsListingMeta?
    
    enum CodingKeys: String, CodingKey {
        case status
        case content
        case imagesData = "ImagesData"
        case authodata = "Authodata"
        case nextPrev = "NextPrev"
        case entityData = "EntityData"
        case relatedArticle = "RelatedArticle"
        case message, meta
    }
}

public struct SIFeedsListingContent: Codable {
    public let items: [SIFeedsListingItem]?
    public let entitydata: [SIFeedsListingEntitydatum]?
}

public struct SIFeedsListingEntitydatum: Codable {
    public let name, canonicalURL: String?
    public let entityRoleMapID: Int?
    
    enum CodingKeys: String, CodingKey {
        case name
        case canonicalURL = "canonical_url"
        case entityRoleMapID = "entity_role_map_id"
    }
}

public struct SIFeedsListingItem: Codable, ContainsTitleAlias {
    public let rno: Int?
    public let duration: String?
    public let assetID: Int?
    public let authorID: Int?
    public let fullName: String?
    public let isActive: Int?
    public let userName: String?
    public let assetGUID: String?
    public let videoUrl: String?
    public let audioURL: String?
    public let createdBy: Int?
    public let imagePath: String?
    public let isDeleted, isTrashed: Int?
    public let shortDesc: String?
    public let updatedBy: Int?
    public let assetTitle: String?
    public var titleAlias, createdDate: String?
    public let displayName: String?
    public let isPublished: Int?
    public let totalAssets: Int?
    public let updatedDate: String?
    public let assetListID: Int?
    public let assetTypeID: SIFeedsAssetType?
    public let publishedDate: String?
    public let imageFileName: String?
    public let priEntDispName: String?
    public let secEntDispName: String?
    public let primaryEntityName: String?
    public let secondaryEntityName: String?
    public let secondaryEntityUrl: String?
    public let publishedVersionNumber, primaryEntityRoleMapID, secondaryEntityRoleMapID: Int?
    public let contentSourceID, contentProviderName, slugUrl: String?
    var focusByKeyword: [SIFeedsDetailFocusByKeyword]?
    
    var assetReactionID: String {
        return "\(self.assetID ?? 0)_\(self.assetTypeID?.rawValue ?? 0)"
    }
    
    enum CodingKeys: String, CodingKey {
        case rno, duration
        case assetID = "asset_id"
        case authorID = "author_id"
        case fullName = "full_name"
        case isActive = "is_active"
        case userName = "user_name"
        case assetGUID = "asset_guid"
        case videoUrl = "video_url"
        case audioURL = "audio_url"
        case createdBy = "created_by"
        case imagePath = "image_path"
        case isDeleted = "is_deleted"
        case isTrashed = "is_trashed"
        case shortDesc = "short_desc"
        case updatedBy = "updated_by"
        case assetTitle = "asset_title"
        case titleAlias = "title_alias"
        case createdDate = "created_date"
        case displayName = "display_name"
        case isPublished = "is_published"
        case totalAssets = "total_assets"
        case updatedDate = "updated_date"
        case assetListID = "asset_list_id"
        case assetTypeID = "asset_type_id"
        case publishedDate = "published_date"
        case imageFileName = "image_file_name"
        case priEntDispName = "pri_ent_disp_name"
        case secEntDispName = "sec_ent_disp_name"
        case primaryEntityName = "primary_entity_name"
        case secondaryEntityName = "secondary_entity_name"
        case publishedVersionNumber = "published_version_number"
        case primaryEntityRoleMapID = "primary_entity_role_map_id"
        case secondaryEntityRoleMapID = "secondary_entity_role_map_id"
        case secondaryEntityUrl = "sec_ent_url"
        case contentSourceID = "content_source_id"
        case contentProviderName = "content_provider_name"
        case focusByKeyword = "focus_by_keywords"
        case slugUrl = "slug_url"
    }
}

public struct SIFeedsListingMeta: Codable {
    public let pagination: SIFeedsListingPagination?
    public let message: String?
}

public struct SIFeedsListingPagination: Codable {
    public let total, count, perPage, currentPage: Int?
    public let totalPages: Int?
    
    enum CodingKeys: String, CodingKey {
        case total, count
        case perPage = "per_page"
        case currentPage = "current_page"
        case totalPages = "total_pages"
    }
}
