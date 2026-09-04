//
//  PosterGridCard.swift
//  Framey
//
//  Created by Fabian Dargaud on 04/09/2026.
//

import SwiftUI

struct PosterGridCard: View {
    let title: String
    let posterPath: String?
    var subtitle: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Color.clear
                .aspectRatio(2/3, contentMode: .fit)
                .overlay {
                    AsyncImage(url: posterPath?.tmdbPosterURL()) { phase in
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
            
            Text(title)
                .font(.caption)
                .lineLimit(2, reservesSpace: true)
                .foregroundStyle(.white)
            
            if let subtitle {
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(.gray)
            }
        }
    }
}

#Preview {
    PosterGridCard(title: "Interstellar", posterPath: nil, subtitle: "Ajouté le 4 sept.")
        .padding()
        .background(Color.black)
        .preferredColorScheme(.dark)
}
