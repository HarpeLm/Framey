//
//  ProfileView.swift
//  Framey
//
//  Created by Fabian Dargaud on 03/09/2026.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Query private var watched: [WatchedEntry]
    @Query private var reviews: [ReviewEntry]
    @Query private var lists: [ListEntity]
    @Query private var watchlist: [WatchlistEntry]
    
    private var watchedThisMonth: Int {
        watched.filter {
            Calendar.current.isDate($0.dateWatched, equalTo: .now, toGranularity: .month)
        }.count
    }
    
    private var watchedThisYear: Int {
        watched.filter {
            Calendar.current.isDate($0.dateWatched, equalTo: .now, toGranularity: .year)
        }.count
    }
    
    private var currentYear: Int {
        Calendar.current.component(.year, from: .now)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    header
                    statsGrid
                }
                .padding(20)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - En-tête
    
    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(.purple)
            Text("Cinéphile")
                .font(.title2.bold())
                .foregroundStyle(.white)
            Text("Membre Framey")
                .font(.caption)
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 20)
    }
    
    // MARK: - Stats
    
    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(value: "\(watched.count)", label: "Films vus", icon: "eye.fill")
            StatCard(value: "\(watchedThisMonth)", label: "Episodes Vus", icon: "popcorn")
            StatCard(value: "\(watchedThisYear)", label: "Vus en \(currentYear)", icon: "calendar")
            StatCard(value: "\(watchlist.count)", label: "À voir", icon: "bookmark")
            StatCard(value: "\(reviews.count)", label: "Critiques", icon: "text.quote")
            StatCard(value: "\(lists.count)", label: "Listes", icon: "list.bullet.rectangle")
        }
    }
}

#Preview {
    ProfileView()
        .preferredColorScheme(.dark)
        .modelContainer(for: [WatchedEntry.self, ReviewEntry.self, ListEntity.self, WatchlistEntry.self], inMemory: true)
}
