//
//  GifsModel.swift
//  KKR App
//
//  Created by Vishal Thakur on 11/09/23.
//

import Foundation

// MARK: - GifsData
struct GifsData : Codable{
    var data: [GifyData]?
    var pagination: GifsPagination?
    var meta: GifsMeta?
}

// MARK: - Datum
struct GifyData : Codable{
    var type: String?
    var id: String?
    var url: String?
    var slug: String?
    var bitlyGIFURL, bitlyURL: String?
    var embedURL: String?
    var username: String?
    var source: String?
    var title: String?
    var rating: String?
    var contentURL, sourceTLD: String?
    var sourcePostURL: String?
    var isSticker: Int?
    var importDatetime, trendingDatetime: String?
    var images: GifsImages?
    var user: GifsUser?
    var analyticsResponsePayload: String?
    var analytics: GifsAnalytics?
    
    enum CodingKeys: String, CodingKey {
           case type, id, url, slug
           case bitlyGIFURL = "bitly_gif_url"
           case bitlyURL = "bitly_url"
           case embedURL = "embed_url"
           case username, source, title, rating
           case contentURL = "content_url"
           case sourceTLD = "source_tld"
           case sourcePostURL = "source_post_url"
           case isSticker = "is_sticker"
           case importDatetime = "import_datetime"
           case trendingDatetime = "trending_datetime"
           case images, user
           case analyticsResponsePayload = "analytics_response_payload"
           case analytics
       }
}

// MARK: - Analytics
struct GifsAnalytics : Codable{
    var onload, onclick, onsent: Onclick?
}

// MARK: - Onclick
struct Onclick : Codable {
    var url: String?
}

// MARK: - Images
struct GifsImages : Codable {
    var original: GifsFixedHeight?
    var downsized, downsizedLarge, downsizedMedium: The480_WStill?
    var downsizedSmall: The4_K?
    var downsizedStill: The480_WStill?
    var fixedHeight, fixedHeightDownsampled, fixedHeightSmall: GifsFixedHeight?
    var fixedHeightSmallStill, fixedHeightStill: The480_WStill?
    var fixedWidth, fixedWidthDownsampled, fixedWidthSmall: GifsFixedHeight?
    var fixedWidthSmallStill, fixedWidthStill: The480_WStill?
    var looping: GifsLooping?
    var originalStill: The480_WStill?
    var originalMp4, preview: The4_K?
    var previewGIF, previewWebp, the480WStill: The480_WStill?
    var hd, the4K: The4_K?
    
    enum CodingKeys: String, CodingKey {
        case original, downsized
        case downsizedLarge = "downsized_large"
        case downsizedMedium = "downsized_medium"
        case downsizedSmall = "downsized_small"
        case downsizedStill = "downsized_still"
        case fixedHeight = "fixed_height"
        case fixedHeightDownsampled = "fixed_height_downsampled"
        case fixedHeightSmall = "fixed_height_small"
        case fixedHeightSmallStill = "fixed_height_small_still"
        case fixedHeightStill = "fixed_height_still"
        case fixedWidth = "fixed_width"
        case fixedWidthDownsampled = "fixed_width_downsampled"
        case fixedWidthSmall = "fixed_width_small"
        case fixedWidthSmallStill = "fixed_width_small_still"
        case fixedWidthStill = "fixed_width_still"
        case looping
        case originalStill = "original_still"
        case originalMp4 = "original_mp4"
        case preview
        case previewGIF = "preview_gif"
        case previewWebp = "preview_webp"
        case the480WStill = "480w_still"
        case hd
        case the4K = "4k"
    }
}
// MARK: - The480_WStill
struct The480_WStill : Codable{
    var height, width, size: String?
    var url: String?
}

// MARK: - The4_K
struct The4_K : Codable {
    var height, width, mp4Size: String?
    var mp4: String?
    
    enum CodingKeys: String, CodingKey {
          case height, width
          case mp4Size = "mp4_size"
          case mp4
      }
}

// MARK: - FixedHeight
struct GifsFixedHeight : Codable{
    var height, width, size: String?
    var url: String?
    var mp4Size: String?
    var mp4: String?
    var webpSize: String?
    var webp: String?
    var frames, hash: String?
    
    enum CodingKeys: String, CodingKey {
            case height, width, size, url
            case mp4Size = "mp4_size"
            case mp4
            case webpSize = "webp_size"
            case webp, frames, hash
        }
}

// MARK: - Looping
struct GifsLooping : Codable{
    var mp4Size: String?
    var mp4: String?
    
    enum CodingKeys: String, CodingKey {
           case mp4Size = "mp4_size"
           case mp4
       }
}

enum Rating: String {
    case g
}

enum TypeEnum: String {
    case gif
}

// MARK: - User
struct GifsUser  : Codable{
    var avatarURL, bannerImage, bannerURL: String?
    var profileURL: String?
    var username, displayName, description: String?
    var instagramURL: String?
    var websiteURL: String?
    var isVerified: Bool?
    
    enum CodingKeys: String, CodingKey {
          case avatarURL = "avatar_url"
          case bannerImage = "banner_image"
          case bannerURL = "banner_url"
          case profileURL = "profile_url"
          case username
          case displayName = "display_name"
          case description
          case instagramURL = "instagram_url"
          case websiteURL = "website_url"
          case isVerified = "is_verified"
      }
}

// MARK: - Meta
struct GifsMeta  : Codable{
    var status: Int?
    var msg, responseID: String?
    
    enum CodingKeys: String, CodingKey {
            case status, msg
            case responseID = "response_id"
        }
}

// MARK: - Pagination
struct GifsPagination : Codable{
    var totalCount, count, offset: Int?
    
    enum CodingKeys: String, CodingKey {
            case totalCount = "total_count"
            case count, offset
        }
}
