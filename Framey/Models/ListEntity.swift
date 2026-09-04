//
//  ListEntity.swift
//  Framey
//
//  Created by Fabian Dargaud on 03/09/2026.
//

import Foundation
import SwiftData

@Model
final class ListEntity {
    var name: String
    var dateCreated: Date
    @Relationship(deleteRule: .cascade, inverse: \ListItemEntry.list)
    var items: [ListItemEntry]
    
    init(name: String, dateCreated: Date = .now, items: [ListItemEntry] = []) {
        self.name = name
        self.dateCreated = dateCreated
        self.items = items
    }
}

@Model
final class ListItemEntry {
    var mediaId: Int
    var mediaTypeRaw: String
    var title: String
    var posterPath: String?
    var dateAdded: Date
    var list: ListEntity?
    
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

extension ListItemEntry {
    var asMediaItem: MediaItemEntity {
        MediaItemEntity(id: mediaId, mediaType: mediaType, title: title, posterPath: posterPath)
    }
}
