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
    private(set) var weekReleases: [MediaItemEntity] = []
    private(set) var isLoading = false
    
    func load() async {
        isLoading = true
        defer { isLoading = false }
        let region = Locale.current.region?.identifier ?? "FR"
        
        async let popularResult = MovieService.fetchPopularMovies()
        async let releasesResult = MovieService.fetchWeekReleases(region: region)
        
        allPopular = (try? await popularResult) ?? []
        weekReleases = (try? await releasesResult) ?? []
    }
    
    func featuredMovies(excludingWatchedIds watchedIds: Set<Int>) -> [MediaItemEntity] {
        allPopular
            .filter { !watchedIds.contains($0.id) }
            .prefix(5)
            .map { $0 }
    }
    
    // MARK: - Semaine cinéma
    
    var weekDays: [Date] {
        let calendar = Calendar.current
        guard let start = calendar.dateInterval(of: .weekOfYear, for: .now)?.start else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }
    
    func releases(on day: Date) -> [MediaItemEntity] {
        weekReleases.filter { movie in
            guard let date = movie.releaseDate else { return false }
            return Calendar.current.isDate(date, inSameDayAs: day)
        }
    }
    
    func hasReleases(on day: Date) -> Bool {
        !releases(on: day).isEmpty
    }
}
