//
//  ProfileHeader.swift
//  Framey
//
//  Created by Fabian Dargaud on 04/09/2026.
//

import SwiftUI

struct ProfileHeader: View {
    let username: String
    let handle: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.purple)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(username)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                Text(handle)
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }
}

#Preview {
    ProfileHeader(username: "Cinéphile", handle: "@framey")
        .background(Color.black)
        .preferredColorScheme(.dark)
}
