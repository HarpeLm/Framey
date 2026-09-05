//
//  SeriesModelView.swift
//  Framey
//
//  Created by Fabian Dargaud on 05/09/2026.
//

import Foundation
import Observation

@Observable
final class SeriesViewModel {
    private(set) var popular: [MediaItemEntity] = []
    private(set) var onTheAir: [MediaItemEntity] = []
    private(set) var topRated: [MediaItemEntity] = []
    private(set) var isLoading = false
    
    func load() async {
        isLoading = true
        defer { isLoading = false }
        let region = Locale.current.region?.identifier ?? "FR"
        
        async let popularResult = MovieService.fetchPopularTV()
        async let onTheAirResult = MovieService.fetchOnTheAirTV(region: region)
        async let topRatedResult = MovieService.fetchTopRatedTV()
        
        popular = (try? await popularResult) ?? []
        onTheAir = (try? await onTheAirResult) ?? []
        topRated = (try? await topRatedResult) ?? []
    }
}
