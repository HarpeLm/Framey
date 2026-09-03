//
//  HomeView.swift
//  Framey
//
//  Created by Fabian Dargaud on 03/09/2026.
//

import SwiftUI

struct HomeView: View {

    var body: some View {
        NavigationStack {
            Text("Framey 🎬")
                .navigationTitle("Accueil")
        }
        .task {
            await testTMDB()
        }
    }

    private func testTMDB() async {
        do {
            let movies = try await MovieService.fetchPopularMovies()
            print("✅ \(movies.count) films reçus")
            for movie in movies {
                print("🎬 \(movie.title)")
            }
        } catch {
            print("❌ Erreur API :", error)
        }
    }
}

#Preview {
    HomeView()
}
