//
//  CinemaPosterCard.swift
//  Framey
//
//  Created by Fabian Dargaud on 04/09/2026.
//

import SwiftUI

struct CinemaPosterCard: View {
    let movie: MediaItemEntity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack(alignment: .topLeading) {
                AsyncImage(url: movie.posterPath?.tmdbPosterURL()) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().aspectRatio(2/3, contentMode: .fill)
                    case .failure:
                        Rectangle().fill(.gray.opacity(0.3))
                            .overlay(Image(systemName: "film").foregroundStyle(.secondary))
                    default:
                        Rectangle().fill(.gray.opacity(0.3)).overlay(ProgressView())
                    }
                }
                .frame(width: 110, height: 165)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
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
                .foregroundStyle(.primary)
            
            if let date = movie.releaseDate {
                Text(date.formatted(.dateTime.day().month(.abbreviated)))
                    .font(.caption2)
                    .foregroundStyle(.gray)
            }
        }
        .frame(width: 110)
    }
}

#Preview {
    CinemaPosterCard(movie: MediaItemEntity(id: 1, title: "Film test", releaseDate: .now, posterPath: nil))
        .padding()
        .preferredColorScheme(.dark)
}
