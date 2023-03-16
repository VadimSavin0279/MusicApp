//
//  ModelForSearch.swift
//  AppleMusicClone
//
//  Created by 123 on 10.11.2022.
//

import Foundation

struct ResultOfSearch: Codable {
    let resultCount: Int
    let results: [Track]
}

struct Track: Codable, Equatable, Identifiable {
    var id = UUID()
    let trackName: String
    let collectionName: String?
    let artistName: String
    let iconUrlString: String?
    let audioUrl: String
    
    enum CodingKeys: String, CodingKey {
        case trackName = "trackName"
        case collectionName = "collectionName"
        case artistName = "artistName"
        case iconUrlString = "artworkUrl100"
        case audioUrl = "previewUrl"
    }
}
