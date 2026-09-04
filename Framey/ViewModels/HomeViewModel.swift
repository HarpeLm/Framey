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
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    
    func featuredMovies(excludingWatchedIds watchedIds: Set<Int>) -> [MediaItemEntity] {
        allPopular
            .filter { !watchedIds.contains($0.id) }
            .prefix(5)
            .map { $0 }
    }
    
    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            allPopular = try await MovieService.fetchPopularMovies()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
