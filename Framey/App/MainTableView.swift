//
//  MainTableView.swift
//  Framey
//
//  Created by Fabian Dargaud on 04/09/2026.
//

import SwiftUI

enum MainTab: Hashable {
    case accueil, films, quick, series, profil
}

struct MainTabView: View {
    @State private var selection: MainTab = .accueil
    @State private var previousTab: MainTab = .accueil
    @State private var showingQuickLog = false
    
    var body: some View {
        TabView(selection: $selection) {
            Tab("Accueil", systemImage: "house", value: .accueil) {
                HomeView()
            }
            Tab("Films", systemImage: "film", value: .films) {
                FilmsView()
            }
            Tab("", systemImage: "plus.circle.fill", value: .quick) {
                Color.clear
            }
            Tab("Séries", systemImage: "tv", value: .series) {
                NavigationStack {
                    SeriesFeedView(mode: .tab)
                        .navigationDestination(for: MediaItemEntity.self) { item in
                            SeriesDetailView(item: item)
                        }
                }
            }
            Tab("Profil", systemImage: "person", value: .profil) {
                ProfileView()
            }
        }
        .onChange(of: selection) { _, new in
            if new == .quick {
                showingQuickLog = true
                selection = previousTab
            } else {
                previousTab = new
            }
        }
        .sheet(isPresented: $showingQuickLog) {
            QuickLogSheet()
                .preferredColorScheme(.dark)
        }
    }
}

#Preview {
    MainTabView()
}
