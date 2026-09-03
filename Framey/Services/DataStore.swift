//
//  DataStore.swift
//  Framey
//
//  Created by Fabian Dargaud on 03/09/2026.
//
import Foundation
import SwiftData

@Model
final class MovieEntity {
    var id: Int
    var title: String
    var releaseDate: Date?
    var posterPath: String?
    var backdropPath: String?
    var overview: String
    
    init(id: Int, title: String, releaseDate: Date? = nil, posterPath: String? = nil, backdropPath: String? = nil, overview: String = "") {
        self.id = id
        self.title = title
        self.releaseDate = releaseDate
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.overview = overview
    }
}
