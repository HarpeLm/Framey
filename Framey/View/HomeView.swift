//
//  HomeView.swift
//  Framey
//
//  Created by Fabian Dargaud on 04/09/2026.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.black
                .ignoresSafeArea()
            
            VStack {
                topBar
                Spacer()
            }
        }
    }
    
    // MARK: - Barre du haut
    
    private var topBar: some View {
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
    HomeView()
        .preferredColorScheme(.dark)
}
