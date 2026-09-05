//
//  FeaturedHeroCard.swift
//  Framey
//
//  Created by Fabian Dargaud on 04/09/2026.
//

import SwiftUI

struct FeaturedHeroCard: View {
    let movie: MediaItemEntity
    
    var body: some View {
        Color.clear
            .overlay {
                AsyncImage(url: movie.backdropPath?.tmdbPosterURL(size: .w780)) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        Rectangle().fill(.gray.opacity(0.3))
                    }
                }
            }
            .clipped()
            .overlay {
                LinearGradient(colors: [.black.opacity(0.1), .black.opacity(0.9)],
                               startPoint: .top, endPoint: .bottom)
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(movie.title)
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    
                    Text(movie.overview)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.85))
                        .lineLimit(2)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
            .overlay(alignment: .topLeading) {
                HStack {
                    Text(movie.mediaType == .tv ? "Série à la une" : "À l'affiche")
                        .font(.caption.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.purple, in: Capsule())
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Label("Voir la fiche", systemImage: "play.fill")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(.white.opacity(0.2), in: Capsule())
                        .foregroundStyle(.white)
                }
                .padding(16)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    FeaturedHeroCard(movie: MediaItemEntity(id: 157336, title: "Interstellar", overview: "Un voyage au-delà des étoiles."))
        .frame(height: 240)
        .padding(.horizontal, 20)
        .preferredColorScheme(.dark)
}
