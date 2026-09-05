//
//  MediaPosterCard.swift
//  Framey
//
//  Created by Fabian Dargaud on 04/09/2026.
//

import SwiftUI

struct MediaPosterCard: View {
    let title: String
    let posterPath: String?
    var rating: Int? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            AsyncImage(url: posterPath?.tmdbPosterURL()) { phase in
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
            
            Text(title)
                .font(.caption)
                .lineLimit(2, reservesSpace: true)
                .foregroundStyle(.primary)
            
            if let rating {
                Label("\(rating)/5", systemImage: "star.fill")
                    .font(.caption2)
                    .foregroundStyle(.yellow)
            }
        }
        .frame(width: 110)
    }
}

#Preview {
    MediaPosterCard(title: "Interstellar", posterPath: nil, rating: 5)
        .padding()
        .preferredColorScheme(.dark)
}
