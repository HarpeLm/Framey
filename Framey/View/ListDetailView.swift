//
//  ListDetailsView.swift
//  Framey
//
//  Created by Fabian Dargaud on 04/09/2026.
//

import SwiftUI
import SwiftData

struct ListDetailView: View {
    enum ListSort: String, CaseIterable, Identifiable {
        case manuel = "Manuel"
        case note = "Note"
        case titre = "Titre"
        case recent = "Récent"
        var id: String { rawValue }
    }
    
    let list: ListEntity
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var watched: [WatchedEntry]
    @AppStorage("username") private var username = "Cinéphile"
    @AppStorage("handle") private var handle = "@framey"
    @State private var profilePhoto: Data?
    @State private var showingEdit = false
    @State private var showingAdd = false
    @State private var showingDelete = false
    @State private var sort: ListSort = .manuel
    
    private var ratingByMediaId: [Int: Int] {
        watched.reduce(into: [:]) { dict, entry in
            if let rating = entry.rating { dict[entry.mediaId] = rating }
        }
    }
    
    private var sortedItems: [ListItemEntry] {
        switch sort {
        case .manuel:
            return list.items
        case .note:
            return list.items.sorted { (ratingByMediaId[$0.mediaId] ?? -1) > (ratingByMediaId[$1.mediaId] ?? -1) }
        case .titre:
            return list.items.sorted { $0.title.localizedStandardCompare($1.title) == .orderedAscending }
        case .recent:
            return list.items.sorted { $0.dateAdded > $1.dateAdded }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                rowsSection
            }
            .padding(.top, 12)
            .padding(.bottom, 40)
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle(list.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: MediaItemEntity.self) { item in
            MovieDetailView(item: item)
        }
        .sheet(isPresented: $showingEdit) {
            EditListSheet(list: list)
                .preferredColorScheme(.dark)
        }
        .sheet(isPresented: $showingAdd) {
            AddMovieToListSheet(list: list)
                .preferredColorScheme(.dark)
        }
        .confirmationDialog("Supprimer cette liste ?",
                            isPresented: $showingDelete,
                            titleVisibility: .visible) {
            Button("Supprimer la liste", role: .destructive) {
                modelContext.delete(list)
                dismiss()
            }
        } message: {
            Text("« \(list.name) » et ses \(list.items.count) films seront définitivement supprimés.")
        }
        .onAppear { profilePhoto = ProfilePhotoStore.load() }
    }
    
    // MARK: - Header
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                ListCollage(posterPaths: Array(list.items.prefix(4).map(\.posterPath)),
                            count: list.items.count)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(list.name)
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                    
                    HStack(spacing: 8) {
                        avatar
                        VStack(alignment: .leading, spacing: 2) {
                            Text(username)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.white)
                            Text(handle)
                                .font(.caption2)
                                .foregroundStyle(.gray)
                        }
                    }
                    
                    Label(list.isPublic ? "Publique" : "Privée",
                          systemImage: list.isPublic ? "globe" : "lock")
                        .font(.caption2)
                        .foregroundStyle(.gray)
                }
            }
            .padding(.horizontal, 20)
            
            HStack(spacing: 8) {
                ListActionButton(title: "J'aime",
                                 icon: list.isLikedByMe ? "heart.fill" : "heart",
                                 tint: list.isLikedByMe ? .pink : .purple) {
                    list.isLikedByMe.toggle()
                }
                
                ListActionButton(title: "Modifier", icon: "pencil") {
                    showingEdit = true
                }
                
                ShareLink(item: "Ma liste « \(list.name) » sur Framey 🎬") {
                    actionLabel("Partager", icon: "square.and.arrow.up")
                }
                .buttonStyle(.plain)
                
                ListActionButton(title: "Ajouter", icon: "plus") {
                    showingAdd = true
                }
                
                Menu {
                    Picker("Trier par", selection: $sort) {
                        ForEach(ListSort.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                } label: {
                    actionLabel("Trier", icon: "arrow.up.arrow.down")
                }
                
                ListActionButton(title: "Supprimer", icon: "trash", tint: .red) {
                    showingDelete = true
                }
            }
            .padding(.horizontal, 20)
            
            Button {
                showingEdit = true
            } label: {
                Text(list.listDescription.isEmpty ? "Ajouter une description…" : list.listDescription)
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
        }
    }
    
    private func actionLabel(_ title: String, icon: String, tint: Color = .purple) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
            Text(title)
                .font(.caption2)
        }
        .foregroundStyle(tint)
        .frame(maxWidth: .infinity, minHeight: 56)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
    }
    
    @ViewBuilder
    private var avatar: some View {
        if let profilePhoto, let uiImage = UIImage(data: profilePhoto) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 28, height: 28)
                .clipShape(Circle())
        } else {
            Image(systemName: "person.crop.circle.fill")
                .font(.title3)
                .foregroundStyle(.purple)
        }
    }
    
    // MARK: - Lignes numérotées
    
    private var rowsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("\(list.items.count) FILMS")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.gray)
                Spacer()
                Text("Trier par")
                    .font(.caption)
                    .foregroundStyle(.gray)
                Text(sort.rawValue)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 20)
            
            if sortedItems.isEmpty {
                ContentUnavailableView("Liste vide",
                                       systemImage: "list.bullet.rectangle",
                                       description: Text("Ajoute des films avec le bouton Ajouter"))
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(sortedItems.enumerated()), id: \.element.persistentModelID) { index, entry in
                        row(index: index, entry: entry)
                        if index < sortedItems.count - 1 {
                            Divider().overlay(.white.opacity(0.08))
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private func row(index: Int, entry: ListItemEntry) -> some View {
        HStack(spacing: 12) {
            Text("\(index + 1)")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 36, height: 44)
                .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))
            
            NavigationLink(value: entry.asMediaItem) {
                HStack(spacing: 12) {
                    AsyncImage(url: entry.posterPath?.tmdbPosterURL()) { phase in
                        if let image = phase.image {
                            image.resizable().aspectRatio(2/3, contentMode: .fill)
                        } else {
                            Rectangle().fill(.gray.opacity(0.3))
                        }
                    }
                    .frame(width: 50, height: 75)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                            .lineLimit(2)
                        if let rating = ratingByMediaId[entry.mediaId] {
                            stars(rating)
                        }
                    }
                }
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            Menu {
                Button(role: .destructive) {
                    modelContext.delete(entry)
                } label: {
                    Label("Retirer de la liste", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundStyle(.gray)
            }
            
            Image(systemName: "line.3.horizontal")
                .foregroundStyle(.gray)
        }
        .padding(.vertical, 10)
    }
    
    private func stars(_ rating: Int) -> some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .font(.caption2)
                    .foregroundStyle(star <= rating ? .yellow : .gray)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ListDetailView(list: ListEntity(name: "À voir 🎬"))
            .preferredColorScheme(.dark)
    }
    .modelContainer(for: [MediaItemEntity.self, WatchedEntry.self, ListEntity.self, ListItemEntry.self], inMemory: true)
}
