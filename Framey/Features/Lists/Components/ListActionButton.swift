//
//  ListActionButton.swift
//  Framey
//
//  Created by Fabian Dargaud on 04/09/2026.
//

import SwiftUI

struct ListActionButton: View {
    let title: String
    let icon: String
    var tint: Color = .purple
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
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
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack {
        ListActionButton(title: "J'aime", icon: "heart", tint: .pink) { }
        ListActionButton(title: "Modifier", icon: "pencil") { }
    }
    .padding()
    .background(Color.black)
    .preferredColorScheme(.dark)
}
