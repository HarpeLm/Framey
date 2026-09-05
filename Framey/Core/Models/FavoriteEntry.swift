//
//  FavoriteEntry.swift
//  Framey
//
//  Created by Fabian Dargaud on 05/09/2026.
//

import Foundation
import SwiftData

@Model
final class FavoriteEntry {
    var mediaId: Int
    var mediaTypeRaw: String = "movie"
    var title: String = ""
    var posterPath: String?
    var position: Int = 0
    
    var mediaType: MediaType {
        get { MediaType(rawValue: mediaTypeRaw) ?? .movie }
        set { mediaTypeRaw = newValue.rawValue }
    }
    
    init(mediaId: Int, mediaType: MediaType = .movie, title: String = "", posterPath: String? = nil, position: Int = 0) {
        self.mediaId = mediaId
        self.mediaTypeRaw = mediaType.rawValue
        self.title = title
        self.posterPath = posterPath
        self.position = position
    }
}

extension FavoriteEntry {
    var asMediaItem: MediaItemEntity {
        MediaItemEntity(id: mediaId, mediaType: mediaType, title: title, posterPath: posterPath)
    }
}
