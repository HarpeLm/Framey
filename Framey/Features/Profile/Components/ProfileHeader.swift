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
    var photoData: Data? = nil
    var followers: Int = 0
    var following: Int = 0
    
    var body: some View {
        HStack(spacing: 16) {
            avatar
            
            VStack(alignment: .leading, spacing: 4) {
                Text(username)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                Text(handle)
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                Text("\(followers) abonnés · \(following) suivis")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }
    
    @ViewBuilder
    private var avatar: some View {
        if let photoData, let uiImage = UIImage(data: photoData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 64, height: 64)
                .clipShape(Circle())
        } else {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.purple)
        }
    }
}

#Preview {
    ProfileHeader(username: "Cinéphile", handle: "@framey", followers: 12, following: 34)
        .background(Color.black)
        .preferredColorScheme(.dark)
}
