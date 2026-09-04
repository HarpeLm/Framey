//
//  ListView.swift
//  Framey
//
//  Created by Fabian Dargaud on 04/09/2026.
//

import SwiftUI
import SwiftData

struct ListsView: View {
    @Query(sort: \ListEntity.dateCreated) private var lists: [ListEntity]
    
    var body: some View {
        Group {
            if lists.isEmpty {
                ContentUnavailableView("Tes listes",
                                       systemImage: "list.bullet.rectangle",
                                       description: Text("Crée des listes depuis la fiche d'un film"))
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(lists) { list in
                            NavigationLink(value: HomeRoute.list(list)) {
                                listCard(list)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(20)
                }
            }
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("Tes listes")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func listCard(_ list: ListEntity) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12)
                .fill(.purple.opacity(0.2))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "list.bullet.rectangle")
                        .font(.title2)
                        .foregroundStyle(.purple)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(list.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Text("\(list.items.count) titres")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.gray)
        }
        .padding(12)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    NavigationStack {
        ListsView()
            .preferredColorScheme(.dark)
    }
    .modelContainer(for: [ListEntity.self, ListItemEntry.self], inMemory: true)
}
