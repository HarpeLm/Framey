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
    
    func loadDetails(id: Int) async {
        details = try? await MovieService.fetchMovieDetails(id: id)
    }
}
