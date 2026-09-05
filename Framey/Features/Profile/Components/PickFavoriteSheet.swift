//
//  PickFavoriteSheet.swift
//  Framey
//
//  Created by Fabian Dargaud on 05/09/2026.
//

import SwiftUI
import SwiftData

struct PickFavoriteSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FavoriteEntry.position) private var favorites: [FavoriteEntry]
    @State private var query = ""
    @State private var results: [MediaItemEntity] = []
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(results, id: \.id) { movie in
                        row(movie)
                    }
                }
                .padding(20)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Choisir un favori")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .top) { searchBar }
            .task(id: query) { await runSearch() }
        }
        .presentationDetents([.medium, .large])
    }
    
    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.gray)
            TextField("Rechercher un film…", text: $query)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .foregroundStyle(.white)
            if !query.isEmpty {
                Button { query = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                }
                .foregroundStyle(.gray)
            }
        }
        .padding(10)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
        .background(.black)
    }
    
    private func row(_ movie: MediaItemEntity) -> some View {
        let isFavorite = favorites.contains { $0.mediaId == movie.id }
        let isFull = !isFavorite && favorites.count >= 5
        
        return HStack(spacing: 12) {
            AsyncImage(url: movie.posterPath?.tmdbPosterURL()) { phase in
                if let image = phase.image {
                    image.resizable().aspectRatio(2/3, contentMode: .fill)
                } else {
                    Rectangle().fill(.gray.opacity(0.3))
                }
            }
            .frame(width: 40, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            
            Text(movie.title)
                .font(.subheadline)
                .foregroundStyle(.white)
                .lineLimit(2)
            
            Spacer()
            
            Button {
                toggle(movie)
            } label: {
                Image(systemName: isFavorite ? "checkmark.circle.fill" : "plus.circle")
                    .font(.title2)
                    .foregroundStyle(isFavorite ? .green : .purple)
            }
            .disabled(isFull)
            .opacity(isFull ? 0.3 : 1)
        }
        .padding(10)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
    }
    
    private func toggle(_ movie: MediaItemEntity) {
        if let existing = favorites.first(where: { $0.mediaId == movie.id }) {
            modelContext.delete(existing)
        } else {
            guard favorites.count < 5 else { return }
            let entry = FavoriteEntry(mediaId: movie.id,
                                      mediaType: movie.mediaType,
                                      title: movie.title,
                                      posterPath: movie.posterPath,
                                      position: nextFreePosition)
            modelContext.insert(entry)
        }
    }
    
    private var nextFreePosition: Int {
        (0..<5).first { pos in !favorites.contains { $0.position == pos } } ?? 0
    }
    
    private func runSearch() async {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard trimmed.count >= 2 else {
            results = []
            return
        }
        
        try? await Task.sleep(for: .milliseconds(400))
        guard !Task.isCancelled else { return }
        
        results = (try? await MovieService.searchMovies(query: trimmed)) ?? []
    }
}

#Preview {
    PickFavoriteSheet()
        .preferredColorScheme(.dark)
        .modelContainer(for: [FavoriteEntry.self], inMemory: true)
}
