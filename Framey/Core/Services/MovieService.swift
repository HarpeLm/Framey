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

struct TMDBPerson: Decodable {
    let id: Int
    let name: String
    let profile_path: String?
}

struct TMDBPersonResponse: Decodable {
    let results: [TMDBPerson]
}

struct TMDBTV: Decodable {
    let id: Int
    let name: String
    let first_air_date: String?
    let poster_path: String?
    let backdrop_path: String?
    let overview: String
}

struct TMDBTVResponse: Decodable {
    let results: [TMDBTV]
}

enum MovieService {

    // MARK: - Films

    static func fetchPopularMovies() async throws -> [MediaItemEntity] {
        async let page1 = fetchPopularPage(1)
        async let page2 = fetchPopularPage(2)
        async let page3 = fetchPopularPage(3)
        let (p1, p2, p3) = try await (page1, page2, page3)
        return p1 + p2 + p3
    }
    
    static func fetchMovie(id: Int) async throws -> MediaItemEntity {
        let urlString = "https://api.themoviedb.org/3/movie/\(id)?api_key=\(Secrets.tmdbApiKey)&language=fr-FR"
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.serverError
        }
        
        let movie = try JSONDecoder().decode(TMDBMovie.self, from: data)
        return MediaItemEntity(
            id: movie.id,
            title: movie.title,
            releaseDate: movie.release_date?.toDate(),
            posterPath: movie.poster_path,
            backdropPath: movie.backdrop_path,
            overview: movie.overview
        )
    }
    
    static func fetchTopRatedMovies() async throws -> [MediaItemEntity] {
        let urlString = "https://api.themoviedb.org/3/movie/top_rated?api_key=\(Secrets.tmdbApiKey)&language=fr-FR&page=1"
        return try await fetchMovies(urlString: urlString)
    }

    static func fetchRecommendations(for id: Int) async throws -> [MediaItemEntity] {
        let urlString = "https://api.themoviedb.org/3/movie/\(id)/recommendations?api_key=\(Secrets.tmdbApiKey)&language=fr-FR&page=1"
        return try await fetchMovies(urlString: urlString)
    }

    private static func fetchPopularPage(_ page: Int) async throws -> [MediaItemEntity] {
        let urlString = "https://api.themoviedb.org/3/movie/popular?api_key=\(Secrets.tmdbApiKey)&language=fr-FR&page=\(page)"
        return try await fetchMovies(urlString: urlString)
    }

    static func fetchNowPlaying(region: String) async throws -> [MediaItemEntity] {
        async let page1 = fetchMovies(urlString: nowPlayingURL(page: 1, region: region))
        async let page2 = fetchMovies(urlString: nowPlayingURL(page: 2, region: region))
        let (p1, p2) = try await (page1, page2)
        var seen = Set<Int>()
        return (p1 + p2).filter { seen.insert($0.id).inserted }
    }

    private static func nowPlayingURL(page: Int, region: String) -> String {
        "https://api.themoviedb.org/3/movie/now_playing?api_key=\(Secrets.tmdbApiKey)&language=fr-FR&region=\(region)&page=\(page)"
    }

    static func searchMovies(query: String) async throws -> [MediaItemEntity] {
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw NetworkError.invalidURL
        }
        let urlString = "https://api.themoviedb.org/3/search/movie?api_key=\(Secrets.tmdbApiKey)&language=fr-FR&query=\(encoded)"
        return try await fetchMovies(urlString: urlString)
    }

    static func searchPeople(query: String) async throws -> [TMDBPerson] {
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw NetworkError.invalidURL
        }
        let urlString = "https://api.themoviedb.org/3/search/person?api_key=\(Secrets.tmdbApiKey)&language=fr-FR&query=\(encoded)"
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.serverError
        }
        
        return try JSONDecoder().decode(TMDBPersonResponse.self, from: data).results
    }

    private static func fetchMovies(urlString: String) async throws -> [MediaItemEntity] {
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
            MediaItemEntity(
                id: movie.id,
                title: movie.title,
                releaseDate: movie.release_date?.toDate(),
                posterPath: movie.poster_path,
                backdropPath: movie.backdrop_path,
                overview: movie.overview
            )
        }
    }

    static func fetchMovieDetails(id: Int) async throws -> MovieDetails {
        let urlString = "https://api.themoviedb.org/3/movie/\(id)?api_key=\(Secrets.tmdbApiKey)&language=fr-FR&append_to_response=credits"

        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.serverError
        }

        return try JSONDecoder().decode(MovieDetails.self, from: data)
    }

    static func fetchWatchProviders(id: Int, region: String) async throws -> [WatchProvider] {
        let urlString = "https://api.themoviedb.org/3/movie/\(id)/watch/providers?api_key=\(Secrets.tmdbApiKey)"

        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.serverError
        }

        let decoded = try JSONDecoder().decode(WatchProvidersResponse.self, from: data)
        let providers = decoded.results[region]?.flatrate ?? []
        return providers.sorted { ($0.display_priority ?? 999) < ($1.display_priority ?? 999) }
    }

    // MARK: - Séries (TMDB /tv)

    static func fetchPopularTV() async throws -> [MediaItemEntity] {
        let urlString = "https://api.themoviedb.org/3/tv/popular?api_key=\(Secrets.tmdbApiKey)&language=fr-FR&page=1"
        return try await fetchTV(urlString: urlString)
    }

    static func fetchOnTheAirTV(region: String) async throws -> [MediaItemEntity] {
        let urlString = "https://api.themoviedb.org/3/tv/on_the_air?api_key=\(Secrets.tmdbApiKey)&language=fr-FR&region=\(region)&page=1"
        return try await fetchTV(urlString: urlString)
    }

    static func fetchTopRatedTV() async throws -> [MediaItemEntity] {
        let urlString = "https://api.themoviedb.org/3/tv/top_rated?api_key=\(Secrets.tmdbApiKey)&language=fr-FR&page=1"
        return try await fetchTV(urlString: urlString)
    }

    static func searchTV(query: String) async throws -> [MediaItemEntity] {
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw NetworkError.invalidURL
        }
        let urlString = "https://api.themoviedb.org/3/search/tv?api_key=\(Secrets.tmdbApiKey)&language=fr-FR&query=\(encoded)"
        return try await fetchTV(urlString: urlString)
    }

    static func fetchTVDetails(id: Int) async throws -> TVDetails {
        let urlString = "https://api.themoviedb.org/3/tv/\(id)?api_key=\(Secrets.tmdbApiKey)&language=fr-FR"

        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.serverError
        }

        return try JSONDecoder().decode(TVDetails.self, from: data)
    }
    
    static func fetchTVSeason(seriesId: Int, seasonNumber: Int) async throws -> TVSeason {
        let urlString = "https://api.themoviedb.org/3/tv/\(seriesId)/season/\(seasonNumber)?api_key=\(Secrets.tmdbApiKey)&language=fr-FR"
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.serverError
        }
        
        return try JSONDecoder().decode(TVSeason.self, from: data)
    }

    private static func fetchTV(urlString: String) async throws -> [MediaItemEntity] {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.serverError
        }

        let result = try JSONDecoder().decode(TMDBTVResponse.self, from: data)

        return result.results.map { tv in
            MediaItemEntity(
                id: tv.id,
                mediaType: .tv,
                title: tv.name,
                releaseDate: tv.first_air_date?.toDate(),
                posterPath: tv.poster_path,
                backdropPath: tv.backdrop_path,
                overview: tv.overview
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
