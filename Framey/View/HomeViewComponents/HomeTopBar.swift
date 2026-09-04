//
//  HomeTopBar.swift
//  Framey
//
//  Created by Fabian Dargaud on 04/09/2026.
//

import SwiftUI

struct HomeTopBar: View {
    var body: some View {
        HStack {
            Image("Framey Logo")
                .resizable()
                .scaledToFit()
                .frame(height: 40)
            
            Spacer()
            
            HStack(spacing: 20) {
                Button { } label: {
                    Image(systemName: "magnifyingglass")
                }
                Button { } label: {
                    Image(systemName: "bell")
                }
                Button { } label: {
                    Image(systemName: "person.crop.circle")
                }
            }
            .font(.title3)
            .foregroundStyle(.white)
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack { HomeTopBar(); Spacer() }
    }
    .preferredColorScheme(.dark)
}
