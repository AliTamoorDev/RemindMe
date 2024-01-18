//
//  AlarmListView.swift
//  RemindMe
//
//  Created by Ali Tamoor on 16/01/2024.
//

import SwiftUI

struct ReminderListView: View {
    
    @State var showSetAlarmScreen = false
    @State var showEditAlarmScreen = false
    
    @State var formattedReminders = [AlarmModel]()
    
    @State var selectedReminderTime: Date = .now
    @State var selectedReminderWeekDays = Set(0..<7)
    
    @State var pausedReminders = [AlarmModel]()
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(alignment: .center) {
                    List {
                        
                        ForEach(Array(formattedReminders.enumerated()), id: \.element.id) { (index, reminder) in
                            NavigationLink(value: reminder) {
                                ReminderCell(reminder: $formattedReminders[index], pausedReminders: $pausedReminders, index: index)
                            }
                        }
                        .onDelete(perform: { indexSet in
                            deleteReminder(indexSet: indexSet)
                        })
                    }
                }
                .navigationDestination(for: AlarmModel.self) { item in
                    EditAlarmView(selectedWeekdays: item.selectDaysIndex, selectedTime: item.date, selectedRingTone: item.sound, id: item.reminderId)
                }
                .onAppear {
                    formattedReminders = LocalNotificationManager.getAlarmModel() ?? []
                }
                .sheet(isPresented: $showSetAlarmScreen) {
                    AlarmView()
                        .onDisappear(perform: {
                            formattedReminders = LocalNotificationManager.getAlarmModel() ?? []
                        })
                }
                .navigationTitle("Reminders")
                .navigationBarTitleDisplayMode(.inline)
                
                // Navbar Trailing button
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
                
                // Navbar Leading button
                .navigationBarItems(leading:
                                        Button(action: {
                    LocalNotificationManager.fetchNotifications { reminders in
                        print(reminders.count)
                        print(reminders)
                        
                    }
                }) {
                    Image(systemName: "eye")
                        .resizable()
                        .frame(width: 25, height: 20)
                        .foregroundColor(.white)
                        .font(.title)
                        .padding(.trailing, 10)
                })
                
                if formattedReminders.isEmpty {
                    Text("No Reminders Currently!")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
            }
        }
    }
    
    // MARK: - Methods
    
    func deleteReminder(indexSet: IndexSet) {
        LocalNotificationManager.pauseOrDeleteNotifications(reminderId: formattedReminders[indexSet.first ?? 0].reminderId)
        formattedReminders.remove(atOffsets: indexSet)
        LocalNotificationManager.saveAlarmModel(formattedReminders)
    }
}

#Preview {
    ReminderListView()
}

struct ReminderCell: View {
    
    @State var isReminderScheduled = true
    @Binding var reminder: AlarmModel
    @Binding var pausedReminders: [AlarmModel]
    
    var index: Int
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(reminder.time)
                    .font(.title)
                Text(reminder.repeatDay)
                    .font(.subheadline)
            }
            Spacer()
            Toggle("", isOn: $isReminderScheduled)
                .padding(.trailing, 10)
                .onChange(of: isReminderScheduled) { oldValue, newValue in
                    if newValue {
                        LocalNotificationManager.scheduleNotification(id: reminder.reminderId, selectedTime: reminder.date, selectedWeekdays: reminder.selectDaysIndex, selectedRingTone: reminder.sound.rawValue) {
                        }
                    } else {
                        LocalNotificationManager.pauseOrDeleteNotifications(reminderId: reminder.reminderId)
                        print("Notification paused for \(index)")
                    }
                    editReminder(isScheduled: newValue)
                }
                .onAppear(perform: {
                    isReminderScheduled = reminder.isScheduled
                })
        }
    }
    
    func editReminder(isScheduled: Bool) {
        
        // Modifying the selected reminder
        var reminders = LocalNotificationManager.getAlarmModel()
        reminders = reminders?.map { alarm in
            var reminderObj = alarm
            if reminderObj.reminderId == reminder.reminderId {
                reminderObj.isScheduled = isScheduled
            }
            return reminderObj
        }
        
        // Saving the Modified reminder
        LocalNotificationManager.saveAlarmModel(reminders ?? [])
    }
}
