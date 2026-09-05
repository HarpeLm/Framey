//
//  EpisodeWatchEntry.swift
//  Framey
//
//  Created by Fabian Dargaud on 05/09/2026.
//


import Foundation
import SwiftData

@Model
final class EpisodeWatchEntry {
    var seriesId: Int
    var seriesTitle: String = ""
    var posterPath: String?
    var seasonNumber: Int
    var episodeNumber: Int
    var episodeTitle: String = ""
    var rating: Double?  // 0.0 à 10.0
    var dateWatched: Date
    
    init(seriesId: Int, seriesTitle: String = "", posterPath: String? = nil,
         seasonNumber: Int, episodeNumber: Int, episodeTitle: String = "",
         rating: Double? = nil, dateWatched: Date = .now) {
        self.seriesId = seriesId
        self.seriesTitle = seriesTitle
        self.posterPath = posterPath
        self.seasonNumber = seasonNumber
        self.episodeNumber = episodeNumber
        self.episodeTitle = episodeTitle
        self.rating = rating
        self.dateWatched = dateWatched
    }
    
    var label: String {
        "S\(seasonNumber)E\(episodeNumber)\(episodeTitle.isEmpty ? "" : " · \(episodeTitle)")"
    }
}