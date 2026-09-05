//
//  TVSeason.swift
//  Framey
//
//  Created by Fabian Dargaud on 05/09/2026.
//

import Foundation

struct TVSeason: Decodable {
    let season_number: Int
    let name: String
    let episodes: [TVEpisode]
}

struct TVEpisode: Decodable {
    let episode_number: Int
    let name: String
    let still_path: String?
    let air_date: String?
    let overview: String
}

extension TVEpisode: Identifiable {
    var id: Int { episode_number }
}
