//
//  HomeView.swift
//  Framey
//
//  Created by Fabian Dargaud on 04/09/2026.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @State private var selectedTab: HomeTab = .accueil
    @Query(sort: \WatchlistEntry.dateAdded, order: .reverse) private var watchlist: [WatchlistEntry]
    @Query(sort: \WatchedEntry.dateWatched, order: .reverse) private var watched: [WatchedEntry]
    @Query(sort: \ListEntity.dateCreated) private var lists: [ListEntity]
    
    private var watchedIds: Set<Int> {
        Set(watched.map(\.mediaId))
    }
    
    private var featured: [MediaItemEntity] {
        viewModel.featuredMovies(excludingWatchedIds: watchedIds)
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HomeTopBar()
                HomeSegmentBar(selectedTab: $selectedTab)
                    .padding(.top, 16)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        if selectedTab == .accueil {
                            FeaturedHero(movies: featured, isLoading: viewModel.isLoading)
                            
                            if !watchlist.isEmpty {
                                MediaRow(title: "À voir ensuite", items: watchlist) { entry in
                                    AnyView(
                                        NavigationLink(value: entry.asMediaItem) {
                                            MediaPosterCard(title: entry.title, posterPath: entry.posterPath)
                                        }
                                        .buttonStyle(.plain)
                                    )
                                }
                            }
                            
                            if !watched.isEmpty {
                                MediaRow(title: "Vus récemment", items: watched) { entry in
                                    AnyView(
                                        NavigationLink(value: entry.asMediaItem) {
                                            MediaPosterCard(title: entry.title, posterPath: entry.posterPath, rating: entry.rating)
                                        }
                                        .buttonStyle(.plain)
                                    )
                                }
                            }
                            
                            if !lists.isEmpty {
                                listsRow
                            }
                        } else {
                            comingSoon(tab: selectedTab)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .task { await viewModel.load() }
    }
    
    // MARK: - Rangée Listes (cartes spécifiques, pas des posters)
    
    private var listsRow: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Tes listes")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                Button("Voir tout") { }
                    .font(.caption)
                    .foregroundStyle(.purple)
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(lists) { list in
                        VStack(alignment: .leading, spacing: 4) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.purple.opacity(0.2))
                                .frame(width: 140, height: 90)
                                .overlay(
                                    Image(systemName: "list.bullet.rectangle")
                                        .font(.title2)
                                        .foregroundStyle(.purple)
                                )
                            Text(list.name)
                                .font(.caption)
                                .foregroundStyle(.white)
                                .lineLimit(1)
                            Text("\(list.items.count) titres")
                                .font(.caption2)
                                .foregroundStyle(.gray)
                        }
                        .frame(width: 140)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private func comingSoon(tab: HomeTab) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.largeTitle)
                .foregroundStyle(.purple)
            Text("\(tab.title) — bientôt disponible")
                .font(.headline)
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .preferredColorScheme(.dark)
            .navigationDestination(for: MediaItemEntity.self) { MovieDetailView(item: $0) }
    }
    .modelContainer(for: [MediaItemEntity.self, WatchedEntry.self, WatchlistEntry.self, ListEntity.self, ListItemEntry.self, LikeEntry.self, ReviewEntry.self], inMemory: true)
}
