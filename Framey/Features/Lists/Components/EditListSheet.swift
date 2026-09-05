//
//  EditListSheet.swift
//  Framey
//
//  Created by Fabian Dargaud on 04/09/2026.
//

import SwiftUI

struct EditListSheet: View {
    let list: ListEntity
    @Environment(\.dismiss) private var dismiss
    
    @State private var draftName = ""
    @State private var draftDescription = ""
    @State private var draftIsPublic = true
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Informations") {
                    TextField("Nom de la liste", text: $draftName)
                    TextField("Description", text: $draftDescription, axis: .vertical)
                        .lineLimit(3...6)
                }
                Section {
                    Toggle("Liste publique", isOn: $draftIsPublic)
                } footer: {
                    Text("Une liste privée ne sera visible que par toi (à l'arrivée du compte).")
                }
            }
            .navigationTitle("Modifier la liste")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Enregistrer") {
                        list.name = draftName
                        list.listDescription = draftDescription
                        list.isPublic = draftIsPublic
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(draftName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                draftName = list.name
                draftDescription = list.listDescription
                draftIsPublic = list.isPublic
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    EditListSheet(list: ListEntity(name: "À voir 🎬"))
}
