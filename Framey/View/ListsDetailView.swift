//
//  ListDetailsView.swift
//  Framey
//
//  Created by Fabian Dargaud on 04/09/2026.
//

import SwiftUI
import SwiftData

struct ListDetailView: View {
    let list: ListEntity
    @Environment(\.modelContext) private var modelContext
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        Group {
            if list.items.isEmpty {
                ContentUnavailableView(list.name,
                                       systemImage: "list.bullet.rectangle",
                                       description: Text("Cette liste est vide"))
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(list.items) { entry in
                            NavigationLink(value: entry.asMediaItem) {
                                PosterGridCard(title: entry.title, posterPath: entry.posterPath)
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button(role: .destructive) {
                                    modelContext.delete(entry)
                                } label: {
                                    Label("Retirer de la liste", systemImage: "trash")
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
        .navigationTitle(list.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ListDetailView(list: ListEntity(name: "Mes favoris"))
            .preferredColorScheme(.dark)
    }
    .modelContainer(for: [ListEntity.self, ListItemEntry.self], inMemory: true)
}

