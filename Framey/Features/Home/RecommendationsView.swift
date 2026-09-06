//
//  RecommendationsView.swift
//  Framey
//
//  Created by Fabian Dargaud on 06/09/2026.
//


import SwiftUI
import SwiftData

struct RecommendationsView: View {
    @Query(sort: \WatchedEntry.dateWatched, order: .reverse) private var watched: [WatchedEntry]
    @State private var recommendations: [MediaItemEntity] = []
    
    private var seedMovies: [WatchedEntry] {
        watched.filter { ($0.rating ?? 0) >= 4 }
    }
    
    var body: some View {
        Group {
            if !recommendations.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Pour toi")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(recommendations, id: \.id) { item in
                                NavigationLink(value: item) {
                                    MediaPosterCard(title: item.title, posterPath: item.posterPath)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
        }
        .task { await load() }
    }
    
    private func load() async {
        let seeds = Array(seedMovies.prefix(3))
        guard !seeds.isEmpty else { return }
        
        let watchedIds = Set(watched.map(\.mediaId))
        var merged: [MediaItemEntity] = []
        var seen = Set<Int>()
        
        for seed in seeds {
            guard let recs = try? await MovieService.fetchRecommendations(for: seed.mediaId) else { continue }
            for rec in recs where !seen.contains(rec.id) && !watchedIds.contains(rec.id) {
                seen.insert(rec.id)
                merged.append(rec)
            }
        }
        
        recommendations = Array(merged.prefix(20))
    }
}

#Preview {
    NavigationStack {
        RecommendationsView()
            .preferredColorScheme(.dark)
    }
    .modelContainer(for: [WatchedEntry.self], inMemory: true)
}
