//
//  WeekdaySelectionView.swift
//  RemindMe
//
//  Created by Ali Tamoor on 16/01/2024.
//

import SwiftUI


struct WeekdaySelectionView: View {
    @Binding var selectedWeekdays: Set<Int>
    @State private var numberOfShakes = 0.0
    @State private var currentSelectedWeekDays = 0
    @State private var start: Bool = false

    var body: some View {
        VStack {
            Text(selectionLabelText())
                .font(.headline)
                .fontWeight(.light)
                .padding(.top, 10)
                .foregroundColor(.white.opacity(0.8))

            HStack {
                ForEach(0..<7) { index in
                    Button(action: {
                        toggleWeekday(index)
                        if selectedWeekdays.count == currentSelectedWeekDays {
                            start = true
                            withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.2, blendDuration: 0.2)) {
                                start = false
                            }
                        }
                        
                    }) {
                        Text(weekdaySymbol(index))
                            .offset(x: (start && selectedWeekdays.contains(index)) ? 30 : 0)
                            .frame(width: 45, height: 45)
                            .foregroundColor(Color(.label))
                            .background(selectedWeekdays.contains(index) ? Color.gray : .secondaryBrand)
                            .clipShape(Circle())
                    }
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .background{
            Color.secondaryBrand
        }
    }

    func toggleWeekday(_ index: Int) {
        // At least one weekday should remain selected
        currentSelectedWeekDays = selectedWeekdays.count
        if selectedWeekdays.count > 1 || !selectedWeekdays.contains(index) {
            if selectedWeekdays.contains(index) {
                selectedWeekdays.remove(index)
            } else {
                selectedWeekdays.insert(index)
            }
            print(selectedWeekdays.count)
        }
    }

    func weekdaySymbol(_ index: Int) -> String {
        let calendar = Calendar.current
        let weekdaySymbols = calendar.shortWeekdaySymbols
        return weekdaySymbols[index]
    }

    func selectionLabelText() -> String {
        let selectedDays = selectedWeekdays.sorted()

        if selectedDays == Array(0..<7) {
            return "Everyday"
        } else if selectedDays == Array(1...5) {
            return "Weekdays"
        } else if selectedDays == [0, 6] {
            return "Weekend"
        } else {
            let selectedWeekdaySymbols = selectedDays.map { weekdaySymbol($0) }
            return selectedWeekdaySymbols.joined(separator: ", ")
        }
    }
}

#Preview {
    WeekdaySelectionView(selectedWeekdays: .constant(Set(0..<7)))
}
