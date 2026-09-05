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
    @State private var ratingText = ""
    
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
    
    private var parsedRating: Double? {
        let normalized = ratingText.replacingOccurrences(of: ",", with: ".")
        guard let value = Double(normalized) else { return nil }
        return min(10, max(0, (value * 10).rounded() / 10))
    }
    
    private var displayRating: Double { parsedRating ?? existing?.rating ?? 0 }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("S\(seasonNumber)E\(episode.episode_number) · \(episode.name)")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                Text(displayRating > 0 ? displayRating.formatted(.number.precision(.fractionLength(1))) : "—")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundStyle(displayRating > 0 ? ratingColor(displayRating) : .gray)
                
                TextField("Ex : 8.3", text: $ratingText)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .frame(width: 120)
                    .padding(.vertical, 10)
                    .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                
                Text(ratingLabel(displayRating))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                LinearGradient(colors: [.red, .yellow, Color(red: 0, green: 0.4, blue: 0.1)],
                               startPoint: .leading, endPoint: .trailing)
                    .frame(height: 4)
                    .clipShape(Capsule())
                    .padding(.horizontal, 40)
                
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
                if let rating = existing?.rating, rating > 0 {
                    ratingText = rating.formatted(.number.precision(.fractionLength(1)))
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    private func save() {
        guard let value = parsedRating, value > 0 else {
            if let existing { modelContext.delete(existing) }
            return
        }
        
        if let existing {
            existing.rating = value
            existing.dateWatched = .now
        } else {
            let entry = EpisodeWatchEntry(seriesId: series.id,
                                          seriesTitle: series.title,
                                          posterPath: series.posterPath,
                                          seasonNumber: seasonNumber,
                                          episodeNumber: episode.episode_number,
                                          episodeTitle: episode.name,
                                          rating: value,
                                          dateWatched: .now)
            modelContext.insert(entry)
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
