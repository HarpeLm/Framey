//
//  EpisodeRatingSheet.swift
//  Framey
//
//  Created by Fabian Dargaud on 05/09/2026.
//


import SwiftUI
import SwiftData

struct EpisodeRatingSheet: View {
    let series: MediaItemEntity
    let seasonNumber: Int
    let episode: TVEpisode
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var episodeWatches: [EpisodeWatchEntry]
    
    @State private var rating: Double = 0
    
    init(series: MediaItemEntity, seasonNumber: Int, episode: TVEpisode) {
        self.series = series
        self.seasonNumber = seasonNumber
        self.episode = episode
        
        let sid = series.id
        let s = seasonNumber
        let e = episode.episode_number
        _episodeWatches = Query(filter: #Predicate<EpisodeWatchEntry> {
            $0.seriesId == sid && $0.seasonNumber == s && $0.episodeNumber == e
        })
    }
    
    private var existing: EpisodeWatchEntry? { episodeWatches.first }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("S\(seasonNumber)E\(episode.episode_number) · \(episode.name)")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                Text(rating > 0 ? String(format: "%.1f", rating) : "—")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundStyle(rating > 0 ? ratingColor(rating) : .gray)
                
                Slider(value: $rating, in: 0...10, step: 0.5)
                    .tint(ratingColor(rating))
                
                Text(ratingLabel(rating))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Noter l'épisode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Enregistrer") {
                        save()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                rating = existing?.rating ?? 0
            }
        }
        .presentationDetents([.medium])
    }
    
    private func save() {
        if rating == 0 {
            // Pas de note = on supprime l'entrée éventuelle
            if let existing {
                modelContext.delete(existing)
            }
            return
        }
        
        if let existing {
            existing.rating = rating
            existing.dateWatched = .now
        } else {
            let entry = EpisodeWatchEntry(
                seriesId: series.id,
                seriesTitle: series.title,
                posterPath: series.posterPath,
                seasonNumber: seasonNumber,
                episodeNumber: episode.episode_number,
                episodeTitle: episode.name,
                rating: rating,
                dateWatched: .now
            )
            modelContext.insert(entry)
        }
    }
    
    private func ratingColor(_ rating: Double) -> Color {
        let t = max(0, min(1, rating / 10.0))
        let r, g, b: Double
        if t <= 0.5 {
            let x = t * 2
            r = 1.0
            g = x
            b = 0
        } else {
            let x = (t - 0.5) * 2
            r = 1.0 - x
            g = 1.0 - (0.6 * x)
            b = 0 + (0.1 * x)
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