//
//  ListCollage.swift
//  Framey
//
//  Created by Fabian Dargaud on 04/09/2026.
//

import SwiftUI

struct ListCollage: View {
    let posterPaths: [String?]
    let count: Int
    
    var body: some View {
        VStack(spacing: 2) {
            HStack(spacing: 2) { cell(0); cell(1) }
            HStack(spacing: 2) { cell(2); cell(3) }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(alignment: .bottomTrailing) {
            Text("\(count) films")
                .font(.caption2.weight(.semibold))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.black.opacity(0.7), in: Capsule())
                .foregroundStyle(.white)
                .padding(6)
        }
    }
    
    private func cell(_ index: Int) -> some View {
        Group {
            if index < posterPaths.count, let path = posterPaths[index] {
                AsyncImage(url: path.tmdbPosterURL()) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        Rectangle().fill(.gray.opacity(0.3))
                    }
                }
            } else {
                Rectangle().fill(.gray.opacity(0.2))
                    .overlay(Image(systemName: "film").foregroundStyle(.gray))
            }
        }
        .frame(width: 80, height: 110)
        .clipped()
    }
}

#Preview {
    ListCollage(posterPaths: [nil, nil, nil, nil], count: 12)
        .padding()
        .background(Color.black)
        .preferredColorScheme(.dark)
}
