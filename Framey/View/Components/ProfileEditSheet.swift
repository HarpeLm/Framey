//
//  ProfileEditSheet.swift
//  Framey
//
//  Created by Fabian Dargaud on 04/09/2026.
//

import SwiftUI

struct ProfileEditSheet: View {
    @Binding var username: String
    @Binding var handle: String
    @Environment(\.dismiss) private var dismiss
    
    @State private var draftUsername = ""
    @State private var draftHandle = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Profil") {
                    TextField("Nom d'utilisateur", text: $draftUsername)
                    TextField("Pseudo (@…)", text: $draftHandle)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
            }
            .navigationTitle("Modifier le profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Enregistrer") {
                        username = draftUsername
                        handle = draftHandle
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                draftUsername = username
                draftHandle = handle
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    ProfileEditSheet(username: .constant("Cinéphile"), handle: .constant("@framey"))
        .preferredColorScheme(.dark)
}
