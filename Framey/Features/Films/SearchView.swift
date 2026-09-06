//
//  SearchView.swift
//  Framey
//
//  Created by Fabian Dargaud on 04/09/2026.
//

import SwiftUI

struct SearchView: View {
    @State private var query = ""
    @State private var movieResults: [MediaItemEntity] = []
    @State private var seriesResults: [MediaItemEntity] = []
    @State private var classics: [MediaItemEntity] = []
    
    private var isSearching: Bool {
        query.trimmingCharacters(in: .whitespaces).count >= 2
    }
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                searchBar
                    .padding(.horizontal, 20)
                
                if isSearching {
                    if !movieResults.isEmpty {
                        gridSection(title: "Films", items: movieResults)
                    }
                    if !seriesResults.isEmpty {
                        gridSection(title: "Séries", items: seriesResults)
                    }
                    if movieResults.isEmpty && seriesResults.isEmpty {
                        Text("Aucun résultat pour « \(query) »")
                            .foregroundStyle(.gray)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                    }
                } else if classics.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                } else {
                    gridSection(title: "Classiques cultes", items: classics)
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("Recherche")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            classics = (try? await MovieService.fetchTopRatedMovies()) ?? []
        }
        .task(id: query) {
            await runSearch()
        }
    }
    
    // MARK: - Barre de recherche
    
    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.gray)
            TextField("Films, séries…", text: $query)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .foregroundStyle(.white)
            if !query.isEmpty {
                Button {
                    query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                }
                .foregroundStyle(.gray)
            }
        }
        .padding(10)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Grille verticale (haut en bas, sans scroll latéral)
    
    private func gridSection(title: String, items: [MediaItemEntity]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(items, id: \.id) { item in
                    NavigationLink(value: item) {
                        PosterGridCard(title: item.title, posterPath: item.posterPath)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Recherche unifiée (debounce)
    
    private func runSearch() async {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard trimmed.count >= 2 else {
            movieResults = []
            seriesResults = []
            return
        }
        
        try? await Task.sleep(for: .milliseconds(400))
        guard !Task.isCancelled else { return }
        
        async let movies = MovieService.searchMovies(query: trimmed)
        async let series = MovieService.searchTV(query: trimmed)
        
        movieResults = (try? await movies) ?? []
        seriesResults = (try? await series) ?? []
    }
}

#Preview {
    NavigationStack {
        SearchView()
            .preferredColorScheme(.dark)
    }
}
