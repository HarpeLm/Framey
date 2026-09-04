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
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: movie.backdropPath?.tmdbPosterURL(size: .w780)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Rectangle().fill(.gray.opacity(0.3))
            }
            .frame(maxWidth: .infinity)
            .clipped()
            .overlay {
                LinearGradient(colors: [.black.opacity(0.1), .black.opacity(0.9)],
                               startPoint: .top, endPoint: .bottom)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Spacer()
                
                Text(movie.title)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .lineLimit(1)
                
                Text(movie.overview)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.85))
                    .lineLimit(3)
            }
            .padding(16)
        }
        .overlay(alignment: .topLeading) {
            HStack {
                Text("À l'affiche")
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
    FeaturedHeroCard(movie: MediaItemEntity(id: 157336, title: "Interstellar", overview: "Un voyage au-delà des étoiles pour sauver l'humanité."))
        .frame(height: 240)
        .padding()
        .preferredColorScheme(.dark)
}
