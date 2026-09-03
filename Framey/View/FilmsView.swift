//
//  FilmsView.swift
//  Framey
//
//  Created by Fabian Dargaud on 03/09/2026.
//

import SwiftUI

struct FilmsView: View {
    
    @State private var viewModel = FilmsViewModel()
    
    private let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 12)
    ]
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    loadingView
                } else if let error = viewModel.errorMessage {
                    errorView(message: error)
                } else {
                    moviesGrid
                }
            }
            .navigationTitle("Films populaires")
            .navigationDestination(for: MediaItemEntity.self) { item in
                MovieDetailView(item: item)
            }
            .task {
                await viewModel.loadPopularMovies()
            }
        }
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.5)
            Text("Chargement...")
                .foregroundStyle(.secondary)
        }
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.orange)
            Text("Erreur")
                .font(.headline)
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Réessayer") {
                Task { await viewModel.loadPopularMovies() }
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    private var moviesGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(viewModel.movies, id: \.id) { movie in
                    NavigationLink(value: movie) {
                        MoviePosterCard(movie: movie)
                    }
                    .buttonStyle(.plain) // évite la teinte bleue par défaut du lien
                }
            }
            .padding()
        }
    }
}

struct MoviePosterCard: View {
    let movie: MediaItemEntity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            AsyncImage(url: movie.posterPath?.tmdbPosterURL()) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(.gray.opacity(0.3))
                        .overlay(ProgressView())
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(2/3, contentMode: .fill)
                case .failure:
                    Rectangle()
                        .fill(.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "film")
                                .foregroundStyle(.secondary)
                        )
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 150)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Text(movie.title)
                .font(.caption)
                .lineLimit(2, reservesSpace: true)
                .foregroundStyle(.primary)
        }
    }
}


#Preview {
    FilmsView()
}
