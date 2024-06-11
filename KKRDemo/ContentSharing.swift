//
//  ContentSharing.swift
//  KKR App
//
//  Created by Nausheen Khan on 06/03/23.
//

import Foundation

// MARK: - ContentSharing
struct ContentSharing: Codable {
    let sharingItems: [ContentSharingItem]?

    enum CodingKeys: String, CodingKey {
        case sharingItems = "sharing_items"
    }
}

// MARK: - ContentSharingItem
struct ContentSharingItem: Codable {
    let id: Int?
    let domainValue: String?

    enum CodingKeys: String, CodingKey {
        case id
        case domainValue = "domain_value"
    }
}
