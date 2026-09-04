//
//  MediaRow.swift
//  Framey
//
//  Created by Fabian Dargaud on 04/09/2026.
//

import SwiftUI

struct MediaRow<Item: Identifiable>: View {
    let title: String
    let items: [Item]
    let card: (Item) -> AnyView
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                Button("Voir tout") { }
                    .font(.caption)
                    .foregroundStyle(.purple)
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(items) { item in
                        card(item)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}
