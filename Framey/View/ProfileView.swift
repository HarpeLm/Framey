//
//  ProfileView.swift
//  Framey
//
//  Created by Fabian Dargaud on 03/09/2026.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView("Profil",
                                   systemImage: "person",
                                   description: Text("Bientôt : ton profil et tes stats"))
                .navigationTitle("Profil")
        }
    }
}

#Preview {
    ProfileView()
        .preferredColorScheme(.dark)
}
