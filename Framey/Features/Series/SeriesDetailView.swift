//
//  SeriesDetailView.swift
//  Framey
//
//  Created by Fabian Dargaud on 05/09/2026.
//

import SwiftUI
import SwiftData

struct SeriesDetailView: View {
    let item: MediaItemEntity
    
    // MARK: - État
    
    @State private var details: TVDetails?
    @State private var currentSeason: TVSeason?
    @State private var selectedSeasonNumber = 1
    @State private var showingNotes = false
    @State private var ratingText = ""
    @State private var episodeToRateFromList: TVEpisode?
    @State private var ratingSeasonForSheet = 1
    @FocusState private var ratingFocused: Bool
    
    // MARK: - SwiftData
    
    @Environment(\.modelContext) private var modelContext
    @Query private var watchedEntries: [WatchedEntry]
    @Query private var watchlistEntries: [WatchlistEntry]
    @Query private var likeEntries: [LikeEntry]
    @Query private var allEpisodeWatches: [EpisodeWatchEntry]
    
    init(item: MediaItemEntity) {
        self.item = item
        let id = item.id
        let type = item.mediaTypeRaw
        _watchedEntries = Query(filter: #Predicate<WatchedEntry> { $0.mediaId == id && $0.mediaTypeRaw == type })
        _watchlistEntries = Query(filter: #Predicate<WatchlistEntry> { $0.mediaId == id && $0.mediaTypeRaw == type })
        _likeEntries = Query(filter: #Predicate<LikeEntry> { $0.mediaId == id && $0.mediaTypeRaw == type })
        _allEpisodeWatches = Query(filter: #Predicate<EpisodeWatchEntry> { $0.seriesId == id })
    }
    
    // MARK: - Calculs
    
    private var latestWatch: WatchedEntry? {
        watchedEntries.sorted { $0.dateWatched > $1.dateWatched }.first
    }
    private var seriesRating: Double { latestWatch?.seriesRating ?? 0 }
    private var isInWatchlist: Bool { watchlistEntries.first != nil }
    private var isLiked: Bool { likeEntries.first != nil }
    private var currentRating: Double { parseRating(ratingText) ?? seriesRating }
    
    private var episodeWatchesForSeason: [EpisodeWatchEntry] {
        allEpisodeWatches.filter { $0.seasonNumber == selectedSeasonNumber }
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                actionsRow
                seriesRatingCard
                episodeRatingSection
                if !item.overview.isEmpty {
                    synopsisSection
                }
                informationsSection
            }
            .padding(.bottom, 32)
        }
        .background(Color.black.ignoresSafeArea())
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            details = try? await MovieService.fetchTVDetails(id: item.id)
            await loadSeason(1)
            if seriesRating > 0 {
                ratingText = seriesRating.formatted(.number.precision(.fractionLength(1)))
            }
        }
        .onChange(of: selectedSeasonNumber) { _, new in
            Task { await loadSeason(new) }
        }
        .onChange(of: seriesRating) { _, newValue in
            if !ratingFocused, newValue > 0 {
                ratingText = newValue.formatted(.number.precision(.fractionLength(1)))
            }
        }
        .sheet(isPresented: $showingNotes) {
            EpisodeNotesGridView(item: item, seasonCount: details?.number_of_seasons ?? 1)
                .preferredColorScheme(.dark)
        }
        .sheet(item: $episodeToRateFromList) { episode in
            EpisodeRatingSheet(series: item,
                               seasonNumber: ratingSeasonForSheet,
                               episode: episode)
                .preferredColorScheme(.dark)
        }
    }
    
    // MARK: - Chargement
    
    private func loadSeason(_ number: Int) async {
        currentSeason = try? await MovieService.fetchTVSeason(seriesId: item.id, seasonNumber: number)
    }
    
    // MARK: - Actions SwiftData
    
    private func parseRating(_ text: String) -> Double? {
        let normalized = text.replacingOccurrences(of: ",", with: ".")
        guard let value = Double(normalized) else { return nil }
        return min(10, max(0, (value * 10).rounded() / 10))
    }
    
    private func setSeriesRating(_ value: Double) {
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
        entry.seriesRating = value
        removeFromWatchlist()
    }
    
    private func toggleWatchlist() {
        if let entry = watchlistEntries.first {
            modelContext.delete(entry)
        } else {
            modelContext.insert(WatchlistEntry(mediaId: item.id,
                                               mediaType: item.mediaType,
                                               title: item.title,
                                               posterPath: item.posterPath))
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
    
    // MARK: - Header
    
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
                    LinearGradient(colors: [.clear, .black], startPoint: .center, endPoint: .bottom)
                }
            
            HStack(alignment: .bottom, spacing: 16) {
                AsyncImage(url: item.posterPath?.tmdbPosterURL(size: .w342)) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Rectangle().fill(.gray.opacity(0.3)).overlay(ProgressView())
                }
                .frame(width: 120, height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 6)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                    Text(metaLine)
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.8))
                }
                Spacer(minLength: 0)
            }
            .padding()
        }
    }
    
    private var metaLine: String {
        var parts: [String] = []
        if let year = item.releaseDate?.formatted(.dateTime.year()) {
            parts.append(year)
        }
        if let details {
            parts.append("\(details.number_of_seasons) saison\(details.number_of_seasons > 1 ? "s" : "")")
            parts.append(details.genreNames)
        }
        return parts.joined(separator: " • ")
    }
    
    // MARK: - Actions (Watchlist · Like · Mes notes)
    
    private var actionsRow: some View {
        HStack(spacing: 0) {
            actionButton(isInWatchlist ? "eye.fill" : "eye",
                         "Watchlist",
                         tint: isInWatchlist ? .blue : .gray) { toggleWatchlist() }
            actionButton(isLiked ? "heart.fill" : "heart",
                         "Like",
                         tint: isLiked ? .red : .gray) { toggleLike() }
            actionButton("square.grid.3x3",
                         "Mes notes",
                         tint: .purple) { showingNotes = true }
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
    
    // MARK: - Note série (saisie décimale + couleur du dégradé)
    
    private var seriesRatingCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Ma note").font(.headline)
                Spacer()
                Text(details.map { String(format: "TMDB %.1f", $0.vote_average) } ?? "")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            HStack(alignment: .center, spacing: 16) {
                Text(currentRating > 0 ? currentRating.formatted(.number.precision(.fractionLength(1))) : "—")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(currentRating > 0 ? ratingColor(currentRating) : .gray)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("/ 10").font(.caption).foregroundStyle(.secondary)
                    Text(ratingLabel(currentRating)).font(.caption2).foregroundStyle(.secondary)
                }
                
                Spacer()
                
                TextField("8.3", text: $ratingText)
                    .keyboardType(.decimalPad)
                    .focused($ratingFocused)
                    .multilineTextAlignment(.center)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .frame(width: 80)
                    .padding(.vertical, 8)
                    .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
                    .onChange(of: ratingText) { _, newText in
                        if let value = parseRating(newText) {
                            setSeriesRating(value)
                        } else if newText.isEmpty {
                            setSeriesRating(0)
                        }
                    }
            }
            
            LinearGradient(colors: [.red, .yellow, Color(red: 0, green: 0.4, blue: 0.1)],
                           startPoint: .leading, endPoint: .trailing)
                .frame(height: 4)
                .clipShape(Capsule())
        }
        .padding()
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
    
    // MARK: - Liste des épisodes
    
    private var episodeRatingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Épisodes")
                    .font(.headline)
                Spacer()
                if let details {
                    Picker("Saison", selection: $selectedSeasonNumber) {
                        ForEach(1...details.number_of_seasons, id: \.self) { n in
                            Text("Saison \(n)").tag(n)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.purple)
                }
            }
            
            if let season = currentSeason {
                VStack(spacing: 0) {
                    ForEach(season.episodes) { episode in
                        episodeRow(episode)
                        if episode.episode_number < season.episodes.count {
                            Divider().overlay(.white.opacity(0.08))
                        }
                    }
                }
                .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 100)
            }
        }
        .padding(.horizontal)
    }
    
    private func episodeRow(_ episode: TVEpisode) -> some View {
        let existingRating = episodeWatchesForSeason.first(where: {
            $0.episodeNumber == episode.episode_number
        })?.rating
        
        return Button {
            ratingSeasonForSheet = selectedSeasonNumber
            episodeToRateFromList = episode
        } label: {
            HStack(spacing: 12) {
                Text("\(episode.episode_number)")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(episode.name)
                        .font(.subheadline)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(episode.overview)
                        .font(.caption2)
                        .foregroundStyle(.gray)
                        .lineLimit(2)
                }
                
                Spacer()
                
                if let r = existingRating {
                    Text(String(format: "%.1f", r))
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(ratingColor(r))
                } else {
                    Image(systemName: "plus.circle")
                        .foregroundStyle(.purple)
                }
            }
            .padding(12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Sections infos
    
    private var synopsisSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Synopsis").font(.headline)
            Text(item.overview)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
    }
    
    private var informationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Informations").font(.headline)
            VStack(spacing: 0) {
                infoRow("calendar", "Première diffusion",
                        item.releaseDate?.formatted(date: .long, time: .omitted) ?? "—")
                Divider()
                infoRow("tv", "Saisons", details.map { "\($0.number_of_seasons)" } ?? "—")
                Divider()
                infoRow("play.rectangle", "Épisodes", details.map { "\($0.number_of_episodes)" } ?? "—")
            }
            .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal)
    }
    
    private func infoRow(_ icon: String, _ label: String, _ value: String) -> some View {
        HStack {
            Label(label, systemImage: icon).foregroundStyle(.secondary)
            Spacer()
            Text(value).multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
        .padding()
    }
    
    // MARK: - Couleurs & libellés
    
    private func ratingColor(_ rating: Double) -> Color {
        let t = max(0, min(1, rating / 10.0))
        let r, g, b: Double
        if t <= 0.5 {
            let x = t * 2
            r = 1.0; g = x; b = 0
        } else {
            let x = (t - 0.5) * 2
            r = 1.0 - x; g = 1.0 - (0.6 * x); b = 0 + (0.1 * x)
        }
        return Color(red: r, green: g, blue: b)
    }
    
    private func ratingLabel(_ rating: Double) -> String {
        switch rating {
        case 0: "À noter"
        case 0.1..<3: "À fuir"
        case 3..<5: "Moyen"
        case 5..<7: "Sympa"
        case 7..<9: "Très bon"
        case 9...10: "Chef-d'œuvre"
        default: "À noter"
        }
    }
}

#Preview {
    NavigationStack {
        SeriesDetailView(item: MediaItemEntity(id: 1396, mediaType: .tv, title: "Breaking Bad"))
            .preferredColorScheme(.dark)
    }
    .modelContainer(for: [MediaItemEntity.self, WatchedEntry.self, WatchlistEntry.self, LikeEntry.self, EpisodeWatchEntry.self], inMemory: true)
}
