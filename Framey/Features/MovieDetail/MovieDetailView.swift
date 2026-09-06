import SwiftUI
import SwiftData

struct MovieDetailView: View {
    let item: MediaItemEntity
    
    @State private var viewModel = MovieDetailViewModel()
    @State private var showingAddToListSheet = false
    @State private var reviewDraft: String = ""
    @Environment(\.modelContext) private var modelContext
    @Query private var watchedEntries: [WatchedEntry]
    @Query private var watchlistEntries: [WatchlistEntry]
    @Query private var listEntries: [ListItemEntry]
    @Query private var likeEntries: [LikeEntry]
    @Query private var collectionEntries: [CollectionEntry]
    @Query private var reviewEntries: [ReviewEntry]
    
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
        _likeEntries = Query(filter: #Predicate<LikeEntry> {
            $0.mediaId == id && $0.mediaTypeRaw == type
        })
        _reviewEntries = Query(filter: #Predicate<ReviewEntry> {
            $0.mediaId == id && $0.mediaTypeRaw == type
        })
        _collectionEntries = Query(filter: #Predicate<CollectionEntry> {
            $0.mediaId == id && $0.mediaTypeRaw == type
        })
    }
    
    // MARK: - Calculs rewatch
    
    private var latestWatch: WatchedEntry? {
        watchedEntries.sorted { $0.dateWatched > $1.dateWatched }.first
    }
    
    private var watchCount: Int { watchedEntries.count }
    private var isWatched: Bool { watchCount > 0 }
    private var rating: Int { latestWatch?.rating ?? 0 }
    private var isInWatchlist: Bool { watchlistEntries.first != nil }
    private var isInAnyList: Bool { !listEntries.isEmpty }
    private var isLiked: Bool { likeEntries.first != nil }
    private var existingReview: ReviewEntry? { reviewEntries.first }
    private var hasReview: Bool { existingReview != nil && existingReview?.text.isEmpty == false }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                actionsRow
                ratingCard
                reviewSection
                if !item.overview.isEmpty {
                    synopsisSection
                }
                streamingSection
                informationsSection
            }
            .padding(.bottom, 32)
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadDetails(id: item.id)
            reviewDraft = existingReview?.text ?? ""
        }
        .sheet(isPresented: $showingAddToListSheet) {
            AddToListSheet(item: item)
        }
    }
    
    // MARK: - Actions SwiftData (rewatch + retrait watchlist sur review)
    
    /// Toggle "Vu" : si pas vu → crée un visionnage ; si déjà vu → supprime le dernier
    private func toggleWatched() {
        if isWatched {
            // Supprime le dernier visionnage (comportement toggle)
            if let latest = latestWatch {
                modelContext.delete(latest)
            }
        } else {
            // Crée un nouveau visionnage daté d'aujourd'hui
            modelContext.insert(WatchedEntry(mediaId: item.id,
                                             mediaType: item.mediaType,
                                             title: item.title,
                                             posterPath: item.posterPath,
                                             dateWatched: .now))
            removeFromWatchlist()
        }
    }
    
    /// Rewatch : ajoute un nouveau visionnage (sans supprimer l'ancien)
    private func rewatch() {
        modelContext.insert(WatchedEntry(mediaId: item.id,
                                         mediaType: item.mediaType,
                                         title: item.title,
                                         posterPath: item.posterPath,
                                         dateWatched: .now))
        removeFromWatchlist()
    }
    
    /// Note sur le dernier visionnage (crée un visionnage si nécessaire)
    private func setRating(_ value: Int) {
        let entry: WatchedEntry
        if let existing = latestWatch {
            entry = existing
        } else {
            entry = WatchedEntry(mediaId: item.id,
                                 mediaType: item.mediaType,
                                 title: item.title,
                                 posterPath: item.posterPath,
                                 dateWatched: .now)
            modelContext.insert(entry)
        }
        entry.rating = (entry.rating == value) ? nil : value
        removeFromWatchlist()
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
    
    private func toggleLike() {
        if let entry = likeEntries.first {
            modelContext.delete(entry)
        } else {
            modelContext.insert(LikeEntry(mediaId: item.id, mediaType: item.mediaType))
        }
    }
    
    /// Sauvegarde review + retrait automatique watchlist (doc P0)
    private func saveReview() {
        let trimmed = reviewDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            if let existing = existingReview {
                modelContext.delete(existing)
            }
            return
        }
        if let existing = existingReview {
            existing.text = trimmed
            existing.dateModified = .now
        } else {
            let entry = ReviewEntry(mediaId: item.id, mediaType: item.mediaType, text: trimmed)
            modelContext.insert(entry)
        }
        // ✅ Retrait automatique watchlist quand on review (doc : "vu, loggé, noté ou reviewé")
        removeFromWatchlist()
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
                    // Badge "Vu ×N" si rewatch
                    if watchCount > 1 {
                        Label("Vu ×\(watchCount)", systemImage: "arrow.clockwise")
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.green.opacity(0.3), in: Capsule())
                            .foregroundStyle(.green)
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
    
    // MARK: - Actions (avec bouton Rewatch)
    
    private var actionsRow: some View {
        HStack(spacing: 0) {
            actionButton(isWatched ? "checkmark.circle.fill" : "checkmark.circle",
                         isWatched ? "Vu" : "Pas vu",
                         tint: isWatched ? .green : .gray) {
                toggleWatched()
            }
        
            if isWatched {
                actionButton("arrow.clockwise",
                             "Rewatch",
                             tint: .green) {
                    rewatch()
                }
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
            actionButton(isLiked ? "heart.fill" : "heart",
                         "Like",
                         tint: isLiked ? .red : .gray) {
                toggleLike()
            }
            actionButton(isInCollection ? "shippingbox.fill" : "shippingbox",
                         "Collection",
                         tint: isInCollection ? .orange : .gray) {
                toggleCollection()
            }
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
    
    // MARK: - Ma note + moyenne TMDB
    
    private var ratingCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
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
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Moyenne TMDB")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                        Text(viewModel.averageRatingText)
                            .font(.title3.bold())
                    }
                    if !viewModel.voteCountText.isEmpty {
                        Text(viewModel.voteCountText)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
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
    
    
    // MARK: - Collection Entries
    
    private var isInCollection: Bool { collectionEntries.first != nil }
    
    private func toggleCollection() {
        if let entry = collectionEntries.first {
            modelContext.delete(entry)
        } else {
            modelContext.insert(CollectionEntry(mediaId: item.id,
                                                mediaType: item.mediaType,
                                                title: item.title,
                                                posterPath: item.posterPath))
        }
    }
    
    // MARK: - Ma critique
    
    private var reviewSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Ma critique").font(.headline)
                Spacer()
                if hasReview {
                    Button("Modifier") {
                        reviewDraft = existingReview?.text ?? ""
                    }
                    .font(.caption)
                }
            }
            
            TextEditor(text: $reviewDraft)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 120)
                .padding(8)
                .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
                .overlay(alignment: .topLeading) {
                    if reviewDraft.isEmpty {
                        Text("Partage ton avis sur ce film…")
                            .foregroundStyle(.secondary)
                            .padding(16)
                            .allowsHitTesting(false)
                    }
                }
            
            Button {
                saveReview()
            } label: {
                Text(hasReview ? "Mettre à jour" : "Publier")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
        }
        .padding(.horizontal)
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
    
    // MARK: - Où regarder
    
    private var streamingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Où regarder").font(.headline)
            
            if viewModel.providers.isEmpty {
                Text("Non disponible en streaming")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.providers) { provider in
                            VStack(spacing: 4) {
                                AsyncImage(url: provider.logo_path?.tmdbPosterURL(size: .w185)) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(.gray.opacity(0.3))
                                }
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                
                                Text(provider.provider_name)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            .frame(width: 70)
                        }
                    }
                }
            }
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
    .modelContainer(for: [MediaItemEntity.self, WatchedEntry.self, WatchlistEntry.self, ListEntity.self, ListItemEntry.self, LikeEntry.self, ReviewEntry.self], inMemory: true)
}
