//
//  MovieDetailViewModel.swift
//  Framey
//
//  Created by Fabian Dargaud on 03/09/2026.
//

import Foundation
import Observation

@Observable
final class MovieDetailViewModel {
    private(set) var details: MovieDetails?
    private(set) var providers: [WatchProvider] = []
    
    var director: String? {
        details?.credits.crew.first { $0.job == "Director" }?.name
    }
    
    var runtimeText: String {
        guard let runtime = details?.runtime, runtime > 0 else { return "—" }
        return "\(runtime / 60)h \(runtime % 60)min"
    }
    
    var genreNames: String {
        details?.genres.map(\.name).joined(separator: ", ") ?? "—"
    }
    
    var averageRatingText: String {
        guard let avg = details?.vote_average, avg > 0 else { return "—" }
        return String(format: "%.1f", avg)
    }
    
    var voteCountText: String {
        guard let count = details?.vote_count, count > 0 else { return "" }
        return "(\(count.formatted()) notes)"
    }
    
    func loadDetails(id: Int) async {
        let region = Locale.current.region?.identifier ?? "FR"
        
        async let detailsResult = MovieService.fetchMovieDetails(id: id)
        async let providersResult = MovieService.fetchWatchProviders(id: id, region: region)
        
        details = try? await detailsResult
        providers = (try? await providersResult) ?? []
    }
}
