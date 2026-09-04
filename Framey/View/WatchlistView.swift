//
//  WatchlistView.swift
//  Framey
//
//  Created by Fabian Dargaud on 03/09/2026.
//

import SwiftUI
import SwiftData

struct WatchlistView: View {
    @Query(sort: \WatchlistEntry.dateAdded, order: .reverse) private var watchlist: [WatchlistEntry]
    @Environment(\.modelContext) private var modelContext
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        NavigationStack {
            Group {
                if watchlist.isEmpty {
                    ContentUnavailableView("Watchlist",
                                           systemImage: "eye",
                                           description: Text("Ajoute des films à voir depuis leurs fiches"))
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(watchlist) { entry in
                                NavigationLink(value: entry.asMediaItem) {
                                    PosterGridCard(
                                        title: entry.title,
                                        posterPath: entry.posterPath,
                                        subtitle: entry.dateAdded.formatted(date: .abbreviated, time: .omitted)
                                    )
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        modelContext.delete(entry)
                                    } label: {
                                        Label("Retirer de la watchlist", systemImage: "eye.slash")
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    }
                }
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Watchlist")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: MediaItemEntity.self) { item in
                MovieDetailView(item: item)
            }
        }
    }
}

#Preview {
    WatchlistView()
        .preferredColorScheme(.dark)
        .modelContainer(for: [MediaItemEntity.self, WatchlistEntry.self], inMemory: true)
}
