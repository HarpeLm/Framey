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
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \ListEntity.dateCreated) private var lists: [ListEntity]
    
    @State private var showingNewList = false
    @State private var newListName = ""
    
    var body: some View {
        NavigationStack {
            Group {
                if lists.isEmpty {
                    ContentUnavailableView("Aucune liste",
                                           systemImage: "list.bullet.rectangle",
                                           description: Text("Crée ta première liste avec le bouton +"))
                } else {
                    listRows
                }
            }
            .navigationTitle("Ajouter à une liste")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Fermer") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingNewList = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert("Nouvelle liste", isPresented: $showingNewList) {
                TextField("Nom de la liste", text: $newListName)
                Button("Créer") { createList() }
                Button("Annuler", role: .cancel) { newListName = "" }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    private var listRows: some View {
        List(lists) { list in
            Button {
                toggle(list)
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(list.name).foregroundStyle(.primary)
                        Text("\(list.items.count) titres")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if contains(list) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }
    
    private func contains(_ list: ListEntity) -> Bool {
        list.items.contains { $0.mediaId == item.id && $0.mediaTypeRaw == item.mediaTypeRaw }
    }
    
    private func toggle(_ list: ListEntity) {
        if let existing = list.items.first(where: { $0.mediaId == item.id && $0.mediaTypeRaw == item.mediaTypeRaw }) {
            modelContext.delete(existing)
        } else {
            let entry = ListItemEntry(mediaId: item.id,
                                      mediaType: item.mediaType,
                                      title: item.title,
                                      posterPath: item.posterPath)
            entry.list = list
            modelContext.insert(entry)
        }
    }
    
    private func createList() {
        let name = newListName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        modelContext.insert(ListEntity(name: name))
        newListName = ""
    }
}
