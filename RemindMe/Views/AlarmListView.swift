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
                        
                        //                        ForEach($formattedReminders, id: \.id) { $reminder in
                        //                            NavigationLink(value: reminder) {
                        //                                ReminderCell(reminder: $reminder, pausedReminders: $pausedReminders)
                        //                            }
                        //                        }
                        .onDelete(perform: { indexSet in
                            LocalNotificationManager.pauseOrDeleteNotifications(reminderId: formattedReminders[indexSet.first ?? 0].reminderId)
                            formattedReminders.remove(atOffsets: indexSet)
                        })
                    }
                }
                .navigationDestination(for: AlarmModel.self) { item in
                    EditAlarmView(selectedWeekdays: item.selectDaysIndex, selectedTime: item.date, selectedRingTone: .autumnWind, id: item.reminderId)
                }
                .onAppear {
                    LocalNotificationManager.fetchNotifications { reminders in
                        formattedReminders = reminders
                    }
                }
                .sheet(isPresented: $showSetAlarmScreen) {
                    AlarmView()
                        .onDisappear(perform: {
                            LocalNotificationManager.fetchNotifications { reminders in
                                formattedReminders = reminders
                            }
                        })
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
                
                if formattedReminders.isEmpty {
                    Text("No Reminders Currently!")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
            }
        }
    }
}

#Preview {
    AlarmListView()
}

struct ReminderCell: View {
    
    @State var isReminderNotPaused = true
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
//            Toggle("", isOn: $isReminderNotPaused)
//                .padding(.trailing, 10)
//                .onChange(of: isReminderNotPaused) { oldValue, newValue in
//                    if newValue {
//                        LocalNotificationManager.scheduleNotification(selectedTime: reminder.date, selectedWeekdays: reminder.selectDaysIndex, selectedRingTone: Sounds.JollyRing.rawValue) {
//                            pausedReminders.remove(at: index)
//                        }
//                    } else {
//                        LocalNotificationManager.pauseOrDeleteNotifications(reminderId: reminder.reminderId)
//                    }
//                }
        }
    }
}
