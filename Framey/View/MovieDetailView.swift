//
//  MovieDetailView.swift
//  Framey
//
//  Created by Fabian Dargaud on 03/09/2026.
//

import SwiftUI

struct MovieDetailView: View {
    let movie: MovieEntity
    
    @State private var viewModel = MovieDetailViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                actionsRow
                ratingCard
                if !movie.overview.isEmpty {
                    synopsisSection
                }
                informationsSection
            }
            .padding(.bottom, 32)
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.loadDetails(id: movie.id) }
    }
    
    // MARK: - Header backdrop + poster
    
    private var header: some View {
        ZStack(alignment: .bottomLeading) {
            Color.clear
                .frame(height: 340)
                .overlay {
                    AsyncImage(url: movie.backdropPath?.tmdbPosterURL(size: .w780)) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Rectangle().fill(.gray.opacity(0.3))
                    }
                }
                .clipped()
                .overlay {
                    LinearGradient(colors: [.clear, .black],
                                   startPoint: .center,
                                   endPoint: .bottom)
                }
            
            HStack(alignment: .bottom, spacing: 16) {
                posterView
                VStack(alignment: .leading, spacing: 4) {
                    Text(movie.title)
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                    Text(metaLine)
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.8))
                    if let director = viewModel.director {
                        Text("Réalisé par \(director)")
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                Spacer(minLength: 0)
            }
            .padding()
        }
    }
    
    private var posterView: some View {
        AsyncImage(url: movie.posterPath?.tmdbPosterURL(size: .w342)) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            Rectangle().fill(.gray.opacity(0.3)).overlay(ProgressView())
        }
        .frame(width: 120, height: 180)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 6)
    }
    
    private var metaLine: String {
        var parts: [String] = []
        if let year = movie.releaseDate?.formatted(.dateTime.year()) {
            parts.append(year)
        }
        if viewModel.details != nil {
            parts.append(viewModel.runtimeText)
            parts.append(viewModel.genreNames)
        }
        return parts.joined(separator: " • ")
    }
    
    // MARK: - Actions (à câbler dans l'étape SwiftData)
    
    private var actionsRow: some View {
        HStack(spacing: 0) {
            actionButton("checkmark", "Vu") { }
            actionButton("eye", "Watchlist") { }
            actionButton("list.bullet.rectangle", "Liste") { }
            actionButton("heart", "Like") { }
        }
        .padding(.horizontal)
    }
    
    private func actionButton(_ icon: String, _ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon).font(.title3)
                Text(title).font(.caption)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.tint)
    }
    
    // MARK: - Ma note (placeholder, câblé plus tard)
    
    private var ratingCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ma note").font(.headline)
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { _ in
                    Image(systemName: "star")
                        .font(.title2)
                        .foregroundStyle(.gray.opacity(0.4))
                }
            }
            Text("Ajouter une note")
                .font(.subheadline)
                .foregroundStyle(.orange)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
    
    // MARK: - Synopsis
    
    private var synopsisSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Synopsis").font(.headline)
            Text(movie.overview)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Informations
    
    private var informationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Informations").font(.headline)
            VStack(spacing: 0) {
                infoRow("calendar", "Sortie",
                        movie.releaseDate?.formatted(date: .long, time: .omitted) ?? "—")
                Divider()
                infoRow("clock", "Durée", viewModel.runtimeText)
                Divider()
                infoRow("person", "Réalisateur", viewModel.director ?? "—")
                Divider()
                infoRow("tag", "Genres", viewModel.genreNames)
            }
            .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal)
    }
    
    private func infoRow(_ icon: String, _ label: String, _ value: String) -> some View {
        HStack {
            Label(label, systemImage: icon)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
        .padding()
    }
}

#Preview {
    NavigationStack {
        MovieDetailView(movie: MovieEntity(id: 157336, title: "Interstellar"))
            .preferredColorScheme(.dark)
    }
}
