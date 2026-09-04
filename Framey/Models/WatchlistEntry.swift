//
//  Untitled.swift
//  Framey
//
//  Created by Fabian Dargaud on 03/09/2026.
//

import Foundation
import SwiftData

@Model
final class WatchlistEntry {
    #Unique<WatchlistEntry>([\.mediaId, \.mediaTypeRaw])
    
    var mediaId: Int
    var mediaTypeRaw: String
    var title: String
    var posterPath: String?
    var dateAdded: Date
    
    var mediaType: MediaType {
        get { MediaType(rawValue: mediaTypeRaw) ?? .movie }
        set { mediaTypeRaw = newValue.rawValue }
    }
    
    init(mediaId: Int, mediaType: MediaType = .movie, title: String, posterPath: String? = nil, dateAdded: Date = .now) {
        self.mediaId = mediaId
        self.mediaTypeRaw = mediaType.rawValue
        self.title = title
        self.posterPath = posterPath
        self.dateAdded = dateAdded
    }
}

extension WatchlistEntry {
    var asMediaItem: MediaItemEntity {
        MediaItemEntity(id: mediaId, mediaType: mediaType, title: title, posterPath: posterPath)
    }
}
