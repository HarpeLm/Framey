//
//  SeriesFeedView.swift
//  Framey
//
//  Created by Fabian Dargaud on 05/09/2026.
//


import SwiftUI

struct SeriesFeedView: View {
    enum Mode {
        case segment   // intégré dans le Home
        case tab       // onglet Séries
    }
    
    var mode: Mode = .segment
    @State private var viewModel = SeriesViewModel()
    @State private var query = ""
    @State private var results: [MediaItemEntity] = []
    
    private var isSearching: Bool {
        query.trimmingCharacters(in: .whitespaces).count >= 2
    }
    
    private let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 12)
    ]
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
            } else if mode == .tab {
                tabContent
            } else {
                segmentContent
            }
        }
        .task { await viewModel.load() }
        .task(id: query) { await runSearch() }
    }
    
    // MARK: - Onglet Séries (gros titre + recherche séries)
    
    private var tabContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                searchBar
                    .padding(.horizontal, 20)
                
                if isSearching {
                    if results.isEmpty {
                        Text("Aucune série pour « \(query) »")
                            .foregroundStyle(.gray)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                    } else {
                        grid(items: results)
                    }
                } else {
                    grid(items: viewModel.popular)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Les mieux notées")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 20)
                        
                        grid(items: viewModel.topRated)
                    }
                    .padding(.top, 12)
                }
            }
            .padding(.bottom, 40)
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("Séries populaires")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Segment Séries du Home (inchangé)
    
    private var segmentContent: some View {
        VStack(alignment: .leading, spacing: 28) {
            MediaRow(title: "Séries populaires", items: viewModel.popular) { card($0) }
            topRatedRow
        }
    }
    
    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass").foregroundStyle(.gray)
            TextField("Rechercher une série…", text: $query)
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
            ForEach(items, id: \.id) { serie in
                NavigationLink(value: serie) {
                    PosterGridCard(title: serie.title, posterPath: serie.posterPath)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var topRatedRow: some View {
        MediaRow(title: "Les mieux notées", items: viewModel.topRated) { card($0) }
    }
    
    private func card(_ item: MediaItemEntity) -> AnyView {
        AnyView(
            NavigationLink(value: item) {
                MediaPosterCard(title: item.title, posterPath: item.posterPath)
            }
            .buttonStyle(.plain)
        )
    }
    
    // MARK: - Recherche séries uniquement
    
    private func runSearch() async {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard trimmed.count >= 2 else {
            results = []
            return
        }
        try? await Task.sleep(for: .milliseconds(400))
        guard !Task.isCancelled else { return }
        results = (try? await MovieService.searchTV(query: trimmed)) ?? []
    }
}

#Preview {
    NavigationStack {
        SeriesFeedView(mode: .tab)
            .preferredColorScheme(.dark)
    }
}
