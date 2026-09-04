//
//  HomeViewModel.swift
//  Framey
//
//  Created by Fabian Dargaud on 04/09/2026.
//

import Foundation
import Observation

@Observable
final class HomeViewModel {
    private(set) var allPopular: [MediaItemEntity] = []
    private(set) var nowPlaying: [MediaItemEntity] = []
    private(set) var isLoading = false
    
    func load() async {
        isLoading = true
        defer { isLoading = false }
        let region = Locale.current.region?.identifier ?? "FR"
        
        async let popularResult = MovieService.fetchPopularMovies()
        async let nowPlayingResult = MovieService.fetchNowPlaying(region: region)
        
        allPopular = (try? await popularResult) ?? []
        nowPlaying = sortedNowPlaying((try? await nowPlayingResult) ?? [])
    }
    
    func featuredMovies(excludingWatchedIds watchedIds: Set<Int>) -> [MediaItemEntity] {
        allPopular
            .filter { !watchedIds.contains($0.id) }
            .prefix(5)
            .map { $0 }
    }
    
    // MARK: - Tri : sorties de la semaine en premier
    
    private func sortedNowPlaying(_ movies: [MediaItemEntity]) -> [MediaItemEntity] {
        movies.sorted { a, b in
            let aNew = a.isReleasedThisWeek
            let bNew = b.isReleasedThisWeek
            if aNew != bNew { return aNew }
            return (a.releaseDate ?? .distantPast) > (b.releaseDate ?? .distantPast)
        }
    }
}
