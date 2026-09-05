//
//  EpisodeNotesGridView.swift
//  Framey
//
//  Created by Fabian Dargaud on 05/09/2026.
//


import SwiftUI
import SwiftData

struct EpisodeNotesGridView: View {
    let item: MediaItemEntity
    let seasonCount: Int
    
    @State private var seasons: [TVSeason] = []
    @State private var episodeToRate: TVEpisode?
    @State private var ratingSeasonNumber = 1
    @Query private var episodeWatches: [EpisodeWatchEntry]
    
    init(item: MediaItemEntity, seasonCount: Int) {
        self.item = item
        self.seasonCount = seasonCount
        let sid = item.id
        _episodeWatches = Query(filter: #Predicate<EpisodeWatchEntry> { $0.seriesId == sid })
    }
    
    private var maxEpisodes: Int { seasons.map(\.episodes.count).max() ?? 0 }
    
    var body: some View {
        NavigationStack {
            // Horizontal extérieur : les colonnes (saisons) défilent ensemble, librement
            ScrollView(.horizontal, showsIndicators: false) {
                // Vertical intérieur : défilement "lourd" qui s'aimante aux lignes
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 3) {
                        headerRow
                        ForEach(1...max(maxEpisodes, 1), id: \.self) { episodeNumber in
                            row(episodeNumber)
                        }
                    }
                    .scrollTargetLayout()
                    .padding()
                }
                .scrollTargetBehavior(.viewAligned)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Mes notes d'épisodes")
            .navigationBarTitleDisplayMode(.inline)
            .task { await loadSeasons() }
            .sheet(item: $episodeToRate) { episode in
                EpisodeRatingSheet(series: item,
                                   seasonNumber: ratingSeasonNumber,
                                   episode: episode)
                    .preferredColorScheme(.dark)
            }
        }
    }
    
    // MARK: - Chargement de toutes les saisons (en parallèle)
    
    private func loadSeasons() async {
        seasons = await withTaskGroup(of: TVSeason?.self) { group in
            for number in 1...max(seasonCount, 1) {
                group.addTask {
                    try? await MovieService.fetchTVSeason(seriesId: item.id, seasonNumber: number)
                }
            }
            var result: [TVSeason] = []
            for await season in group {
                if let season { result.append(season) }
            }
            return result.sorted { $0.season_number < $1.season_number }
        }
    }
    
    // MARK: - Grille compacte (S1E1 visible dès l'ouverture)
    
    private var headerRow: some View {
        HStack(spacing: 3) {
            Text("")
                .frame(width: 26)
            ForEach(seasons, id: \.season_number) { season in
                Text("S\(season.season_number)")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.gray)
                    .frame(width: 40)
            }
        }
    }
    
    private func row(_ episodeNumber: Int) -> some View {
        HStack(spacing: 3) {
            Text("E\(episodeNumber)")
                .font(.caption2)
                .foregroundStyle(.gray)
                .frame(width: 26)
            ForEach(seasons, id: \.season_number) { season in
                cell(season: season, episodeNumber: episodeNumber)
            }
        }
    }
    
    @ViewBuilder
    private func cell(season: TVSeason, episodeNumber: Int) -> some View {
        if let episode = season.episodes.first(where: { $0.episode_number == episodeNumber }) {
            let rating = episodeWatches.first {
                $0.seasonNumber == season.season_number && $0.episodeNumber == episodeNumber
            }?.rating
            
            Button {
                ratingSeasonNumber = season.season_number
                episodeToRate = episode
            } label: {
                Text(rating.map { $0.formatted(.number.precision(.fractionLength(1))) } ?? "·")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 26)
                    .background(rating.map { ratingColor($0) } ?? Color.white.opacity(0.06),
                                in: RoundedRectangle(cornerRadius: 5))
            }
            .buttonStyle(.plain)
        } else {
            Color.clear.frame(width: 40, height: 26)
        }
    }
    
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
}
