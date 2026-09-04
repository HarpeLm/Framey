//
//  WatchlistView.swift
//  Framey
//
//  Created by Fabian Dargaud on 03/09/2026.
//

import SwiftUI
import SwiftData

struct WatchlistView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView("Watchlist",
                                   systemImage: "eye",
                                   description: Text("Bientôt : tes films à voir"))
                .navigationTitle("Watchlist")
        }
    }
}

#Preview {
    WatchlistView()
        .preferredColorScheme(.dark)
}
