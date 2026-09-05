//
//  TVDetails.swift
//  Framey
//
//  Created by Fabian Dargaud on 05/09/2026.
//

import Foundation

struct TVDetails: Decodable {
    let id: Int
    let name: String
    let overview: String
    let poster_path: String?
    let backdrop_path: String?
    let first_air_date: String?
    let vote_average: Double
    let vote_count: Int
    let number_of_seasons: Int
    let number_of_episodes: Int
    let genres: [Genre]
    
    var genreNames: String {
        genres.map(\.name).joined(separator: ", ")
    }
}
