//
//  TMDBImageURL.swift.swift
//  Framey
//
//  Created by Fabian Dargaud on 03/09/2026.
//

import Foundation

extension String {
    func tmdbPosterURL(size: TMDBImageSize = .w500) -> URL? {
        let baseURL = "https://image.tmdb.org/t/p/\(size.rawValue)"
        return URL(string: baseURL + self)
    }
}

enum TMDBImageSize: String {
    case w92 = "w92"
    case w154 = "w154"
    case w185 = "w185"
    case w342 = "w342"
    case w500 = "w500"
    case w780 = "w780"
    case original = "original"
}
