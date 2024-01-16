//
//  AlarmView.swift
//  RemindMe
//
//  Created by Ali Tamoor on 16/01/2024.
//

import SwiftUI

struct AlarmView: View {
    
    @State private var selectedWeekdays: Set<Int> = Set(0..<7)
    @State private var selectedTime = Date()
    @State private var selectedRingTone: Sounds = .JollyRing
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
                scheduleNotification()
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
    
    private func scheduleNotification() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                let content = UNMutableNotificationContent()
                content.title = "Reminder"
                content.body = "Time to change your destiny!"
                content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "\(selectedRingTone.stringValue).mp3"))
                print("\(selectedRingTone.stringValue).mp3")
                let userTimeZone = TimeZone.current
                let calendar = Calendar.current
                
                let localTime = calendar.date(bySettingHour: calendar.component(.hour, from: selectedTime),
                                              minute: calendar.component(.minute, from: selectedTime),
                                              second: 0, of: selectedTime)
                
                var dateComponents = calendar.dateComponents([.hour, .minute, .second], from: selectedTime)
                dateComponents.timeZone = userTimeZone
                dateComponents.second = 0
                // Set up a repeating trigger based on selected days
                for index in selectedWeekdays {
                    dateComponents.weekday = index + 1 // Weekdays are 1-indexed
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                    let request = UNNotificationRequest(identifier: "alarm-\(index)", content: content, trigger: trigger)
                    center.add(request) { error in
                        if let error = error {
                            print("Error scheduling notification: \(error.localizedDescription)")
                        } else {
                            print("Notification for day \(index+1) scheduled successfully")
                        }
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            } else {
                print("Permission denied for notifications")
            }
        }
    }

//    private func scheduleNotification() {
//            let center = UNUserNotificationCenter.current()
//            center.requestAuthorization(options: [.alert, .sound]) { granted, error in
//                if granted {
//                    let content = UNMutableNotificationContent()
//                    content.title = "Alarm"
//                    content.body = "Time to wake up!"
//                    content.sound = .default
//                    
//                    let userTimeZone = TimeZone.current
//                    let calendar = Calendar.current
//                    
//                    let localTime = calendar.date(bySettingHour: calendar.component(.hour, from: selectedTime),
//                                                  minute: calendar.component(.minute, from: selectedTime),
//                                                  second: 0, of: selectedTime)
//                    var dateComponents = DateComponents()
//                    let trigger = UNCalendarNotificationTrigger(dateMatching: calendar.dateComponents([.hour, .minute, .second], from: localTime!), repeats: false)
//                    
//                    let request = UNNotificationRequest(identifier: "alarm", content: content, trigger: trigger)
//                    
//                    center.add(request) { error in
//                        if let error = error {
//                            print("Error scheduling notification: \(error.localizedDescription)")
//                        } else {
//                            print("Notification scheduled successfully")
//                        }
//                    }
//                } else {
//                    print("Permission denied for notifications")
//                }
//            }
//        }
}

#Preview {
    AlarmView()
}
