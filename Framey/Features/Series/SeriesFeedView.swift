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
    }
    
    // MARK: - Onglet Séries (gros titre, comme "Films populaires")
    
    private var tabContent: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.popular, id: \.id) { serie in
                    NavigationLink(value: serie) {
                        PosterGridCard(title: serie.title, posterPath: serie.posterPath)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            
            topRatedRow
                .padding(.top, 28)
                .padding(.bottom, 40)
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("Séries populaires")
    }
    
    // MARK: - Segment Séries du Home
    
    private var segmentContent: some View {
        VStack(alignment: .leading, spacing: 28) {
            MediaRow(title: "Séries populaires", items: viewModel.popular) { card($0) }
            topRatedRow
        }
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
}

#Preview {
    NavigationStack {
        SeriesFeedView(mode: .tab)
            .preferredColorScheme(.dark)
    }
}
