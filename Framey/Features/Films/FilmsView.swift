//
//  FilmsView.swift
//  Framey
//
//  Created by Fabian Dargaud on 03/09/2026.
//

import SwiftUI

struct FilmsView: View {
    @State private var popular: [MediaItemEntity] = []
    @State private var isLoading = false
    @State private var query = ""
    @State private var results: [MediaItemEntity] = []
    
    private var isSearching: Bool {
        query.trimmingCharacters(in: .whitespaces).count >= 2
    }
    
    private let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 12)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    searchBar
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    
                    if isSearching {
                        if results.isEmpty {
                            Text("Aucun film pour « \(query) »")
                                .foregroundStyle(.gray)
                                .frame(maxWidth: .infinity)
                                .padding(.top, 40)
                        } else {
                            grid(items: results)
                        }
                    } else if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.top, 60)
                    } else {
                        grid(items: popular)
                    }
                }
                .padding(.bottom, 40)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Films populaires")
            .navigationDestination(for: MediaItemEntity.self) { item in
                if item.mediaType == .tv {
                    SeriesDetailView(item: item)
                } else {
                    MovieDetailView(item: item)
                }
            }
            .task { await loadPopular() }
            .task(id: query) { await runSearch() }
        }
    }
    
    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass").foregroundStyle(.gray)
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
    }
    
    private func grid(items: [MediaItemEntity]) -> some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(items, id: \.id) { movie in
                NavigationLink(value: movie) {
                    PosterGridCard(title: movie.title, posterPath: movie.posterPath)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func loadPopular() async {
        isLoading = true
        defer { isLoading = false }
        popular = (try? await MovieService.fetchPopularMovies()) ?? []
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
    FilmsView()
        .preferredColorScheme(.dark)
}
