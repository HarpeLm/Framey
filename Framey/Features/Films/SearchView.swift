//
//  SearchView.swift
//  Framey
//
//  Created by Fabian Dargaud on 04/09/2026.
//

import SwiftUI

struct SearchView: View {
    @State private var query = ""
    @State private var results: [MediaItemEntity] = []
    @State private var isSearching = false
    @FocusState private var keyboardFocused: Bool
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        ScrollView {
            if isSearching {
                ProgressView()
                    .padding(.top, 60)
            } else if results.isEmpty && query.count >= 2 {
                ContentUnavailableView.search(text: query)
                    .padding(.top, 60)
            } else if query.count < 2 {
                ContentUnavailableView("Rechercher un film",
                                       systemImage: "magnifyingglass",
                                       description: Text("Tape au moins 2 caractères"))
                    .padding(.top, 60)
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(results, id: \.id) { movie in
                        NavigationLink(value: movie) {
                            MediaPosterCard(title: movie.title, posterPath: movie.posterPath)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("Recherche")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .top) { searchBar }
        .task(id: query) { await runSearch() }
        .onAppear { keyboardFocused = true }
    }
    
    // MARK: - Barre de recherche
    
    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.gray)
            TextField("Rechercher un film…", text: $query)
                .focused($keyboardFocused)
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
    
    // MARK: - Debounce moderne
    
    private func runSearch() async {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard trimmed.count >= 2 else {
            results = []
            return
        }
        
        isSearching = true
        defer { isSearching = false }
        
        try? await Task.sleep(for: .milliseconds(400))
        guard !Task.isCancelled else { return }
        
        results = (try? await MovieService.searchMovies(query: trimmed)) ?? []
    }
}

#Preview {
    NavigationStack {
        SearchView()
            .preferredColorScheme(.dark)
    }
}
