//
//  EditReminderView.swift
//  RemindMe
//
//  Created by Ali Tamoor on 17/01/2024.
//

import SwiftUI

struct EditReminderView: View {
    
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
                self.deleteReminder()
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
            self.editReminder()
        }) {
            Text("Save")
                .foregroundStyle(Color(.label))
        })
    }
    
    
    // MARK: - Functions
    func deleteReminder() {
        LocalNotificationManager.pauseOrDeleteNotifications(reminderId: reminderId)
        
        var reminders = LocalNotificationManager.getReminderListFromUD()
        reminders = reminders?.filter{ $0.reminderId != reminderId }
        
        LocalNotificationManager.saveRemindersToUD(reminders ?? [])
        
        presentationMode.wrappedValue.dismiss()
    }
    
    func editReminder() {
        // Deleting Already Scheduled Local Notification
        LocalNotificationManager.pauseOrDeleteNotifications(reminderId: reminderId)
        
        // Modifying the selected reminder
        var reminders = LocalNotificationManager.getReminderListFromUD()
        reminders = reminders?.map { reminder in
            var reminderObj = reminder
            if reminderObj.reminderId == reminderId {
                reminderObj.time = formattedTime()
                reminderObj.selectDaysIndex = selectedWeekdays
                reminderObj.date = selectedTime
                reminderObj.selectDays = []
                selectedWeekdays.forEach { day in
                    let day = Day.allCases[day]
                    reminderObj.selectDays.insert(day)
                }
                reminderObj.sound = selectedRingTone
            }
            return reminderObj
        }
        
        // Saving the Modified reminder
        LocalNotificationManager.saveRemindersToUD(reminders ?? [])
        
        // Creating Modified Version of Local Notification
        LocalNotificationManager.scheduleNotification(id: reminderId, selectedTime: selectedTime, selectedWeekdays: selectedWeekdays, selectedRingTone: selectedRingTone.stringValue) {
            DispatchQueue.main.async {
                presentationMode.wrappedValue.dismiss()

            }
        }
    }
    
    func formattedTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: selectedTime)
    }
}

#Preview {
    EditReminderView(selectedWeekdays: Set(0..<7), selectedTime: .now, selectedRingTone: .jollyRing, id: "")
}
