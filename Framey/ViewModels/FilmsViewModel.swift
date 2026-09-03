//
//  FilmsViewModel.swift
//  Framey
//
//  Created by Fabian Dargaud on 03/09/2026.
//

import Foundation
import Observation

@Observable
final class FilmsViewModel {
    
    // MARK: - État public (observé par la vue)
    var movies: [MovieEntity] = []
    var isLoading: Bool = false
    var errorMessage: String?
    
    // MARK: - Actions
    func loadPopularMovies() async {
        isLoading = true
        errorMessage = nil
        
        do {
            movies = try await MovieService.fetchPopularMovies()
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Erreur ViewModel :", error)
        }
        
        isLoading = false
    }
}
