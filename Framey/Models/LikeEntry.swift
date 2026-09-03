//
//  LikesEntry.swift
//  Framey
//
//  Created by Fabian Dargaud on 03/09/2026.
//

import Foundation
import SwiftData

@Model
final class LikeEntry {
    #Unique<LikeEntry>([\.mediaId, \.mediaTypeRaw])
    
    var mediaId: Int
    var mediaTypeRaw: String
    var dateLiked: Date
    
    var mediaType: MediaType {
        get { MediaType(rawValue: mediaTypeRaw) ?? .movie }
        set { mediaTypeRaw = newValue.rawValue }
    }
    
    init(mediaId: Int, mediaType: MediaType = .movie, dateLiked: Date = .now) {
        self.mediaId = mediaId
        self.mediaTypeRaw = mediaType.rawValue
        self.dateLiked = dateLiked
    }
}
