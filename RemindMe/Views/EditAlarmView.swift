//
//  EditAlarmView.swift
//  RemindMe
//
//  Created by Ali Tamoor on 17/01/2024.
//

import SwiftUI

struct EditAlarmView: View {
    
    @State var selectedWeekdays: Set<Int> = Set(0...6)
    @State var selectedTime: Date = .now
    @State var selectedRingTone: Sounds = .autumnWind
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var reminderId = ""
    
    init(selectedWeekdays: Set<Int>, selectedTime: Date, selectedRingTone: Sounds, id: String) {
        _selectedWeekdays = State(initialValue: selectedWeekdays)
        _selectedTime = State(initialValue: selectedTime)
        _selectedRingTone = State(initialValue: selectedRingTone)
        reminderId = id
    }
    
    
    var body: some View {
        
        VStack {
            
            Text("Scheduled Time: \(formattedTime())")
                .foregroundStyle(Color(.label))
            
            DatePicker("Select a time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .padding()
            
            WeekdaySelectionView(selectedWeekdays: $selectedWeekdays)
            
            CustomNavigationPicker(strengths: Sounds.allCases, selectedStrength: $selectedRingTone)
            
            Button(action: {
                LocalNotificationManager.pauseOrDeleteNotifications(reminderId: reminderId)
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Text("Delete Reminder")
                    .font(.headline)
            })
            .buttonStyle(.bordered)
            .tint(.pink)
            
            Spacer()
                .frame(height: 70)
        }
        .onAppear {
            UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        }
        .navigationTitle("Edit Reminder")
        .navigationBarTitleDisplayMode(.inline)
        
        .navigationBarItems(trailing:
                                Button(action: {
            LocalNotificationManager.scheduleNotification(selectedTime: selectedTime, selectedWeekdays: selectedWeekdays, selectedRingTone: selectedRingTone.stringValue) {
                presentationMode.wrappedValue.dismiss()
            }
        }) {
            Text("Save")
                .foregroundStyle(Color(.label))
        })
    }
    
    
    // MARK: - Functions
    
    func formattedTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: selectedTime)
    }
}

#Preview {
    EditAlarmView(selectedWeekdays: Set(0..<7), selectedTime: .now, selectedRingTone: .JollyRing, id: "")
}
