//
//  SeriesFeedView.swift
//  Framey
//
//  Created by Fabian Dargaud on 05/09/2026.
//

import SwiftUI

struct SeriesFeedView: View {
    @State private var viewModel = SeriesViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
            } else {
                MediaRow(title: "Séries populaires", items: viewModel.popular) { item in
                    AnyView(
                        NavigationLink(value: item) {
                            MediaPosterCard(title: item.title, posterPath: item.posterPath)
                        }
                        .buttonStyle(.plain)
                    )
                }
                
                MediaRow(title: "En ce moment à la TV", items: viewModel.onTheAir) { item in
                    AnyView(
                        NavigationLink(value: item) {
                            MediaPosterCard(title: item.title, posterPath: item.posterPath)
                        }
                        .buttonStyle(.plain)
                    )
                }
                
                MediaRow(title: "Les mieux notées", items: viewModel.topRated) { item in
                    AnyView(
                        NavigationLink(value: item) {
                            MediaPosterCard(title: item.title, posterPath: item.posterPath)
                        }
                        .buttonStyle(.plain)
                    )
                }
            }
        }
        .task { await viewModel.load() }
    }
}

#Preview {
    NavigationStack {
        SeriesFeedView()
            .preferredColorScheme(.dark)
    }
}
