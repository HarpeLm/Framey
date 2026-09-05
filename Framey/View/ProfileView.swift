import SwiftUI
import SwiftData

struct ProfileView: View {
    @AppStorage("username") private var username = "Cinéphile"
    @AppStorage("handle") private var handle = "@framey"
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: ProfileTab = .activite
    @State private var showingEditSheet = false
    @State private var showingPickFavorite = false
    @State private var profilePhoto: Data?
    @Query(sort: \WatchedEntry.dateWatched, order: .reverse) private var watched: [WatchedEntry]
    @Query(sort: \WatchlistEntry.dateAdded, order: .reverse) private var watchlist: [WatchlistEntry]
    @Query(sort: \ListEntity.dateCreated) private var lists: [ListEntity]
    @Query(sort: \FavoriteEntry.position) private var favorites: [FavoriteEntry]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    ProfileHeader(username: username, handle: handle, photoData: profilePhoto)
                    statsGrid
                    ProfileSegmentBar(selectedTab: $selectedTab)
                    tabContent
                }
                .padding(.bottom, 40)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            showingEditSheet = true
                        } label: {
                            Label("Modifier le profil", systemImage: "pencil")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundStyle(.white)
                    }
                }
            }
            .sheet(isPresented: $showingEditSheet, onDismiss: {
                profilePhoto = ProfilePhotoStore.load()
            }) {
                ProfileEditSheet(username: $username, handle: $handle)
                    .preferredColorScheme(.dark)
            }
            .sheet(isPresented: $showingPickFavorite) {
                PickFavoriteSheet()
                    .preferredColorScheme(.dark)
            }
            .onAppear {
                profilePhoto = ProfilePhotoStore.load()
            }
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
    
    // MARK: - Stats
    
    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(value: "\(watched.count)", label: "Films vus", icon: "eye.fill")
            StatCard(value: "\(watchedThisMonth)", label: "Vus ce mois-ci", icon: "popcorn")
        }
        .padding(.horizontal, 20)
    }
    
    private var watchedThisMonth: Int {
        watched.filter {
            Calendar.current.isDate($0.dateWatched, equalTo: .now, toGranularity: .month)
        }.count
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
    
    // MARK: - À propos + les 5 favoris
    
    private var aboutSection: some View {
        VStack(spacing: 16) {
            Text("Membre Framey")
                .font(.headline)
                .foregroundStyle(.white)
            Text("Je note et je journalise mes visionnages. 🎬")
                .font(.caption)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Mes 5 films favoris")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                
                HStack(spacing: 8) {
                    ForEach(0..<5, id: \.self) { index in
                        favoriteSlot(index)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }
    
    @ViewBuilder
    private func favoriteSlot(_ index: Int) -> some View {
        if let fav = favorites.first(where: { $0.position == index }) {
            // Case occupée : poster → tap = fiche film, appui long = retirer
            NavigationLink(value: fav.asMediaItem) {
                slotPoster(fav.posterPath)
            }
            .buttonStyle(.plain)
            .contextMenu {
                Button(role: .destructive) {
                    modelContext.delete(fav)
                } label: {
                    Label("Retirer des favoris", systemImage: "heart.slash")
                }
            }
        } else {
            // Case vide : + au milieu → ouvre le picker
            Button {
                showingPickFavorite = true
            } label: {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.white.opacity(0.06))
                    .frame(width: 64, height: 96)
                    .overlay(
                        Image(systemName: "plus")
                            .font(.title3)
                            .foregroundStyle(.purple)
                    )
            }
            .buttonStyle(.plain)
        }
    }
    
    private func slotPoster(_ path: String?) -> some View {
        AsyncImage(url: path?.tmdbPosterURL()) { phase in
            if let image = phase.image {
                image.resizable().scaledToFill()
            } else {
                Rectangle().fill(.gray.opacity(0.3))
            }
        }
        .frame(width: 64, height: 96)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    // MARK: - Activité
    
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
    
    // MARK: - Listes
    
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
    
    // MARK: - Feed d'activité
    
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
        .modelContainer(for: [MediaItemEntity.self, WatchedEntry.self, WatchlistEntry.self, ListEntity.self, ListItemEntry.self, FavoriteEntry.self], inMemory: true)
}
