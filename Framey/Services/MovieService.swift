//
//  MovieService.swift
//  Framey
//
//  Created by Fabian Dargaud on 03/09/2026.
//

import Foundation


struct TMDBResponse: Decodable {
    let results: [TMDBMovie]
}

struct TMDBMovie: Decodable {
    let id: Int
    let title: String
    let release_date: String?
    let poster_path: String?
    let backdrop_path: String?
    let overview: String
}


enum MovieService {

    
    static func fetchPopularMovies() async throws -> [MovieEntity] {

        let apiKey = Secrets.tmdbApiKey
        let urlString = "https://api.themoviedb.org/3/movie/popular?api_key=\(apiKey)&language=fr-FR"
        

        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        

        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.serverError
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.tmdbDateFormatter)
        
        let result = try decoder.decode(TMDBResponse.self, from: data)
        
        return result.results.map { movie in
            MovieEntity(
                id: movie.id,
                title: movie.title,
                releaseDate: movie.release_date?.toDate(),
                posterPath: movie.poster_path,
                backdropPath: movie.backdrop_path,
                overview: movie.overview
            )
        }
    }
}

// MARK: - Extensions utilitaires
extension DateFormatter {
    static var tmdbDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
}

extension String {
    func toDate() -> Date? {
        DateFormatter.tmdbDateFormatter.date(from: self)
    }
}

// MARK: - Gestion des erreurs réseau
enum NetworkError: Error {
    case invalidURL
    case serverError
    case decodingError
}
