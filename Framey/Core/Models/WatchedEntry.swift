//
//  WatchedMovie.swift
//  Framey
//
//  Created by Fabian Dargaud on 03/09/2026.
//

import Foundation
import SwiftData

@Model
final class WatchedEntry {
    var mediaId: Int
    var mediaTypeRaw: String
    var title: String = ""
    var posterPath: String?
    var dateWatched: Date
    var rating: Int?                  // Films : 1 à 5 étoiles
    var seriesRating: Double? = nil   // Séries : 0.0 à 10.0
    
    var mediaType: MediaType {
        get { MediaType(rawValue: mediaTypeRaw) ?? .movie }
        set { mediaTypeRaw = newValue.rawValue }
    }
    
    init(mediaId: Int, mediaType: MediaType = .movie, title: String = "", posterPath: String? = nil, dateWatched: Date = .now, rating: Int? = nil) {
        self.mediaId = mediaId
        self.mediaTypeRaw = mediaType.rawValue
        self.title = title
        self.posterPath = posterPath
        self.dateWatched = dateWatched
        self.rating = rating
    }
}

extension WatchedEntry {
    var asMediaItem: MediaItemEntity {
        MediaItemEntity(id: mediaId, mediaType: mediaType, title: title, posterPath: posterPath)
    }
}
