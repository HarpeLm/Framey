//
//  ReviewEntry.swift
//  Framey
//
//  Created by Fabian Dargaud on 04/09/2026.
//

import Foundation
import SwiftData

@Model
final class ReviewEntry {
    #Unique<ReviewEntry>([\.mediaId, \.mediaTypeRaw])
    
    var mediaId: Int
    var mediaTypeRaw: String
    var text: String
    var dateCreated: Date
    var dateModified: Date
    
    var mediaType: MediaType {
        get { MediaType(rawValue: mediaTypeRaw) ?? .movie }
        set { mediaTypeRaw = newValue.rawValue }
    }
    
    init(mediaId: Int, mediaType: MediaType = .movie, text: String = "", dateCreated: Date = .now) {
        self.mediaId = mediaId
        self.mediaTypeRaw = mediaType.rawValue
        self.text = text
        self.dateCreated = dateCreated
        self.dateModified = dateCreated
    }
}
