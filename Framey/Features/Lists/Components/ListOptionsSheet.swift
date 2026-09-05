//
//  ListoptionsSheet.swift
//  Framey
//
//  Created by Fabian Dargaud on 04/09/2026.
//

import SwiftUI
import SwiftData

struct ListOptionsSheet: View {
    let list: ListEntity
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showingEdit = false
    @State private var showingDelete = false
    
    var body: some View {
        VStack(spacing: 12) {
            Capsule()
                .fill(.gray.opacity(0.4))
                .frame(width: 36, height: 4)
                .padding(.top, 12)
            
            // Header : identité de la liste
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.purple.opacity(0.2))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "list.bullet.rectangle")
                            .foregroundStyle(.purple)
                    )
                VStack(alignment: .leading, spacing: 2) {
                    Text(list.name)
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text("\(list.items.count) films · \(list.isPublic ? "Publique" : "Privée")")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            
            // Groupe 1 : actions neutres
            VStack(spacing: 0) {
                Button {
                    showingEdit = true
                } label: {
                    actionLabel(icon: "pencil", tint: .purple, title: "Modifier la liste")
                }
                
                Rectangle()
                    .fill(.white.opacity(0.08))
                    .frame(height: 1)
                    .padding(.leading, 58)
                
                ShareLink(item: "Ma liste « \(list.name) » sur Framey 🎬") {
                    actionLabel(icon: "square.and.arrow.up", tint: .blue, title: "Partager la liste")
                }
            }
            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 20)
            
            // Groupe 2 : action destructive
            Button {
                showingDelete = true
            } label: {
                actionLabel(icon: "trash", tint: .red, title: "Supprimer la liste")
            }
            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 20)
            
            // Groupe 3 : annuler
            Button {
                dismiss()
            } label: {
                Text("Annuler")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
        .sheet(isPresented: $showingEdit) {
            EditListSheet(list: list)
                .preferredColorScheme(.dark)
        }
        .confirmationDialog("Supprimer « \(list.name) » ?",
                            isPresented: $showingDelete,
                            titleVisibility: .visible) {
            Button("Supprimer", role: .destructive) {
                modelContext.delete(list)
                dismiss()
            }
        } message: {
            Text("Ses \(list.items.count) films seront retirés de la liste.")
        }
    }
    
    private func actionLabel(icon: String, tint: Color, title: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(tint, in: Circle())
            Text(title)
                .font(.body)
                .foregroundStyle(.white)
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
}

#Preview {
    ListOptionsSheet(list: ListEntity(name: "À voir 🎬"))
        .preferredColorScheme(.dark)
}
