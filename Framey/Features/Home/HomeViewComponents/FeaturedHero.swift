//
//  FeaturedHero.swift
//  Framey
//
//  Created by Fabian Dargaud on 04/09/2026.
//

import SwiftUI

struct FeaturedHero: View {
    let movies: [MediaItemEntity]
    let isLoading: Bool
    
    var body: some View {
        Group {
            if isLoading {
                loadingState
            } else if movies.isEmpty {
                emptyState
            } else {
                carousel
            }
        }
    }
    
    private var carousel: some View {
        TabView {
            ForEach(movies, id: \.id) { movie in
                NavigationLink(value: movie) {
                    FeaturedHeroCard(movie: movie)
                        .padding(.horizontal, 20)
                }
                .buttonStyle(.plain)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .frame(height: 240)
    }
    
    private var loadingState: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.white.opacity(0.06))
            .frame(height: 240)
            .overlay(ProgressView())
            .padding(.horizontal, 20)
    }
    
    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.seal.fill")
                .font(.largeTitle)
                .foregroundStyle(.green)
            Text("Tu as déjà vu tous les films à l'affiche ! 🎉")
                .font(.headline)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 240)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 20)
    }
}

#Preview {
    NavigationStack {
        FeaturedHero(movies: [MediaItemEntity(id: 157336, title: "Interstellar", overview: "Un voyage au-delà des étoiles.")], isLoading: false)
            .navigationDestination(for: MediaItemEntity.self) { MovieDetailView(item: $0) }
    }
    .preferredColorScheme(.dark)
}
