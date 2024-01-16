//
//  AlarmListView.swift
//  RemindMe
//
//  Created by Ali Tamoor on 16/01/2024.
//

import SwiftUI

struct AlarmListView: View {
    
@State var showSetAlarmScreen = false
    
    var body: some View {
        NavigationView {
            Text("Hello, World!")
                .navigationBarItems(trailing:
                                        Button(action: {
                    showSetAlarmScreen = true
                }) {
                    Image(systemName: "plus")
                        .font(.title)
                })
            
                .sheet(isPresented: $showSetAlarmScreen) {
                    AlarmView()
                }
        }
    }
}

#Preview {
    AlarmListView()
}
