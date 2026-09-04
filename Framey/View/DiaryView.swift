//
//  DiaryView.swift
//  Framey
//
//  Created by Fabian Dargaud on 03/09/2026.
//

import SwiftUI
import SwiftData

struct DiaryView: View {
    @Query(sort: \WatchedEntry.dateWatched, order: .reverse) private var watched: [WatchedEntry]
    
    var body: some View {
        Group {
            if watched.isEmpty {
                ContentUnavailableView("Diary",
                                       systemImage: "book",
                                       description: Text("Marque des films comme vus pour remplir ton journal"))
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(watched) { entry in
                            NavigationLink(value: entry.asMediaItem) {
                                diaryRow(entry)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(20)
                }
            }
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("Diary")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func diaryRow(_ entry: WatchedEntry) -> some View {
        HStack(spacing: 12) {
            AsyncImage(url: entry.posterPath?.tmdbPosterURL()) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(2/3, contentMode: .fill)
                case .failure:
                    Rectangle().fill(.gray.opacity(0.3))
                default:
                    Rectangle().fill(.gray.opacity(0.3)).overlay(ProgressView())
                }
            }
            .frame(width: 60, height: 90)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                Text(entry.dateWatched.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.gray)
                if let rating = entry.rating {
                    Label("\(rating)/5", systemImage: "star.fill")
                        .font(.caption2)
                        .foregroundStyle(.yellow)
                }
            }
            Spacer()
        }
        .padding(10)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    NavigationStack {
        DiaryView()
            .preferredColorScheme(.dark)
    }
    .modelContainer(for: [MediaItemEntity.self, WatchedEntry.self], inMemory: true)
}
