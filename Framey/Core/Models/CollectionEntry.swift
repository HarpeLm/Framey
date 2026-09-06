//
//  CollectionEntry.swift
//  Framey
//
//  Created by Fabian Dargaud on 06/09/2026.
//


import Foundation
import SwiftData

enum CollectionFormat: String, CaseIterable, Identifiable {
    case dvd = "DVD"
    case bluray = "Blu-ray"
    case numerique = "Numerique"
    case vhs = "VHS"
    var id: String { rawValue }
}

@Model
final class CollectionEntry {
    var mediaId: Int
    var mediaTypeRaw: String = "movie"
    var title: String = ""
    var posterPath: String?
    var formatRaw: String = CollectionFormat.numerique.rawValue
    var dateAdded: Date = Date.now   // ✅ valeur entièrement qualifiée
    
    var mediaType: MediaType {
        get { MediaType(rawValue: mediaTypeRaw) ?? .movie }
        set { mediaTypeRaw = newValue.rawValue }
    }
    
    var format: CollectionFormat {
        get { CollectionFormat(rawValue: formatRaw) ?? .numerique }
        set { formatRaw = newValue.rawValue }
    }
    
    init(mediaId: Int, mediaType: MediaType = .movie, title: String = "", posterPath: String? = nil, format: CollectionFormat = .numerique, dateAdded: Date = .now) {
        self.mediaId = mediaId
        self.mediaTypeRaw = mediaType.rawValue
        self.title = title
        self.posterPath = posterPath
        self.formatRaw = format.rawValue
        self.dateAdded = dateAdded
    }
}

extension CollectionEntry {
    var asMediaItem: MediaItemEntity {
        MediaItemEntity(id: mediaId, mediaType: mediaType, title: title, posterPath: posterPath)
    }
}

