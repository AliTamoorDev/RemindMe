//
//  AddReminderView.swift
//  RemindMe
//
//  Created by Ali Tamoor on 16/01/2024.
//

import SwiftUI

/// Screen to create new reminders
struct AddReminderView: View {
    
    @State var selectedWeekdays: Set<Int> = Set(0..<7)
    @State var selectedTime = Date()
    @State var selectedRingTone: Sounds = .autumnWind
    @Environment(\.presentationMode) var presentationMode

    init() {
        // To set color of navigationbar items to white
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
                // To save a new reminder locally with all the user set configurations
                let id = UUID().uuidString
                LocalNotificationManager.scheduleNotification(id: id, selectedTime: selectedTime, selectedWeekdays: selectedWeekdays, selectedRingTone: selectedRingTone.stringValue) {
                    
                    var reminder = LocalNotificationManager.getReminderListFromUD()
                    var reminderObj = ReminderModel()
                    reminderObj.reminderId = id
                    reminderObj.selectDaysIndex = selectedWeekdays
                    reminderObj.time = formattedTime()
                    reminderObj.date = selectedTime
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
    
    // To convert time to string
    func formattedTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: selectedTime)
    }
}

#Preview {
    AddReminderView()
}
