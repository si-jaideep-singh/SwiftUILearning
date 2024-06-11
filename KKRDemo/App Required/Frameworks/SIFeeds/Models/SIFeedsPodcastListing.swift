//
//  SIFeedsPodcastListing.swift
//  Bolts
//
//  Created by Siddharth Daga on 5/16/19.
//

import Foundation

public struct SIFeedsPodcastListing: Codable {
    public var status: Int?
    public var content: SIFeedsPodcastListingContent?
    public var meta: SIFeedsListingMeta?

    enum CodingKeys: String, CodingKey {
        case status
        case content
        case meta
    }
}

public struct SIFeedsPodcastListingContent: Codable {
    public var items: [SIFeedsListingItem]?
}
