//
//  SIFeedsShowcaseListing.swift
//  Bolts
//
//  Created by Siddharth Daga on 5/20/19.
//

import Foundation

public struct SIFeedsShowcaseListing: Codable {
    public var status: Int?
    public var content: SIFeedsShowcaseContent?

    enum CodingKeys: String, CodingKey {
        case status
        case content
    }
}

// MARK: - SIFeedsShowcaseContent
public struct SIFeedsShowcaseContent: Codable {
    public let data: SIFeedsShowcaseDataClass?
}

// MARK: - SIFeedsShowcaseDataClass
public struct SIFeedsShowcaseDataClass: Codable {
    public let templateComponentMapID, status, isTrashed, updatedBy: String?
    public let publishedDate, guid, count, versionNumber: String?
    public let assetMap: [SIFeedsShowcaseAssetMap]?

    enum CodingKeys: String, CodingKey {
        case templateComponentMapID = "template_component_map_id"
        case status
        case isTrashed = "is_trashed"
        case updatedBy = "updated_by"
        case publishedDate = "published_date"
        case guid, count
        case versionNumber = "version_number"
        case assetMap = "asset_map"
    }
}

// MARK: - SIFeedsShowcaseAssetMap
public struct SIFeedsShowcaseAssetMap: Codable {
    public let assetOrder, assetType, assetID, publishDate: String?
    public let assetMeta: SIFeedsShowcaseAssetMeta?
    public let entitydata: [SIFeedsShowcaseEntitydatum]?
    public let author: [SIFeedsShowcaseAuthor]?
    public let totalAssets: String?

    enum CodingKeys: String, CodingKey {
        case assetOrder = "asset_order"
        case assetType = "asset_type"
        case assetID = "asset_id"
        case publishDate = "publish_date"
        case assetMeta = "asset_meta"
        case entitydata, author
        case totalAssets = "total_assets"
    }
}

// MARK: - SIFeedsShowcaseAssetMeta
public struct SIFeedsShowcaseAssetMeta: Codable {
    public let title, titleAlias, desc: String?
    public let contentType, imageID: String?
    public let imageName, imagePath, responsive, mobImageName: String?
    public let mobImagePath: String?
    public let videoEmbed, url, scoreWicket, assetID: String?
    public let contentSourceID: String?
    public let videoID, duration: String?

    enum CodingKeys: String, CodingKey {
        case title
        case titleAlias = "title_alias"
        case desc
        case contentType = "content_type"
        case imageID = "image_id"
        case imageName = "image_name"
        case imagePath = "image_path"
        case responsive
        case mobImageName = "mob_image_name"
        case mobImagePath = "mob_image_path"
        case videoEmbed = "video_embed"
        case url
        case scoreWicket = "score_wicket"
        case assetID = "asset_id"
        case contentSourceID = "content_source_id"
        case videoID = "video_id"
        case duration
    }
}

// MARK: - SIFeedsShowcaseAuthor
public struct SIFeedsShowcaseAuthor: Codable {
    public let assetID, authorID: String?
    public let authorName, fullName: String?
    public let userName: String?
    public let assetTypeID: String?
    public let contentSourceID, contentProviderName: String?

    enum CodingKeys: String, CodingKey {
        case assetID = "asset_id"
        case authorID = "author_id"
        case authorName = "author_name"
        case fullName = "full_name"
        case userName = "user_name"
        case assetTypeID = "asset_type_id"
        case contentSourceID = "content_source_id"
        case contentProviderName = "content_provider_name"
    }
}

// MARK: - SIFeedsShowcaseEntitydatum
public struct SIFeedsShowcaseEntitydatum: Codable {
    public let priority, entityRoleMapID: String?
    public let name: String?
    public let isLinkable, isVisible, assetID: String?
    public let entDispName: String?
    public let isLang, canonical: String?

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
    }
}
