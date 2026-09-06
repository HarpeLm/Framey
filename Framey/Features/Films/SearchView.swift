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
    
    /// Vrais classiques cultes (IDs TMDB), dans l'ordre voulu
    private static let classicIds: [Int] = [
        278,    // Les Évadés
        238,    // Le Parrain
        240,    // Le Parrain 2
        680,    // Pulp Fiction
        550,    // Fight Club
        13,     // Forrest Gump
        603,    // Matrix
        155,    // The Dark Knight
        27205,  // Inception
        157336, // Interstellar
        424,    // La Liste de Schindler
        769,    // Les Affranchis
        807,    // Se7en
        274,    // Le Silence des agneaux
        15,     // Citizen Kane
        289,    // Casablanca
        539,    // Psychose
        426,    // Vertigo
        62,     // 2001, l'Odyssée de l'espace
        11,     // Star Wars
        1891,   // L'Empire contre-attaque
        329,    // Jurassic Park
        105,    // Retour vers le futur
        348,    // Alien
        78,     // Blade Runner
        103,    // Taxi Driver
        429,    // Le Bon, la Brute et le Truand
        335,    // Il était une fois dans l'Ouest
        194,    // Le Fabuleux Destin d'Amélie Poulain
        129,    // Le Voyage de Chihiro
        496243, // Parasite
        244786, // Whiplash
        423,    // Le Pianiste
        857,    // Il faut sauver le soldat Ryan
        497,    // La Ligne verte
        98,     // Gladiator
        120,    // La Communauté de l'anneau
        122,    // Le Retour du roi
        597,    // Titanic
        101,    // Léon
        18,     // Le Cinquième Élément
        11216,  // Cinema Paradiso
        389,    // 12 Hommes en colère
        510,    // Vol au-dessus d'un nid de coucou
        629,    // Usual Suspects
        1124,   // Le Prestige
        694,    // Shining
        185,    // Orange mécanique
        28      // Apocalypse Now
    ]
    
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
        .task { await loadClassics() }
        .task(id: query) { await runSearch() }
    }
    
    // MARK: - Chargement des classiques (en parallèle, ordre conservé)
    
    private func loadClassics() async {
        classics = await withTaskGroup(of: MediaItemEntity?.self) { group in
            for id in Self.classicIds {
                group.addTask { try? await MovieService.fetchMovie(id: id) }
            }
            var result: [MediaItemEntity] = []
            for await item in group {
                if let item { result.append(item) }
            }
            return result.sorted { a, b in
                (Self.classicIds.firstIndex(of: a.id) ?? 0) < (Self.classicIds.firstIndex(of: b.id) ?? 0)
            }
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
