import SwiftUI
import SwiftData

struct MovieDetailView: View {
    let item: MediaItemEntity
    
    @State private var viewModel = MovieDetailViewModel()
    @State private var showingAddToListSheet = false
    @Environment(\.modelContext) private var modelContext
    @Query private var watchedEntries: [WatchedEntry]
    @Query private var watchlistEntries: [WatchlistEntry]
    @Query private var listEntries: [ListItemEntry]
    
    init(item: MediaItemEntity) {
        self.item = item
        let id = item.id
        let type = item.mediaTypeRaw
        _watchedEntries = Query(filter: #Predicate<WatchedEntry> {
            $0.mediaId == id && $0.mediaTypeRaw == type
        })
        _watchlistEntries = Query(filter: #Predicate<WatchlistEntry> {
            $0.mediaId == id && $0.mediaTypeRaw == type
        })
        _listEntries = Query(filter: #Predicate<ListItemEntry> {
            $0.mediaId == id && $0.mediaTypeRaw == type
        })
    }
    
    private var watchedEntry: WatchedEntry? { watchedEntries.first }
    private var isWatched: Bool { watchedEntry != nil }
    private var rating: Int { watchedEntry?.rating ?? 0 }
    private var isInWatchlist: Bool { watchlistEntries.first != nil }
    private var isInAnyList: Bool { !listEntries.isEmpty }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                actionsRow
                ratingCard
                if !item.overview.isEmpty {
                    synopsisSection
                }
                informationsSection
            }
            .padding(.bottom, 32)
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.loadDetails(id: item.id) }
        .sheet(isPresented: $showingAddToListSheet) {
            AddToListSheet(item: item)
        }
    }
    
    // MARK: - Actions SwiftData
    
    private func toggleWatched() {
        if let entry = watchedEntry {
            modelContext.delete(entry)
        } else {
            modelContext.insert(WatchedEntry(mediaId: item.id, mediaType: item.mediaType))
            removeFromWatchlist() // comportement Letterboxd : vu → sort de la watchlist
        }
    }
    
    private func setRating(_ value: Int) {
        let entry: WatchedEntry
        if let existing = watchedEntry {
            entry = existing
        } else {
            entry = WatchedEntry(mediaId: item.id, mediaType: item.mediaType)
            modelContext.insert(entry)
        }
        entry.rating = (entry.rating == value) ? nil : value
        removeFromWatchlist() // noté → sort de la watchlist
    }
    
    private func toggleWatchlist() {
        if let entry = watchlistEntries.first {
            modelContext.delete(entry)
        } else {
            modelContext.insert(WatchlistEntry(
                mediaId: item.id,
                mediaType: item.mediaType,
                title: item.title,
                posterPath: item.posterPath
            ))
        }
    }
    
    private func removeFromWatchlist() {
        if let entry = watchlistEntries.first {
            modelContext.delete(entry)
        }
    }
    
    // MARK: - Header backdrop + poster
    
    private var header: some View {
        ZStack(alignment: .bottomLeading) {
            Color.clear
                .frame(height: 340)
                .overlay {
                    AsyncImage(url: item.backdropPath?.tmdbPosterURL(size: .w780)) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Rectangle().fill(.gray.opacity(0.3))
                    }
                }
                .clipped()
                .overlay {
                    LinearGradient(colors: [.clear, .black],
                                   startPoint: .center,
                                   endPoint: .bottom)
                }
            
            HStack(alignment: .bottom, spacing: 16) {
                posterView
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                    Text(metaLine)
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.8))
                    if let director = viewModel.director {
                        Text("Réalisé par \(director)")
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                Spacer(minLength: 0)
            }
            .padding()
        }
    }
    
    private var posterView: some View {
        AsyncImage(url: item.posterPath?.tmdbPosterURL(size: .w342)) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            Rectangle().fill(.gray.opacity(0.3)).overlay(ProgressView())
        }
        .frame(width: 120, height: 180)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 6)
    }
    
    private var metaLine: String {
        var parts: [String] = []
        if let year = item.releaseDate?.formatted(.dateTime.year()) {
            parts.append(year)
        }
        if viewModel.details != nil {
            parts.append(viewModel.runtimeText)
            parts.append(viewModel.genreNames)
        }
        return parts.joined(separator: " • ")
    }
    
    // MARK: - Actions
    
    private var actionsRow: some View {
        HStack(spacing: 0) {
            actionButton(isWatched ? "checkmark.circle.fill" : "checkmark.circle",
                         isWatched ? "Vu" : "Pas vu",
                         tint: isWatched ? .green : .gray) {
                toggleWatched()
            }
            actionButton(isInWatchlist ? "eye.fill" : "eye",
                         "Watchlist",
                         tint: isInWatchlist ? .blue : .gray) {
                toggleWatchlist()
            }
            actionButton(isInAnyList ? "list.bullet.rectangle.fill" : "list.bullet.rectangle",
                         "Liste",
                         tint: isInAnyList ? .purple : .gray) {
                showingAddToListSheet = true
            }
            actionButton("heart", "Like") { }
        }
        .padding(.horizontal)
    }
    
    private func actionButton(_ icon: String, _ title: String, tint: Color = .accentColor, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon).font(.title3)
                Text(title).font(.caption)
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(tint)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Ma note interactive
    
    private var ratingCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ma note").font(.headline)
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { star in
                    Button {
                        setRating(star)
                    } label: {
                        Image(systemName: star <= rating ? "star.fill" : "star")
                            .font(.title2)
                            .foregroundStyle(star <= rating ? Color.yellow : Color.gray.opacity(0.4))
                    }
                    .buttonStyle(.plain)
                }
            }
            Text(ratingLabel)
                .font(.subheadline)
                .foregroundStyle(.orange)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
    
    private var ratingLabel: String {
        switch rating {
        case 0: "Ajouter une note"
        case 1: "Nul"
        case 2: "Bof"
        case 3: "Bien"
        case 4: "Très bien"
        default: "Incroyable"
        }
    }
    
    // MARK: - Synopsis
    
    private var synopsisSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Synopsis").font(.headline)
            Text(item.overview)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Informations
    
    private var informationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Informations").font(.headline)
            VStack(spacing: 0) {
                infoRow("calendar", "Sortie",
                        item.releaseDate?.formatted(date: .long, time: .omitted) ?? "—")
                Divider()
                infoRow("clock", "Durée", viewModel.runtimeText)
                Divider()
                infoRow("person", "Réalisateur", viewModel.director ?? "—")
                Divider()
                infoRow("tag", "Genres", viewModel.genreNames)
            }
            .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal)
    }
    
    private func infoRow(_ icon: String, _ label: String, _ value: String) -> some View {
        HStack {
            Label(label, systemImage: icon)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
        .padding()
    }
}

#Preview {
    NavigationStack {
        MovieDetailView(item: MediaItemEntity(id: 157336, title: "Interstellar"))
            .preferredColorScheme(.dark)
    }
    .modelContainer(for: [MediaItemEntity.self, WatchedEntry.self, WatchlistEntry.self], inMemory: true)
}
