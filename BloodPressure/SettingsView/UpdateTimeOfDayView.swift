//
//  UpdateTimeOfDayView.swift
//  BloodPressure
//
//  Created by Zsolt Kébel on 18/02/2024.
//

import SwiftUI

struct UpdateTimeOfDayView: View {
    @Bindable var timeOfDay: PartOfDay
    
//    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = false //TODO: use this
    @State private var notificationsEnabled: Bool = true

    var body: some View {
        Form {
            Toggle("Recieve Reminder", isOn: $timeOfDay.isTracked)
                .onChange(of: timeOfDay.isTracked) {
                    if notificationsEnabled {
                        if timeOfDay.isTracked {
                            timeOfDay.addNotification()
                        } else {
                            timeOfDay.removePendingNotification()
                        }
                    }
                }
            if timeOfDay.isTracked {
                DatePicker(
                    "Time",
                    selection: $timeOfDay.notificationDate,
                    in: timeOfDay.range,
                    displayedComponents: [.hourAndMinute]
                )
                .datePickerStyle(.wheel)
                .onChange(of: timeOfDay.notificationDate) {
                    if notificationsEnabled {
                        timeOfDay.updateNotification()
                    }
                }
            }
        }
        .navigationTitle(timeOfDay.name)
    }
    
    func updateNotification(withNewTime: String) {
//        if notificationsEnabled {
//            timeOfDay.updateNotification(newTime: withNewTime)
//        }
    }
}

#Preview {
    UpdateTimeOfDayView(timeOfDay: PartOfDay.morning)
}
