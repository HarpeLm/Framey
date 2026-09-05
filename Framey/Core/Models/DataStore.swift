//
//  DataStore.swift
//  Framey
//
//  Created by Fabian Dargaud on 03/09/2026.
//

import Foundation
import SwiftData

@Model
final class MediaItemEntity {
    var id: Int
    var mediaTypeRaw: String
    var title: String
    var releaseDate: Date?
    var posterPath: String?
    var backdropPath: String?
    var overview: String
    
    var mediaType: MediaType {
        get { MediaType(rawValue: mediaTypeRaw) ?? .movie }
        set { mediaTypeRaw = newValue.rawValue }
    }
    
    init(id: Int, mediaType: MediaType = .movie, title: String, releaseDate: Date? = nil, posterPath: String? = nil, backdropPath: String? = nil, overview: String = "") {
        self.id = id
        self.mediaTypeRaw = mediaType.rawValue
        self.title = title
        self.releaseDate = releaseDate
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.overview = overview
    }
}

extension MediaItemEntity {
    var isReleasedThisWeek: Bool {
        guard let date = releaseDate else { return false }
        return Calendar.current.isDate(date, equalTo: .now, toGranularity: .weekOfYear)
    }
}
