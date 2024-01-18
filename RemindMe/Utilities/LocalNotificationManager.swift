//
//  LocalNotificationManager.swift
//  RemindMe
//
//  Created by Ali Tamoor on 18/01/2024.
//

import SwiftUI

struct LocalNotificationManager {
    static func scheduleNotification(id: String, selectedTime: Date, selectedWeekdays: Set<Int>, selectedRingTone: String, completion: @escaping ()->()) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                let content = UNMutableNotificationContent()
                content.title = "Reminder"
                content.body = "Time to change your destiny!"
                content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "\(selectedRingTone).mp3"))
                print("\(selectedRingTone).mp3")
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
                    let request = UNNotificationRequest(identifier: "reminder\(index):\(id)", content: content, trigger: trigger)
                    center.add(request) { error in
                        if let error = error {
                            print("Error scheduling notification: \(error.localizedDescription)")
                        } else {
                            print("Notification for day \(index+1) scheduled successfully")
                        }
                    }
                }
                completion()
            } else {
                completion()
                print("Permission denied for notifications")
            }
        }
    }
    
    static func fetchNotifications(completion: @escaping ([ReminderModel] )->()){
        var scheduledNotifications: [String: [UNNotificationRequest]] = [:]
        var formattedNotifications = [ReminderModel]()

        UNUserNotificationCenter.current().getPendingNotificationRequests { (reqs) in
            scheduledNotifications = [:]
            for reminder in reqs {
                if let id = reminder.identifier.components(separatedBy: ":").last {
                    if scheduledNotifications[id] != nil {
                        scheduledNotifications[id]?.append(reminder)
                    } else {
                        scheduledNotifications[id] = [reminder]
                    }
                }
            }
            
            scheduledNotifications.forEach { (key: String, value: [UNNotificationRequest]) in
                var reminderObj = ReminderModel(reminderId: key)
                for reminder in value {
                    if let dc = (reminder.trigger as? UNCalendarNotificationTrigger)?.dateComponents {
                        let day = Day.allCases[(dc.weekday ?? 0) - 1]
                        reminderObj.selectDays.insert(day)
                        reminderObj.selectDaysIndex.insert((dc.weekday ?? 0) - 1)
                        reminderObj.date = getDate(data: dc) ?? .now
                        
                        if let hour = dc.hour, let minute = dc.minute {
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "h:mm a"
                            
                            if let date = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) {
                                reminderObj.time = dateFormatter.string(from: date)
                            }
                        }
                    }
                }
                formattedNotifications.append(reminderObj)
            }
            if let dc = (reqs.first?.trigger as? UNCalendarNotificationTrigger)?.dateComponents {
                print("\(dc.hour ?? 0):\(dc.minute ?? 0)")
                
            }
            completion(formattedNotifications)
        }
    }
    
    static func pauseOrDeleteNotifications(reminderId: String) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { (reqs) in
            var ids =  [String]()
            reqs.forEach {
                if $0.identifier.components(separatedBy: ":").last == reminderId {
                    ids.append($0.identifier)
                }
            }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers:ids)
        }
    }
    
    static func getDate(data: DateComponents) -> Date? {
        let calendar = Calendar.current
        let hour = data.hour ?? 0
        let minute = data.minute ?? 0
        let currentDate = Date()
        
        if let newDate = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: currentDate) {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            let formattedTimeString = formatter.string(from: newDate)
            
            if let formattedDate = formatter.date(from: formattedTimeString) {
                return formattedDate
            }
        }
        return nil
    }
    
    // MARK: - User Default Methods
    
    static func saveRemindersToUD(_ reminderModel: [ReminderModel]) {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(reminderModel.sorted(by: {$0.date < $1.date}))
            UserDefaults.standard.set(encodedData, forKey: "reminderModelKey")
        } catch {
            print("Error encoding ReminderModel: \(error.localizedDescription)")
        }
    }

    // Function to retrieve ReminderModel from UserDefaults
    static func getReminderListFromUD() -> [ReminderModel]? {
        if let encodedData = UserDefaults.standard.data(forKey: "reminderModelKey") {
            do {
                let decoder = JSONDecoder()
                let reminderModel = try decoder.decode([ReminderModel].self, from: encodedData)
                return reminderModel
            } catch {
                print("Error decoding ReminderModel: \(error.localizedDescription)")
                return nil
            }
        }
        return nil
    }
}
