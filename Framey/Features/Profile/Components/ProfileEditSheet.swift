//
//  ProfileEditSheet.swift
//  Framey
//
//  Created by Fabian Dargaud on 04/09/2026.
//

import SwiftUI
import PhotosUI

struct ProfileEditSheet: View {
    @Binding var username: String
    @Binding var handle: String
    @Environment(\.dismiss) private var dismiss
    
    @State private var draftUsername = ""
    @State private var draftHandle = ""
    @State private var draftPhoto: Data?
    @State private var pickerItem: PhotosPickerItem?
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        PhotosPicker(selection: $pickerItem, matching: .images) {
                            avatarPreview
                                .overlay(alignment: .bottomTrailing) {
                                    Image(systemName: "camera.circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(.purple)
                                }
                        }
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }
                
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
                        if let draftPhoto {
                            ProfilePhotoStore.save(draftPhoto)
                        }
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                draftUsername = username
                draftHandle = handle
                draftPhoto = ProfilePhotoStore.load()
            }
            .onChange(of: pickerItem) { _, newItem in
                guard let newItem else { return }
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self) {
                        draftPhoto = data
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    @ViewBuilder
    private var avatarPreview: some View {
        if let draftPhoto, let uiImage = UIImage(data: draftPhoto) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(Circle())
        } else {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.purple)
        }
    }
}

#Preview {
    ProfileEditSheet(username: .constant("Cinéphile"), handle: .constant("@framey"))
        .preferredColorScheme(.dark)
}
