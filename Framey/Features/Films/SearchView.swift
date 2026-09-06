//
//  SearchView.swift
//  Framey
//
//  Created by Fabian Dargaud on 04/09/2026.
//

import SwiftUI
import SwiftData

struct SearchView: View {
    @State private var query = ""
    @State private var movieResults: [MediaItemEntity] = []
    @State private var seriesResults: [MediaItemEntity] = []
    @State private var classics: [MediaItemEntity] = []
    @AppStorage("recentSearchesData") private var recentSearchesData = ""
    @Query(sort: \WatchedEntry.dateWatched, order: .reverse) private var watched: [WatchedEntry]
    
    /// Vrais classiques cultes (IDs TMDB), dans l'ordre voulu
    private static let classicIds: [Int] = [
        278, 238, 240, 680, 550, 13, 603, 155, 27205, 157336,
        424, 769, 807, 274, 15, 289, 539, 426, 62, 11,
        1891, 329, 105, 348, 78, 103, 429, 335, 194, 129,
        496243, 244786, 423, 857, 497, 98, 120, 122, 597, 101,
        18, 11216, 389, 510, 629, 1124, 694, 185, 28
    ]
    
    private var isSearching: Bool {
        query.trimmingCharacters(in: .whitespaces).count >= 2
    }
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    private var recentSearches: [String] {
        get {
            guard let data = recentSearchesData.data(using: .utf8),
                  let arr = try? JSONDecoder().decode([String].self, from: data) else { return [] }
            return arr
        }
        nonmutating set {
            let data = try? JSONEncoder().encode(newValue)
            recentSearchesData = String(data: data ?? Data(), encoding: .utf8) ?? ""
        }
    }
    
    /// Derniers titres vus (films + séries mélangés, dédoublonnés)
    private var recentTitles: [MediaItemEntity] {
        var seen = Set<String>()
        var result: [MediaItemEntity] = []
        for entry in watched {
            let key = "\(entry.mediaTypeRaw)-\(entry.mediaId)"
            if seen.insert(key).inserted {
                result.append(entry.asMediaItem)
            }
            if result.count >= 9 { break }
        }
        return result
    }
    
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
                } else {
                    // 1. Recherches récentes
                    if !recentSearches.isEmpty {
                        recentSearchesSection
                    }
                    
                    // 2. Films & séries récents EN PREMIER
                    if !recentTitles.isEmpty {
                        gridSection(title: "Vus récemment", items: recentTitles)
                    }
                    
                    // 3. Puis les classiques
                    if classics.isEmpty {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.top, 20)
                    } else {
                        gridSection(title: "Classiques cultes", items: classics)
                    }
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("Recherche")
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadClassics() }
        .task(id: query) { await runSearch() }
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
    
    // MARK: - Recherches récentes
    
    private var recentSearchesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Recherches récentes")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.gray)
                .padding(.horizontal, 20)
                .padding(.bottom, 4)
            
            ForEach(recentSearches, id: \.self) { term in
                Button {
                    query = term
                } label: {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.caption)
                            .foregroundStyle(.gray)
                        Text(term)
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Grille verticale
    
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
                    .simultaneousGesture(TapGesture().onEnded {
                        addRecentSearch(query)
                    })
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Logique
    
    private func addRecentSearch(_ term: String) {
        let trimmed = term.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        var current = recentSearches
        current.removeAll { $0.lowercased() == trimmed.lowercased() }
        current.insert(trimmed, at: 0)
        recentSearches = Array(current.prefix(8))
    }
    
    private func loadClassics() async {
        var fetched: [TMDBMovie] = []
        await withTaskGroup(of: TMDBMovie?.self) { group in
            for id in Self.classicIds {
                group.addTask { () -> TMDBMovie? in
                    try? await MovieService.fetchMovie(id: id)
                }
            }
            for await movie in group {
                if let movie {
                    fetched.append(movie)
                }
            }
        }
        
        classics = fetched
            .sorted { (Self.classicIds.firstIndex(of: $0.id) ?? 0) < (Self.classicIds.firstIndex(of: $1.id) ?? 0) }
            .map { movie in
                MediaItemEntity(
                    id: movie.id,
                    title: movie.title,
                    releaseDate: movie.release_date?.toDate(),
                    posterPath: movie.poster_path,
                    backdropPath: movie.backdrop_path,
                    overview: movie.overview
                )
            }
    }
    
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
    .modelContainer(for: [WatchedEntry.self], inMemory: true)
}
