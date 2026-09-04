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
    @Query private var watchedEntries: [WatchedEntry]
    
    private var watchedIds: Set<Int> {
        Set(watchedEntries.map(\.mediaId))
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
                    VStack(alignment: .leading, spacing: 24) {
                        if selectedTab == .accueil {
                            FeaturedHero(movies: featured, isLoading: viewModel.isLoading)
                        } else {
                            comingSoon(tab: selectedTab)
                        }
                    }
                    .padding(.top, 20)
                }
            }
        }
        .task { await viewModel.load() }
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
