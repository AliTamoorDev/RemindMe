//
//  AlarmListView.swift
//  RemindMe
//
//  Created by Ali Tamoor on 16/01/2024.
//

import SwiftUI

struct AlarmListView: View {
    
    @State var showSetAlarmScreen = false
    @State var showEditAlarmScreen = false
    @State var scheduledReminders: [String: [UNNotificationRequest]] = [:]
    @State var formattedReminders = [AlarmModel]()
    
    @State var selectedReminderTime: Date = .now
    @State var selectedReminderWeekDays = Set(0..<7)
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(formattedReminders, id: \.id) { reminder in
                        NavigationLink(value: reminder) {
                            VStack(alignment: .leading) {
                                Text(reminder.time)
                                    .font(.title)
                                Text(reminder.repeatDay)
                                    .font(.subheadline)
                            }
                        }
                    }
                    .onDelete(perform: { indexSet in
                        
                    })
                }
                
            }
            .navigationDestination(for: AlarmModel.self) { item in
                EditAlarmView(selectedWeekdays: item.selectDaysIndex, selectedTime: item.date, selectedRingTone: .JollyRing)
//                Text("Hey")
            }
            .onAppear {
                UNUserNotificationCenter.current().getPendingNotificationRequests { (reqs) in
                    scheduledReminders = [:]
                    formattedReminders = []
                    for reminder in reqs {
                        if let id = reminder.identifier.components(separatedBy: ":").last {
                            var alarmObj = AlarmModel(reminderId: id)
                            if scheduledReminders[id] != nil {
                                scheduledReminders[id]?.append(reminder)
                            } else {
                                scheduledReminders[id] = [reminder]
                            }
                        }
                    }
                    
                    scheduledReminders.forEach { (key: String, value: [UNNotificationRequest]) in
                        var alarmObj = AlarmModel(reminderId: key)
                        for alarm in value {
                            if let dc = (alarm.trigger as? UNCalendarNotificationTrigger)?.dateComponents {
                                let day = Day.allCases[(dc.weekday ?? 0) - 1]
                                alarmObj.selectDays.insert(day)
                                alarmObj.selectDaysIndex.insert((dc.weekday ?? 0) - 1)
                                alarmObj.time = "\(dc.hour ?? 0):\(dc.minute ?? 0)"
                                alarmObj.date = getDate(data: dc) ?? .now
                            }
                        }
                        formattedReminders.append(alarmObj)
                    }
                    if let dc = (reqs.first?.trigger as? UNCalendarNotificationTrigger)?.dateComponents {
                        print("\(dc.hour ?? 0):\(dc.minute ?? 0)")
                        
                    }
                }
            }
            .sheet(isPresented: $showSetAlarmScreen) {
                AlarmView()
            }
            .navigationTitle("Reminders")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing:
                                    Button(action: {
                showSetAlarmScreen = true
            }) {
                Image(systemName: "plus")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.white)
                    .font(.title)
                    .padding(.trailing, 10)
            })
        }
    }
    
    func getDate(data: DateComponents) -> Date? {
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
}

#Preview {
    AlarmListView()
}

//var ids =  [String]()
//reqs.forEach {
//    if $0.identifier == "someId" {
//        ids.append($0.identifier)
//    }
//}
//UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers:ids)
