import SwiftUI
import SwiftData

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @State private var selectedTab: HomeTab = .accueil
    @State private var path = NavigationPath()
    @State private var listOptionsTarget: ListEntity?
    @State private var topSeries: [MediaItemEntity] = []
    @State private var seriesReleases: [MediaItemEntity] = []
    @Environment(\.modelContext) private var modelContext
    @State private var showingNewList = false
    @State private var newListName = ""
    @Query(sort: \WatchlistEntry.dateAdded, order: .reverse) private var watchlist: [WatchlistEntry]
    @Query(sort: \WatchedEntry.dateWatched, order: .reverse) private var watched: [WatchedEntry]
    @Query(sort: \ListEntity.dateCreated) private var lists: [ListEntity]
    
    private var watchedIds: Set<Int> {
        Set(watched.map(\.mediaId))
    }
    
    private var featured: [MediaItemEntity] {
        viewModel.featuredMovies(excludingWatchedIds: watchedIds)
    }
    
    /// Hero mixte : 3 top films + 3 top séries
    private var heroItems: [MediaItemEntity] {
        Array(featured.prefix(3)) + Array(topSeries.prefix(3))
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack(alignment: .topLeading) {
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HomeTopBar(onSearch: { path.append(HomeRoute.search) })
                    HomeSegmentBar(selectedTab: $selectedTab)
                        .padding(.top, 12)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 28) {
                            if selectedTab == .accueil {
                                FeaturedHero(movies: heroItems, isLoading: viewModel.isLoading)
                                
                                if !viewModel.nowPlaying.isEmpty {
                                    cinemaSection
                                }
                                
                                if !seriesReleases.isEmpty {
                                    seriesReleasesRow
                                }
                                
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
                                    MediaRow(title: "Vus récemment",
                                             items: watched,
                                             onSeeAll: { path.append(HomeRoute.diary) }) { entry in
                                        AnyView(
                                            NavigationLink(value: entry.asMediaItem) {
                                                MediaPosterCard(title: entry.title, posterPath: entry.posterPath, rating: entry.rating)
                                            }
                                            .buttonStyle(.plain)
                                        )
                                    }
                                }
                                
                                listsRow
                                
                            } else if selectedTab == .pourVous {
                                RecommendationsView()
                                
                            } else if selectedTab == .series {
                                SeriesFeedView()
                                
                            } else {
                                comingSoon(tab: selectedTab)
                            }
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 40)
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: MediaItemEntity.self) { item in
                if item.mediaType == .tv {
                    SeriesDetailView(item: item)
                } else {
                    MovieDetailView(item: item)
                }
            }
            .navigationDestination(for: HomeRoute.self) { route in
                switch route {
                case .nowPlaying: NowPlayingView()
                case .diary: DiaryView()
                case .search: SearchView()
                case .lists: ListsView()
                case .list(let list): ListDetailView(list: list)
                }
            }
            .sheet(item: $listOptionsTarget) { list in
                ListOptionsSheet(list: list)
                    .preferredColorScheme(.dark)
            }
            .alert("Nouvelle liste", isPresented: $showingNewList) {
                TextField("Nom de la liste", text: $newListName)
                Button("Créer") {
                    let name = newListName.trimmingCharacters(in: .whitespaces)
                    guard !name.isEmpty else { return }
                    modelContext.insert(ListEntity(name: name))
                    newListName = ""
                }
                Button("Annuler", role: .cancel) { }
            }
        }
        .task { await viewModel.load() }
        .task { await loadSeries() }
    }
    
    // MARK: - Chargement des séries (hero + sorties)
    
    private func loadSeries() async {
        let region = Locale.current.region?.identifier ?? "FR"
        async let popular = MovieService.fetchPopularTV()
        async let onAir = MovieService.fetchOnTheAirTV(region: region)
        topSeries = (try? await popular) ?? []
        seriesReleases = (try? await onAir) ?? []
    }
    
    // MARK: - Actuellement au cinéma
    
    private var cinemaSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Actuellement au cinéma")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                Button("Voir tout") { path.append(HomeRoute.nowPlaying) }
                    .font(.caption)
                    .foregroundStyle(.purple)
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.nowPlaying, id: \.id) { movie in
                        NavigationLink(value: movie) {
                            CinemaPosterCard(movie: movie)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Sorties séries du moment
    
    private var seriesReleasesRow: some View {
        MediaRow(title: "Sorties séries du moment",
                 items: seriesReleases,
                 onSeeAll: { selectedTab = .series }) { serie in
            AnyView(
                NavigationLink(value: serie) {
                    MediaPosterCard(title: serie.title, posterPath: serie.posterPath)
                }
                .buttonStyle(.plain)
            )
        }
    }
    
    // MARK: - Rangée Listes
    
    private var listsRow: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Tes listes")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                Button("Voir tout") { path.append(HomeRoute.lists) }
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
                        .onTapGesture { path.append(HomeRoute.list(list)) }
                        .onLongPressGesture { listOptionsTarget = list }
                    }
                    
                    Button {
                        showingNewList = true
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                                .foregroundStyle(.purple.opacity(0.6))
                                .frame(width: 140, height: 90)
                                .overlay(
                                    Image(systemName: "plus")
                                        .font(.title2)
                                        .foregroundStyle(.purple)
                                )
                            Text("Nouvelle liste")
                                .font(.caption)
                                .foregroundStyle(.purple)
                            Text("Créer")
                                .font(.caption2)
                                .foregroundStyle(.gray)
                        }
                        .frame(width: 140)
                    }
                    .buttonStyle(.plain)
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
    HomeView()
        .preferredColorScheme(.dark)
        .modelContainer(for: [MediaItemEntity.self, WatchedEntry.self, WatchlistEntry.self, ListEntity.self, ListItemEntry.self, LikeEntry.self, ReviewEntry.self], inMemory: true)
}
