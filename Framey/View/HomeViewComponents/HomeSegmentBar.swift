//
//  HomeSegmentBar.swift
//  Framey
//
//  Created by Fabian Dargaud on 04/09/2026.
//

import SwiftUI

struct HomeSegmentBar: View {
    @Binding var selectedTab: HomeTab
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 24) {
                ForEach(HomeTab.allCases) { tab in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = tab
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Text(tab.title)
                                .font(.subheadline.weight(selectedTab == tab ? .semibold : .regular))
                                .foregroundStyle(selectedTab == tab ? .white : .gray)
                            
                            Rectangle()
                                .fill(selectedTab == tab ? Color.purple : .clear)
                                .frame(height: 2)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack { HomeSegmentBar(selectedTab: .constant(.accueil)); Spacer() }
    }
    .preferredColorScheme(.dark)
}
