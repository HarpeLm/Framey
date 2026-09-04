//
//  AddToListSheet.swift
//  Framey
//
//  Created by Fabian Dargaud on 03/09/2026.
//

import SwiftUI
import SwiftData

struct AddToListSheet: View {
    let item: MediaItemEntity
    @Query(sort: \ListEntity.dateCreated) private var lists: [ListEntity]
    @Environment(\.modelContext) private var modelContext
    @State private var showingNewList = false
    @State private var newListName = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section("Ajouter à une liste") {
                    ForEach(lists) { list in
                        let isInList = list.items.contains { $0.mediaId == item.id }
                        
                        Button {
                            toggle(list)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "list.bullet.rectangle")
                                    .foregroundStyle(.purple)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(list.name)
                                        .foregroundStyle(.white)
                                    Text("\(list.items.count) titres")
                                        .font(.caption2)
                                        .foregroundStyle(.gray)
                                }
                                
                                Spacer()
                                
                                Image(systemName: isInList ? "checkmark.circle.fill" : "plus.circle")
                                    .font(.title3)
                                    .foregroundStyle(isInList ? .green : .gray)
                            }
                        }
                        .listRowBackground(Color.white.opacity(0.04))
                    }
                }
                
                Button {
                    showingNewList = true
                } label: {
                    Label("Nouvelle liste", systemImage: "plus")
                }
                .listRowBackground(Color.white.opacity(0.04))
            }
            .scrollContentBackground(.hidden)
            .background(Color.black)
            .navigationTitle("Listes")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Nouvelle liste", isPresented: $showingNewList) {
                TextField("Nom de la liste", text: $newListName)
                Button("Créer et ajouter") {
                    let name = newListName.trimmingCharacters(in: .whitespaces)
                    guard !name.isEmpty else { return }
                    let newList = ListEntity(name: name)
                    modelContext.insert(newList)
                    add(to: newList)
                    newListName = ""
                }
                Button("Annuler", role: .cancel) { }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    // MARK: - Ajout / retrait
    
    private func toggle(_ list: ListEntity) {
        if let existing = list.items.first(where: { $0.mediaId == item.id }) {
            modelContext.delete(existing)
        } else {
            add(to: list)
        }
    }
    
    private func add(to list: ListEntity) {
        let entry = ListItemEntry(mediaId: item.id,
                                  mediaType: item.mediaType,
                                  title: item.title,
                                  posterPath: item.posterPath,
                                  position: (list.items.map(\.position).max() ?? -1) + 1)
        modelContext.insert(entry)
        list.items.append(entry)
    }
}

#Preview {
    AddToListSheet(item: MediaItemEntity(id: 157336, title: "Interstellar"))
        .preferredColorScheme(.dark)
        .modelContainer(for: [ListEntity.self, ListItemEntry.self], inMemory: true)
}
