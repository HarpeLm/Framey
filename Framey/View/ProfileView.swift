//
//  ProfileView.swift
//  Framey
//
//  Created by Fabian Dargaud on 03/09/2026.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @State private var selectedTab: ProfileTab = .activite
    @Query(sort: \WatchedEntry.dateWatched, order: .reverse) private var watched: [WatchedEntry]
    @Query(sort: \WatchlistEntry.dateAdded, order: .reverse) private var watchlist: [WatchlistEntry]
    @Query(sort: \ListEntity.dateCreated) private var lists: [ListEntity]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    ProfileHeader(username: "Cinéphile", handle: "@framey")
                    statsGrid
                    ProfileSegmentBar(selectedTab: $selectedTab)
                    tabContent
                }
                .padding(.bottom, 40)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: MediaItemEntity.self) { item in
                MovieDetailView(item: item)
            }
            .navigationDestination(for: ProfileRoute.self) { route in
                switch route {
                case .list(let list): ListDetailView(list: list)
                }
            }
        }
    }
    
    // MARK: - Stats (gardées de l'ancienne version)
    
    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(value: "\(watched.count)", label: "Films vus", icon: "eye.fill")
            StatCard(value: "\(watchedThisMonth)", label: "Vus ce mois-ci", icon: "popcorn")
            StatCard(value: "\(watchedThisYear)", label: "Vus en \(currentYear)", icon: "calendar")
            StatCard(value: "\(watchlist.count)", label: "À voir", icon: "bookmark")
            StatCard(value: "\(lists.count)", label: "Listes", icon: "list.bullet.rectangle")
            StatCard(value: "\(averageRating)", label: "Note moyenne /5", icon: "star.fill")
        }
        .padding(.horizontal, 20)
    }
    
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
    
    private var averageRating: String {
        let rated = watched.compactMap(\.rating)
        guard !rated.isEmpty else { return "–" }
        let avg = Double(rated.reduce(0, +)) / Double(rated.count)
        return avg.formatted(.number.precision(.fractionLength(1)))
    }
    
    // MARK: - Onglets
    
    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .activite: activityFeed
        case .listes: listsSection
        case .aPropos: aboutSection
        }
    }
    
    private var activityFeed: some View {
        Group {
            if activityItems.isEmpty {
                ContentUnavailableView("Aucune activité",
                                       systemImage: "clock",
                                       description: Text("Note et ajoute des films pour remplir ton journal"))
            } else {
                VStack(spacing: 10) {
                    ForEach(activityItems) { item in
                        NavigationLink(value: item.mediaItem) {
                            ActivityRow(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private var listsSection: some View {
        Group {
            if lists.isEmpty {
                ContentUnavailableView("Aucune liste",
                                       systemImage: "list.bullet.rectangle",
                                       description: Text("Crée des listes depuis la fiche d'un film"))
            } else {
                VStack(spacing: 10) {
                    ForEach(lists) { list in
                        NavigationLink(value: ProfileRoute.list(list)) {
                            listRow(list)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private var aboutSection: some View {
        VStack(spacing: 8) {
            Text("Membre Framey")
                .font(.headline)
                .foregroundStyle(.white)
            Text("Je note et je journalise mes visionnages. 🎬")
                .font(.caption)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 40)
        .padding(.top, 12)
    }
    
    private func listRow(_ list: ListEntity) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12)
                .fill(.purple.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "list.bullet.rectangle")
                        .foregroundStyle(.purple)
                )
            VStack(alignment: .leading, spacing: 4) {
                Text(list.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Text("\(list.items.count) titres")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.gray)
        }
        .padding(10)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Feed d'activité (fusion watched + watchlist, trié par date)
    
    private var activityItems: [ActivityItem] {
        let watchedItems = watched.map { entry in
            ActivityItem(
                id: "watched-\(entry.mediaId)-\(entry.dateWatched.timeIntervalSinceReferenceDate)",
                actionText: entry.rating != nil ? "Tu as noté" : "Tu as marqué comme vu",
                title: entry.title,
                posterPath: entry.posterPath,
                rating: entry.rating,
                date: entry.dateWatched,
                mediaItem: entry.asMediaItem
            )
        }
        
        let watchlistItems = watchlist.map { entry in
            ActivityItem(
                id: "watchlist-\(entry.mediaId)-\(entry.dateAdded.timeIntervalSinceReferenceDate)",
                actionText: "Tu as ajouté à ta watchlist",
                title: entry.title,
                posterPath: entry.posterPath,
                date: entry.dateAdded,
                mediaItem: entry.asMediaItem
            )
        }
        
        return Array((watchedItems + watchlistItems)
            .sorted { $0.date > $1.date }
            .prefix(20))
    }
}

#Preview {
    ProfileView()
        .preferredColorScheme(.dark)
        .modelContainer(for: [MediaItemEntity.self, WatchedEntry.self, WatchlistEntry.self, ListEntity.self, ListItemEntry.self], inMemory: true)
}
