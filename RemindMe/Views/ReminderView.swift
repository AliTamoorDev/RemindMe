//
//  ReminderView.swift
//  RemindMe
//
//  Created by Ali Tamoor on 16/01/2024.
//

import SwiftUI

struct ReminderView: View {
    
    @State var selectedWeekdays: Set<Int> = Set(0..<7)
    @State var selectedTime = Date()
    @State var selectedRingTone: Sounds = .autumnWind
    @Environment(\.presentationMode) var presentationMode

    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    var body: some View {
        NavigationStack {
            
            VStack {
                
                Text("Scheduled Time: \(formattedTime())")
                    .foregroundStyle(Color(.label))
                
                DatePicker("Select a time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .padding()
                
                WeekdaySelectionView(selectedWeekdays: $selectedWeekdays)
                    
                CustomNavigationPicker(strengths: Sounds.allCases, selectedStrength: $selectedRingTone)
            }
            .navigationTitle("Add Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading:
                                    Button(action: {
                presentationMode.wrappedValue.dismiss()

            }) {
                Text("Cancel")
                    .foregroundStyle(Color(.label))
            })
        
            .navigationBarItems(trailing:
                                    Button(action: {
                let id = UUID().uuidString
                LocalNotificationManager.scheduleNotification(id: id, selectedTime: selectedTime, selectedWeekdays: selectedWeekdays, selectedRingTone: selectedRingTone.stringValue) {
                    
                    var reminder = LocalNotificationManager.getReminderListFromUD()
                    var reminderObj = ReminderModel()
                    reminderObj.reminderId = id
                    reminderObj.selectDaysIndex = selectedWeekdays
                    reminderObj.time = formattedTime()
                    reminderObj.selectDaysIndex = selectedWeekdays
                    selectedWeekdays.forEach { day in
                        let day = Day.allCases[day]
                        reminderObj.selectDays.insert(day)
                    }
                    reminderObj.sound = selectedRingTone
                    reminder?.append(reminderObj)
                    LocalNotificationManager.saveRemindersToUD(reminder ?? [reminderObj])
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                Text("Save")
                    .foregroundStyle(Color(.label))
            })
        }
    }
    
    func formattedTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: selectedTime)
    }
}

#Preview {
    ReminderView()
}
