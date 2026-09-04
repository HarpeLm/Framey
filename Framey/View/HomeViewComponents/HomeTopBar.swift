//
//  HomeTopBar.swift
//  Framey
//
//  Created by Fabian Dargaud on 04/09/2026.
//

import SwiftUI

struct HomeTopBar: View {
    var onSearch: () -> Void = { }
    
    var body: some View {
        HStack {
            Image("Framey Logo")
                .resizable()
                .scaledToFit()
                .frame(height: 40)
            
            Spacer()
            
            HStack(spacing: 20) {
                Button(action: onSearch) {
                    Image(systemName: "magnifyingglass")
                }
                Button { } label: {
                    Image(systemName: "bell")
                }
            }
            .font(.title3)
            .foregroundStyle(.white)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack { HomeTopBar(); Spacer() }
    }
    .preferredColorScheme(.dark)
}
