//
//  MainTableView.swift
//  Framey
//
//  Created by Fabian Dargaud on 04/09/2026.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            Tab("Accueil", systemImage: "house") {
                HomeView()
            }
            Tab("Films", systemImage: "film") {
                FilmsView()
            }
            Tab("Séries", systemImage: "tv") {
                NavigationStack {
                    SeriesFeedView()
                        .navigationDestination(for: MediaItemEntity.self) { item in
                            SeriesDetailView(item: item)
                        }
                }
            }
            Tab("Watchlist", systemImage: "eye") {
                WatchlistView()
            }
            Tab("Profil", systemImage: "person") {
                ProfileView()
            }
        }
    }
}

#Preview {
    MainTabView()
}
