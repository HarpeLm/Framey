//
//  PickDirectorSheet.swift
//  Framey
//
//  Created by Fabian Dargaud on 05/09/2026.
//

import SwiftUI
import SwiftData

struct PickDirectorSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FavoriteDirectorEntry.position) private var favorites: [FavoriteDirectorEntry]
    @State private var query = ""
    @State private var results: [TMDBPerson] = []
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(results, id: \.id) { person in
                        row(person)
                    }
                }
                .padding(20)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Choisir un réalisateur")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .top) { searchBar }
            .task(id: query) { await runSearch() }
        }
        .presentationDetents([.medium, .large])
    }
    
    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.gray)
            TextField("Rechercher un réalisateur…", text: $query)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .foregroundStyle(.white)
            if !query.isEmpty {
                Button { query = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                }
                .foregroundStyle(.gray)
            }
        }
        .padding(10)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
        .background(.black)
    }
    
    private func row(_ person: TMDBPerson) -> some View {
        let isFavorite = favorites.contains { $0.personId == person.id }
        let isFull = !isFavorite && favorites.count >= 3
        
        return HStack(spacing: 12) {
            AsyncImage(url: person.profile_path?.tmdbPosterURL()) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFill()
                } else {
                    Circle().fill(.gray.opacity(0.3))
                        .overlay(Image(systemName: "person.fill").foregroundStyle(.gray))
                }
            }
            .frame(width: 48, height: 48)
            .clipShape(Circle())
            
            Text(person.name)
                .font(.subheadline)
                .foregroundStyle(.white)
                .lineLimit(2)
            
            Spacer()
            
            Button {
                toggle(person)
            } label: {
                Image(systemName: isFavorite ? "checkmark.circle.fill" : "plus.circle")
                    .font(.title2)
                    .foregroundStyle(isFavorite ? .green : .purple)
            }
            .disabled(isFull)
            .opacity(isFull ? 0.3 : 1)
        }
        .padding(10)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
    }
    
    private func toggle(_ person: TMDBPerson) {
        if let existing = favorites.first(where: { $0.personId == person.id }) {
            modelContext.delete(existing)
        } else {
            guard favorites.count < 3 else { return }
            let entry = FavoriteDirectorEntry(personId: person.id,
                                              name: person.name,
                                              profilePath: person.profile_path,
                                              position: nextFreePosition)
            modelContext.insert(entry)
        }
    }
    
    private var nextFreePosition: Int {
        (0..<3).first { pos in !favorites.contains { $0.position == pos } } ?? 0
    }
    
    private func runSearch() async {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard trimmed.count >= 2 else {
            results = []
            return
        }
        
        try? await Task.sleep(for: .milliseconds(400))
        guard !Task.isCancelled else { return }
        
        results = (try? await MovieService.searchPeople(query: trimmed)) ?? []
    }
}

#Preview {
    PickDirectorSheet()
        .preferredColorScheme(.dark)
        .modelContainer(for: [FavoriteDirectorEntry.self], inMemory: true)
}
