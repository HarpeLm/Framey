//
//  MovieDetailView.swift
//  Framey
//
//  Created by Fabian Dargaud on 03/09/2026.
//

import SwiftUI

struct MovieDetailView: View {
    let movie: MovieEntity
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                backdrop
                
                Text(movie.title)
                    .font(.title2.bold())
                
                if let date = movie.releaseDate {
                    Text(date.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                if !movie.overview.isEmpty {
                    Text("Synopsis")
                        .font(.headline)
                    Text(movie.overview)
                }
            }
            .padding()
        }
        .navigationTitle(movie.title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var backdrop: some View {
        // Color.clear + overlay : empêche l'image en scaledToFill de casser le layout
        Color.clear
            .frame(height: 220)
            .overlay {
                AsyncImage(url: movie.backdropPath?.tmdbPosterURL(size: .w780)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        Image(systemName: "film")
                            .foregroundStyle(.secondary)
                    default:
                        ProgressView()
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    NavigationStack {
        MovieDetailView(movie: MovieEntity(id: 0, title: "Film de test"))
    }
}
