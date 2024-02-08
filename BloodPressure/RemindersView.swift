//
//  ScheduleView.swift
//  blood_pressure
//
//  Created by Zsolt Kébel on 04/02/2024.
//

import SwiftUI
import UserNotifications

enum TimeOfDay {
    case morning, afternoon, evening
    
    func getNotificationIdentifier() -> String {
        switch self {
        case .morning:
            return "morningBP"
        case .afternoon:
            return "afternoonBP"
        case .evening:
            return "eveningBP"
        }
    }
    
    func getNotificationTitle() -> String {
        switch self {
        case .morning:
            return "Morning Reminder"
        case .afternoon:
            return "Afternoon Reminder"
        case .evening:
            return "Evening Reminder"
        }
    }
    
    func getName() -> String {
        switch self {
        case .morning:
            return "Morning"
        case .afternoon:
            return "Afternoon"
        case .evening:
            return "Evening"
        }
    }
    
    func getDefaultTimeComponents() -> DateComponents {
        switch self {
        case .morning:
            return DateComponents(hour: 8, minute: 0)
        case .afternoon:
            return DateComponents(hour: 14, minute: 0)
        case .evening:
            return DateComponents(hour: 20, minute: 0)
        }
    }
}

struct RemindersView: View {
    @Environment(\.dismiss) var dismiss
    
    // TODO: retrieve this setting
    @AppStorage("enableNotifications") private var enableNotifications = false
    
    var body: some View {
        Form {
            Section {
                Toggle("Reminder Notifications", isOn: $enableNotifications)
                    .onChange(of: enableNotifications) { oldValue, newValue in
                        if newValue {
                            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                                if success {
                                    print("All set!")
                                } else if let error {
                                    print(error.localizedDescription)
                                    enableNotifications = false
                                }
                            }
                        } else {
                            print("removing all notifications")
                            //                        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [TimeOfDay.morning.getNotificationIdentifier(), TimeOfDay.afternoon.getNotificationIdentifier(), TimeOfDay.evening.getNotificationIdentifier()])
                        }
                    }
            } footer: {
                Text("When switched on, this app can send you timed notifications to remind you to take measurements.")
            }
            if enableNotifications {
                NotificationTimePicker(for: .morning)
                NotificationTimePicker(for: .afternoon)
                NotificationTimePicker(for: .evening)
            }
        }
        .navigationTitle("Reminders")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                Button(action: {
                    dismiss()
                }, label: {
                    Text("Done")
                })
            }
        }
    }
}

#Preview {
    RemindersView()
}

struct NotificationTimePicker: View {
    @State private var notificationEnabled = false
    @State private var notificationTime: Date
    
    private var timeOfDay: TimeOfDay
    
    init(for timeOfDay: TimeOfDay) {
        self.timeOfDay = timeOfDay
        self._notificationTime = State<Date>(initialValue: Calendar.current.date(from: timeOfDay.getDefaultTimeComponents())!)
    }
    
    var body: some View {
        Section {
            Toggle(timeOfDay.getName(), isOn: $notificationEnabled)
                .onChange(of: notificationEnabled) { oldValue, newValue in
                    if newValue {
                        let components = Calendar.current.dateComponents([.hour, .minute], from: notificationTime)
                        changeNotificationTime(of: timeOfDay, time: components)
                    } else {
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [timeOfDay.getNotificationIdentifier()])
                    }
                }
                .onAppear {
                    // get time of notification
                    UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                        if let notification = requests.first(where: { request in
                            request.identifier == timeOfDay.getNotificationIdentifier()
                        }) {
                            let timeComponents = (notification.trigger as! UNCalendarNotificationTrigger).dateComponents
                            notificationTime = Calendar.current.date(from: timeComponents)!
                            print("Retrieved notification time for \(timeOfDay.getName()): \(timeComponents)")
                            notificationEnabled = true
                        } else {
                            // There is no notification so add one
                            notificationEnabled = false
                            print("Scheduling notification for \(timeOfDay.getName())")
                            //                            scheduleRecurringNotification(for: timeOfDay, at: Calendar.current.dateComponents([.hour, .minute], from: notificationTime))
                        }
                    }
                }
            if notificationEnabled {
                DatePicker(
                    "Every Day At",
                    selection: $notificationTime,
                    displayedComponents: [.hourAndMinute]
                )
                .foregroundStyle(.gray)
                .datePickerStyle(.compact)
                .onChange(of: notificationTime) { oldValue, newValue in
                    let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                    changeNotificationTime(of: timeOfDay, time: components)
                }
                
            }
        }
    }
}

func changeNotificationTime(of timeOfDay: TimeOfDay, time: DateComponents) {
    //    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [timeOfDay.getNotificationIdentifier()])
    scheduleRecurringNotification(for: timeOfDay, at: time)
}

func scheduleRecurringNotification(for timeOfDay: TimeOfDay, at dateMatching: DateComponents) {
    let content = UNMutableNotificationContent()
    content.title = timeOfDay.getNotificationTitle()
    content.body = "It's time to measure your blood pressure."
    content.sound = UNNotificationSound.default
    
    // show this notification five seconds from now
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateMatching, repeats: true)
    
    // choose a random identifier
    let request = UNNotificationRequest(identifier: timeOfDay.getNotificationIdentifier(), content: content, trigger: trigger)
    
    // add our notification request
    UNUserNotificationCenter.current().add(request)
}
