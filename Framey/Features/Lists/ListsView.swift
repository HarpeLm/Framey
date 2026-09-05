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
    @Environment(\.modelContext) private var modelContext
    @State private var showingNewList = false
    @State private var newListName = ""
    @State private var selectedList: ListEntity?
    
    var body: some View {
        Group {
            if lists.isEmpty {
                ContentUnavailableView("Tes listes",
                                       systemImage: "list.bullet.rectangle",
                                       description: Text("Crée des listes depuis la fiche d'un film"))
            } else {
                List {
                    ForEach(lists) { list in
                        Button {
                            selectedList = list
                        } label: {
                            listCard(list)
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            modelContext.delete(lists[index])
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("Tes listes")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedList) { list in
            ListDetailView(list: list)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingNewList = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .alert("Nouvelle liste", isPresented: $showingNewList) {
            TextField("Nom de la liste", text: $newListName)
            Button("Créer") {
                let name = newListName.trimmingCharacters(in: .whitespaces)
                guard !name.isEmpty else { return }
                modelContext.insert(ListEntity(name: name))
                newListName = ""
            }
            Button("Annuler", role: .cancel) { }
        }
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
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        ListsView()
            .preferredColorScheme(.dark)
    }
    .modelContainer(for: [ListEntity.self, ListItemEntry.self], inMemory: true)
}
