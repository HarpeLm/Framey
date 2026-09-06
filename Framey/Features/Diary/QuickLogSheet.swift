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
    @Query private var watchlist: [WatchlistEntry]
    @State private var query = ""
    @State private var results: [MediaItemEntity] = []
    @State private var selected: MediaItemEntity?
    @State private var date = Date()
    @State private var movieRating = 0
    @State private var seriesRatingText = ""
    
    var body: some View {
        NavigationStack {
            Group {
                if let selected {
                    logForm(for: selected)
                } else {
                    searchList
                }
            }
            .navigationTitle("Log rapide")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(selected == nil ? "Annuler" : "Retour") {
                        if selected != nil {
                            selected = nil
                        } else {
                            dismiss()
                        }
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    // MARK: - Étape 1 : recherche
    
    private var searchList: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").foregroundStyle(.gray)
                TextField("Film ou série…", text: $query)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .foregroundStyle(.white)
            }
            .padding(10)
            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 20)
            .padding(.top, 12)
            
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(results, id: \.id) { item in
                        Button {
                            selected = item
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
        }
        .task(id: query) { await runSearch() }
    }
    
    // MARK: - Étape 2 : date + note
    
    private func logForm(for item: MediaItemEntity) -> some View {
        VStack(spacing: 24) {
            HStack(spacing: 12) {
                AsyncImage(url: item.posterPath?.tmdbPosterURL()) { phase in
                    if let image = phase.image {
                        image.resizable().aspectRatio(2/3, contentMode: .fill)
                    } else {
                        Rectangle().fill(.gray.opacity(0.3))
                    }
                }
                .frame(width: 60, height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text(item.mediaType == .tv ? "Série" : "Film")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            
            DatePicker("Date de visionnage", selection: $date, displayedComponents: .date)
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
            
            if item.mediaType == .tv {
                HStack(spacing: 12) {
                    Text("Ma note")
                        .foregroundStyle(.white)
                    TextField("8.3", text: $seriesRatingText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.center)
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                        .frame(width: 70)
                        .padding(.vertical, 6)
                        .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                    Text("/ 10")
                        .foregroundStyle(.gray)
                }
            } else {
                HStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { star in
                        Button {
                            movieRating = (movieRating == star) ? 0 : star
                        } label: {
                            Image(systemName: star <= movieRating ? "star.fill" : "star")
                                .font(.title2)
                                .foregroundStyle(star <= movieRating ? Color.yellow : Color.gray.opacity(0.4))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            Button {
                save(item)
            } label: {
                Text("Enregistrer")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.purple)
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding(.top, 20)
    }
    
    // MARK: - Actions
    
    private func save(_ item: MediaItemEntity) {
        let entry = WatchedEntry(mediaId: item.id,
                                 mediaType: item.mediaType,
                                 title: item.title,
                                 posterPath: item.posterPath,
                                 dateWatched: date)
        if item.mediaType == .tv {
            entry.seriesRating = parseSeries(seriesRatingText)
        } else if movieRating > 0 {
            entry.rating = movieRating
        }
        modelContext.insert(entry)
        
        // Retrait automatique watchlist (doc P0)
        if let watchEntry = watchlist.first(where: {
            $0.mediaId == item.id && $0.mediaTypeRaw == item.mediaTypeRaw
        }) {
            modelContext.delete(watchEntry)
        }
        
        dismiss()
    }
    
    private func parseSeries(_ text: String) -> Double? {
        let normalized = text.replacingOccurrences(of: ",", with: ".")
        guard let value = Double(normalized) else { return nil }
        return min(10, max(0, (value * 10).rounded() / 10))
    }
    
    private func runSearch() async {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard trimmed.count >= 2 else {
            results = []
            return
        }
        try? await Task.sleep(for: .milliseconds(400))
        guard !Task.isCancelled else { return }
        
        async let movies = MovieService.searchMovies(query: trimmed)
        async let series = MovieService.searchTV(query: trimmed)
        let m = (try? await movies) ?? []
        let s = (try? await series) ?? []
        results = Array((m + s).prefix(20))
    }
}

#Preview {
    QuickLogSheet()
        .preferredColorScheme(.dark)
        .modelContainer(for: [WatchedEntry.self, WatchlistEntry.self], inMemory: true)
}