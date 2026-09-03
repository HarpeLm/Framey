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
    #Unique<WatchedEntry>([\.mediaId, \.mediaTypeRaw])
    
    var mediaId: Int
    var mediaTypeRaw: String
    var dateWatched: Date
    var rating: Int?
    
    var mediaType: MediaType {
        get { MediaType(rawValue: mediaTypeRaw) ?? .movie }
        set { mediaTypeRaw = newValue.rawValue }
    }
    
    init(mediaId: Int, mediaType: MediaType = .movie, dateWatched: Date = .now, rating: Int? = nil) {
        self.mediaId = mediaId
        self.mediaTypeRaw = mediaType.rawValue
        self.dateWatched = dateWatched
        self.rating = rating
    }
}
