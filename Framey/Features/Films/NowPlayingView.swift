//
//  NowPlayingView.swift
//  Framey
//
//  Created by Fabian Dargaud on 04/09/2026.
//

import SwiftUI

struct NowPlayingView: View {
    @State private var movies: [MediaItemEntity] = []
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(movies, id: \.id) { movie in
                    NavigationLink(value: movie) {
                        gridCard(movie)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("Au cinéma")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }
    
    private func load() async {
        let region = Locale.current.region?.identifier ?? "FR"
        movies = (try? await MovieService.fetchNowPlaying(region: region)) ?? []
    }
    
    private func gridCard(_ movie: MediaItemEntity) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Color.clear
                .aspectRatio(2/3, contentMode: .fit)
                .overlay {
                    AsyncImage(url: movie.posterPath?.tmdbPosterURL()) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        case .failure:
                            Rectangle().fill(.gray.opacity(0.3))
                                .overlay(Image(systemName: "film").foregroundStyle(.secondary))
                        default:
                            Rectangle().fill(.gray.opacity(0.3)).overlay(ProgressView())
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(alignment: .topLeading) {
                    if movie.isReleasedThisWeek {
                        Text("Nouveau")
                            .font(.system(size: 9, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.purple, in: Capsule())
                            .foregroundStyle(.white)
                            .padding(6)
                    }
                }
            
            Text(movie.title)
                .font(.caption)
                .lineLimit(2, reservesSpace: true)
                .foregroundStyle(.white)
            
            if let date = movie.releaseDate {
                Text(date.formatted(.dateTime.day().month(.abbreviated)))
                    .font(.caption2)
                    .foregroundStyle(.gray)
            }
        }
    }
}

#Preview {
    NavigationStack {
        NowPlayingView()
            .preferredColorScheme(.dark)
    }
}
