//
//  QuickLogSheet.swift
//  Framey
//
//  Created by Fabian Dargaud on 06/09/2026.
//

import SwiftUI
import SwiftData

struct QuickLogSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("recentSearchesData") private var recentSearchesData = ""
    
    @State private var query = ""
    @State private var results: [MediaItemEntity] = []
    @State private var selected: MediaItemEntity?
    
    // Formulaire
    @State private var date = Date()
    @State private var movieRating = 0
    @State private var seriesRatingText = ""
    @State private var isLiked = false
    @State private var reviewText = ""
    @State private var tagsText = ""
    @State private var isRewatch = false
    
    // Données existantes du titre sélectionné
    @State private var existingWatches: [WatchedEntry] = []
    @State private var existingLike: LikeEntry?
    @State private var existingReview: ReviewEntry?
    
    
    @Query(sort: \WatchedEntry.dateWatched, order: .reverse) private var watched: [WatchedEntry]
    
    var body: some View {
        NavigationStack {
            Group {
                if let selected {
                    logForm(for: selected)
                } else {
                    searchStep
                }
            }
            .navigationTitle(selected == nil ? "Ajouter un titre" : "J'ai regardé…")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Annuler") {
                        if selected != nil {
                            selected = nil
                        } else {
                            dismiss()
                        }
                    }
                }
                if selected != nil {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Enregistrer") {
                            save(selected!)
                        }
                        .fontWeight(.semibold)
                        .foregroundStyle(.green)
                    }
                }
            }
        }
        .presentationDetents([.large])
    }
    
    // MARK: - Étape 1 : recherche + récentes
    
    private var searchStep: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").foregroundStyle(.gray)
                TextField("Nom du film ou de la série", text: $query)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .foregroundStyle(.white)
                if !query.isEmpty {
                    Button { query = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                    }
                    .foregroundStyle(.gray)
                }
            }
            .padding(10)
            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 20)
            .padding(.top, 12)
            
            ScrollView {
                if query.trimmingCharacters(in: .whitespaces).count < 2 {
                    recentSearchesSection
                    recentTitlesSection
                } else {
                    resultsList
                }
            }
        }
        .task(id: query) { await runSearch() }
    }

    private var recentSearches: [String] {
        get {
            guard let data = recentSearchesData.data(using: .utf8),
                  let arr = try? JSONDecoder().decode([String].self, from: data) else { return [] }
            return arr
        }
        nonmutating set {
            let data = try? JSONEncoder().encode(newValue)
            recentSearchesData = String(data: data ?? Data(), encoding: .utf8) ?? ""
        }
    }
    
    private var recentSearchesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !recentSearches.isEmpty {
                Text("Recherches récentes")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.gray)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 4)
                
                ForEach(recentSearches, id: \.self) { term in
                    Button {
                        query = term
                    } label: {
                        HStack {
                            Text(term)
                                .foregroundStyle(.white)
                            Spacer()
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                    }
                    .buttonStyle(.plain)
                    Divider().overlay(.white.opacity(0.08)).padding(.leading, 20)
                }
            }
        }
    }
    
    private var recentTitlesSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            if !recentTitles.isEmpty {
                Text("Films & séries récents")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.gray)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 4)
                
                ForEach(recentTitles, id: \.id) { item in
                    Button {
                        selected = item
                        loadExisting(item)
                    } label: {
                        HStack(spacing: 12) {
                            AsyncImage(url: item.posterPath?.tmdbPosterURL()) { phase in
                                if let image = phase.image {
                                    image.resizable().aspectRatio(2/3, contentMode: .fill)
                                } else {
                                    Rectangle().fill(.gray.opacity(0.3))
                                }
                            }
                            .frame(width: 40, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.title)
                                    .font(.subheadline)
                                    .foregroundStyle(.white)
                                    .lineLimit(2)
                                Text(item.mediaType == .tv ? "Série" : "Film")
                                    .font(.caption2)
                                    .foregroundStyle(.gray)
                            }
                            Spacer()
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundStyle(.gray)
                        }
                        .padding(10)
                        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal, 20)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    private var recentTitles: [MediaItemEntity] {
        var seen = Set<String>()
        var result: [MediaItemEntity] = []
        for entry in watched {
            let key = "\(entry.mediaTypeRaw)-\(entry.mediaId)"
            if seen.insert(key).inserted {
                result.append(entry.asMediaItem)
            }
            if result.count >= 10 { break }
        }
        return result
    }
    
    private var resultsList: some View {
        LazyVStack(spacing: 10) {
            ForEach(Array(results.enumerated()), id: \.offset) { _, item in
                Button {
                    addRecentSearch(query)
                    selected = item
                    loadExisting(item)
                } label: {
                    HStack(spacing: 12) {
                        AsyncImage(url: item.posterPath?.tmdbPosterURL()) { phase in
                            if let image = phase.image {
                                image.resizable().aspectRatio(2/3, contentMode: .fill)
                            } else {
                                Rectangle().fill(.gray.opacity(0.3))
                            }
                        }
                        .frame(width: 40, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .font(.subheadline)
                                .foregroundStyle(.white)
                                .lineLimit(2)
                            Text(item.mediaType == .tv ? "Série" : "Film")
                                .font(.caption2)
                                .foregroundStyle(.gray)
                        }
                        Spacer()
                    }
                    .padding(10)
                    .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
    }
    
    // MARK: - Étape 2 : formulaire "J'ai regardé…"
    
    private func logForm(for item: MediaItemEntity) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                // Ligne du film
                HStack(spacing: 12) {
                    AsyncImage(url: item.posterPath?.tmdbPosterURL()) { phase in
                        if let image = phase.image {
                            image.resizable().aspectRatio(2/3, contentMode: .fill)
                        } else {
                            Rectangle().fill(.gray.opacity(0.3))
                        }
                    }
                    .frame(width: 44, height: 66)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.title)
                            .font(.headline)
                            .foregroundStyle(.white)
                        if let year = item.releaseDate?.formatted(.dateTime.year()) {
                            Text(year)
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                    }
                    Spacer()
                }
                .padding(16)
                .background(.white.opacity(0.04))
                
                // Date
                HStack {
                    Text("Date").foregroundStyle(.white)
                    Spacer()
                    DatePicker("", selection: $date, displayedComponents: .date)
                        .labelsHidden()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                Divider().overlay(.white.opacity(0.08)).padding(.leading, 20)
                
                // Note + Like
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ma note").foregroundStyle(.white)
                        if item.mediaType == .tv {
                            HStack(spacing: 8) {
                                TextField("8.3", text: $seriesRatingText)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.center)
                                    .font(.title3.bold())
                                    .foregroundStyle(.white)
                                    .frame(width: 70)
                                    .padding(.vertical, 6)
                                    .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                                Text("/ 10").foregroundStyle(.gray)
                            }
                        } else {
                            starsRow
                        }
                    }
                    Spacer()
                    VStack(spacing: 8) {
                        Text("Like").foregroundStyle(.white)
                        Button { isLiked.toggle() } label: {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .font(.title2)
                                .foregroundStyle(isLiked ? .red : .gray)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                Divider().overlay(.white.opacity(0.08)).padding(.leading, 20)
                
                // Critique
                TextEditor(text: $reviewText)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 120)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .overlay(alignment: .topLeading) {
                        if reviewText.isEmpty {
                            Text("Ajouter une critique…")
                                .foregroundStyle(.gray)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .allowsHitTesting(false)
                        }
                    }
                
                Divider().overlay(.white.opacity(0.08))
                
                // Tags
                TextField("Ajouter des tags…", text: $tagsText)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                
                Divider().overlay(.white.opacity(0.08))
                
                // Toggle rewatch
                Button { isRewatch.toggle() } label: {
                    VStack(spacing: 6) {
                        Image(systemName: isRewatch ? "eye.fill" : "eye")
                            .font(.title3)
                        Text("Déjà vu auparavant")
                            .font(.caption2)
                    }
                    .foregroundStyle(isRewatch ? .green : .gray)
                }
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
        }
    }
    
    private var starsRow: some View {
        HStack(spacing: 6) {
            ForEach(1...5, id: \.self) { star in
                Button {
                    movieRating = (movieRating == star) ? 0 : star
                } label: {
                    Image(systemName: star <= movieRating ? "star.fill" : "star")
                        .font(.title2)
                        .foregroundStyle(star <= movieRating ? Color.green : Color.gray.opacity(0.4))
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Logique
    
    private func loadExisting(_ item: MediaItemEntity) {
        let id = item.id
        let type = item.mediaTypeRaw
        
        let watchDesc = FetchDescriptor<WatchedEntry>(
            predicate: #Predicate<WatchedEntry> { $0.mediaId == id && $0.mediaTypeRaw == type },
            sortBy: [SortDescriptor(\.dateWatched, order: .reverse)]
        )
        existingWatches = (try? modelContext.fetch(watchDesc)) ?? []
        
        let likeDesc = FetchDescriptor<LikeEntry>(
            predicate: #Predicate<LikeEntry> { $0.mediaId == id && $0.mediaTypeRaw == type }
        )
        existingLike = (try? modelContext.fetch(likeDesc))?.first
        
        let reviewDesc = FetchDescriptor<ReviewEntry>(
            predicate: #Predicate<ReviewEntry> { $0.mediaId == id && $0.mediaTypeRaw == type }
        )
        existingReview = (try? modelContext.fetch(reviewDesc))?.first
        
        // Pré-remplissage
        date = existingWatches.first?.dateWatched ?? Date()
        movieRating = existingWatches.first?.rating ?? 0
        seriesRatingText = existingWatches.first?.seriesRating.map {
            $0.formatted(.number.precision(.fractionLength(1)))
        } ?? ""
        isLiked = existingLike != nil
        reviewText = existingReview?.text ?? ""
        tagsText = existingWatches.first?.tagsRaw ?? ""
        isRewatch = false
    }
    
    private func save(_ item: MediaItemEntity) {
        let ratingValue: Int? = item.mediaType == .tv ? nil : (movieRating > 0 ? movieRating : nil)
        let seriesValue: Double? = item.mediaType == .tv ? parseSeries(seriesRatingText) : nil
        let tags = tagsText.trimmingCharacters(in: .whitespaces)
        
        // Visionnage : rewatch = nouvelle entrée, sinon mise à jour du dernier
        if isRewatch || existingWatches.isEmpty {
            let entry = WatchedEntry(mediaId: item.id,
                                     mediaType: item.mediaType,
                                     title: item.title,
                                     posterPath: item.posterPath,
                                     dateWatched: date,
                                     rating: ratingValue,
                                     tagsRaw: tags)
            entry.seriesRating = seriesValue
            modelContext.insert(entry)
        } else if let latest = existingWatches.first {
            latest.dateWatched = date
            latest.rating = ratingValue
            latest.seriesRating = seriesValue
            latest.tagsRaw = tags
        }
        
        // Like
        if isLiked, existingLike == nil {
            modelContext.insert(LikeEntry(mediaId: item.id, mediaType: item.mediaType))
        } else if !isLiked, let like = existingLike {
            modelContext.delete(like)
        }
        
        // Critique
        let trimmed = reviewText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            if let review = existingReview { modelContext.delete(review) }
        } else if let review = existingReview {
            review.text = trimmed
            review.dateModified = .now
        } else {
            modelContext.insert(ReviewEntry(mediaId: item.id, mediaType: item.mediaType, text: trimmed))
        }
        
        // Retrait automatique watchlist (doc P0)
        let wid = item.id
        let wtype = item.mediaTypeRaw
        let watchlistDesc = FetchDescriptor<WatchlistEntry>(
            predicate: #Predicate<WatchlistEntry> { $0.mediaId == wid && $0.mediaTypeRaw == wtype }
        )
        if let entry = (try? modelContext.fetch(watchlistDesc))?.first {
            modelContext.delete(entry)
        }
        
        dismiss()
    }
    
    private func parseSeries(_ text: String) -> Double? {
        let normalized = text.replacingOccurrences(of: ",", with: ".")
        guard let value = Double(normalized) else { return nil }
        return min(10, max(0, (value * 10).rounded() / 10))
    }
    
    private func addRecentSearch(_ term: String) {
        let trimmed = term.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        var current = recentSearches
        current.removeAll { $0.lowercased() == trimmed.lowercased() }
        current.insert(trimmed, at: 0)
        // ✅ Assignation manquante dans la version précédente
        recentSearches = Array(current.prefix(8))
    }
    
    private func runSearch() async {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard trimmed.count >= 2 else {
            results = []
            return
        }
        
        try? await Task.sleep(for: .milliseconds(350))
        guard !Task.isCancelled else { return }
        
        if let multiResults = try? await MovieService.searchMulti(query: trimmed) {
            results = Array(multiResults.prefix(40))
        } else {
            // Fallback si multi_search échoue
            async let movies = MovieService.searchMovies(query: trimmed)
            async let series = MovieService.searchTV(query: trimmed)
            
            let m = (try? await movies) ?? []
            let s = (try? await series) ?? []
            
            results = Array((s + m).prefix(40))
        }
    }
}

#Preview {
    QuickLogSheet()
        .preferredColorScheme(.dark)
        .modelContainer(for: [WatchedEntry.self, WatchlistEntry.self, LikeEntry.self, ReviewEntry.self], inMemory: true)
}
