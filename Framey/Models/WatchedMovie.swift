//
//  WatchedMovie.swift
//  Framey
//
//  Created by Fabian Dargaud on 03/09/2026.
//
import Foundation
import SwiftData

@Model
final class WatchedMovie {
    @Attribute(.unique) var movieId: Int
    var dateWatched: Date
    var rating: Int?
    
    init(movieId: Int, dateWatched: Date = .now, rating: Int? = nil) {
        self.movieId = movieId
        self.dateWatched = dateWatched
        self.rating = rating
    }
}
