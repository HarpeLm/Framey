//
//  AddMovieToListSheet.swift
//  Framey
//
//  Created by Fabian Dargaud on 04/09/2026.
//
import SwiftUI
import SwiftData

struct AddMovieToListSheet: View {
    let list: ListEntity
    @Environment(\.modelContext) private var modelContext
    
    @State private var query = ""
    @State private var results: [MediaItemEntity] = []
    @State private var isSearching = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(results, id: \.id) { movie in
                        addRow(movie)
                    }
                }
                .padding(20)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Ajouter à « \(list.name) »")
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
            TextField("Rechercher un film…", text: $query)
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
    
    private func addRow(_ movie: MediaItemEntity) -> some View {
        let alreadyIn = list.items.contains { $0.mediaId == movie.id }
        
        return HStack(spacing: 12) {
            AsyncImage(url: movie.posterPath?.tmdbPosterURL()) { phase in
                if let image = phase.image {
                    image.resizable().aspectRatio(2/3, contentMode: .fill)
                } else {
                    Rectangle().fill(.gray.opacity(0.3))
                }
            }
            .frame(width: 40, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            
            Text(movie.title)
                .font(.subheadline)
                .foregroundStyle(.white)
                .lineLimit(2)
            
            Spacer()
            
            Button {
                let entry = ListItemEntry(mediaId: movie.id,
                                          mediaType: movie.mediaType,
                                          title: movie.title,
                                          posterPath: movie.posterPath)
                modelContext.insert(entry)
                list.items.append(entry)
            } label: {
                Image(systemName: alreadyIn ? "checkmark.circle.fill" : "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(alreadyIn ? .green : .purple)
            }
            .disabled(alreadyIn)
        }
        .padding(10)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
    }
    
    private func runSearch() async {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard trimmed.count >= 2 else {
            results = []
            return
        }
        
        isSearching = true
        defer { isSearching = false }
        
        try? await Task.sleep(for: .milliseconds(400))
        guard !Task.isCancelled else { return }
        
        results = (try? await MovieService.searchMovies(query: trimmed)) ?? []
    }
}
