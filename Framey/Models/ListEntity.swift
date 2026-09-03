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
    var listDescription: String
    var isPublic: Bool
    var dateCreated: Date
    
    @Relationship(deleteRule: .cascade, inverse: \ListItemEntry.list)
    var items: [ListItemEntry] = []
    
    init(name: String, listDescription: String = "", isPublic: Bool = false, dateCreated: Date = .now) {
        self.name = name
        self.listDescription = listDescription
        self.isPublic = isPublic
        self.dateCreated = dateCreated
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
