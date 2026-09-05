//
//  WeekStrip.swift
//  Framey
//
//  Created by Fabian Dargaud on 04/09/2026.
//

import SwiftUI

struct WeekStrip: View {
    let days: [Date]
    @Binding var selectedDay: Date
    let hasReleases: (Date) -> Bool
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(days, id: \.self) { day in
                    dayCell(day)
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func dayCell(_ day: Date) -> some View {
        let isSelected = Calendar.current.isDate(day, inSameDayAs: selectedDay)
        
        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                selectedDay = day
            }
        } label: {
            VStack(spacing: 4) {
                Text(weekdayLabel(day))
                    .font(.caption2.weight(.semibold))
                Text(day.formatted(.dateTime.day()))
                    .font(.title3.weight(.bold))
                Circle()
                    .fill(hasReleases(day) ? Color.purple : .clear)
                    .frame(width: 5, height: 5)
            }
            .foregroundStyle(isSelected ? Color.purple : .white)
            .frame(width: 52, height: 64)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white.opacity(isSelected ? 0.12 : 0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.purple : .clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func weekdayLabel(_ day: Date) -> String {
        let calendar = Calendar.current
        let symbol = calendar.shortWeekdaySymbols[calendar.component(.weekday, from: day) - 1]
        return symbol.replacingOccurrences(of: ".", with: "").uppercased()
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        WeekStrip(days: (0..<7).map { Calendar.current.date(byAdding: .day, value: $0, to: .now)! },
                  selectedDay: .constant(.now),
                  hasReleases: { _ in true })
    }
    .preferredColorScheme(.dark)
}
