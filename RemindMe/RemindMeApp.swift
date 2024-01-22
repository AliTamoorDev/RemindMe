//
//  RemindMeApp.swift
//  RemindMe
//
//  Created by Ali Tamoor on 16/01/2024.
//

import SwiftUI

@main
struct RemindMeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ReminderListView()
//                .tint(.white)
        }
    }
}
