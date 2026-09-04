//
//  ActivityRow.swift
//  Framey
//
//  Created by Fabian Dargaud on 04/09/2026.
//

import SwiftUI

struct ActivityRow: View {
    let item: ActivityItem
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: item.posterPath?.tmdbPosterURL()) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(2/3, contentMode: .fill)
                case .failure:
                    Rectangle().fill(.gray.opacity(0.3))
                default:
                    Rectangle().fill(.gray.opacity(0.3)).overlay(ProgressView())
                }
            }
            .frame(width: 45, height: 68)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.actionText)
                    .font(.caption)
                    .foregroundStyle(.gray)
                Text(item.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                if let rating = item.rating {
                    stars(rating)
                }
            }
            
            Spacer()
            
            Text(item.date.formatted(.relative(presentation: .named)))
                .font(.caption2)
                .foregroundStyle(.gray)
        }
        .padding(10)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
    }
    
    private func stars(_ rating: Int) -> some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .font(.caption2)
                    .foregroundStyle(star <= rating ? .yellow : .gray)
            }
        }
    }
}

#Preview {
    ActivityRow(item: ActivityItem(id: "1",
                                   actionText: "Tu as noté",
                                   title: "La La Land",
                                   posterPath: nil,
                                   rating: 4,
                                   date: .now,
                                   mediaItem: MediaItemEntity(id: 313369, title: "La La Land")))
        .padding()
        .background(Color.black)
        .preferredColorScheme(.dark)
}
