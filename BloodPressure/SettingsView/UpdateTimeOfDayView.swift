//
//  UpdateTimeOfDayView.swift
//  BloodPressure
//
//  Created by Zsolt Kébel on 18/02/2024.
//

import SwiftUI

struct UpdateTimeOfDayView: View {
    var timeOfDay: PartOfDay
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    //    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = false //TODO: use this
    @State private var notificationsEnabled: Bool = true
    
    @State private var name: String = ""
    @State private var preferredTime: Date = Date()
    @State private var notificationOn: Bool = false
    @State private var notificationBody: String = ""

    @State private var showingDeleteAlert: Bool = false
    
    var body: some View {
        Form {
            Section(header: Text("Name & Time")) {
                HStack {
                    TextField(timeOfDay.name.isEmpty ? "Name" : timeOfDay.name, text: $name)
                    DatePicker(
                        "Time",
                        selection: $preferredTime,
                        displayedComponents: [.hourAndMinute]
                    )
                    .labelsHidden()
                    .datePickerStyle(.compact)
                }
//                Toggle("Active", isOn: $active)

            }
            
            Section("Notification") {
                Toggle("Recieve Reminder", isOn: $notificationOn)
                TextField("Customize Message", text: $notificationBody, axis: .vertical)
                    .lineLimit(2)
            }
            
            Section {
                Button("Delete", role: .destructive) {
                    showingDeleteAlert.toggle()
                }
                .alert(isPresented: $showingDeleteAlert, content: {
                    Alert(title: Text("Are you sure you want to delete \"\(timeOfDay.name)\"?"),
                          primaryButton: .cancel(),
                          secondaryButton: .destructive(Text("Delete"), action: {
                        modelContext.delete(timeOfDay)
                        dismiss()
                    }))
                })
            }
        }
        .onAppear {
            preferredTime = timeOfDay.preferredTime
            notificationOn = timeOfDay.isNotificationEnabled
            notificationBody = timeOfDay.notificationBody
        }
        .navigationTitle("Edit \(timeOfDay.name)")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Done") {
                    updateDayPart()
                    //                    WidgetCenter.shared.reloadTimelines(ofKind: "TripsWidget")
                    dismiss()
                }
            }
        }
    }
    
    private func updateDayPart() {
        if !name.isEmpty {
            timeOfDay.name = name
        }
        
        timeOfDay.preferredTime = preferredTime
        timeOfDay.notificationBody = notificationBody
        
        // Add or remove notification
        if notificationOn {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                if granted {
                    UNUserNotificationCenter.current().updateNotification(for: timeOfDay)
                } else if let error {
                    print(error.localizedDescription)
                }
            }
        } else {
            UNUserNotificationCenter.current().removeNotification(for: timeOfDay)
        }
    }
}

#Preview {
    ModelContainerPreview(PreviewSampleData.inMemoryContainer) {
        NavigationStack {
            UpdateTimeOfDayView(timeOfDay: PartOfDay.morning)
        }
    }
}

extension UNUserNotificationCenter {
    func updateNotification(for time: PartOfDay) {
        removeNotification(for: time)
        addNotification(for: time)
    }
    
    func removeNotification(for time: PartOfDay) {
        if let identifier = time.notificationIdentifier {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
            time.notificationIdentifier = nil
        }
    }
    
    func addNotification(for time: PartOfDay, completion: ((UNNotificationRequest, Error?) -> Void)? = nil) {
        let content = UNMutableNotificationContent()
        content.title = "\(time.name) Reminder"
        content.body = time.notificationBody.isEmpty ? "It's time to measure your blood pressure." : time.notificationBody
        content.sound = UNNotificationSound.default
        
        // show this notification five seconds from now
        let trigger = UNCalendarNotificationTrigger(dateMatching: time.preferredTime.hourAndMinute(), repeats: true)
        
        // choose a random identifier
        let id = UUID().uuidString
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        // add our notification request
        UNUserNotificationCenter.current().add(request) { error in
            if error == nil {
                print("Added notification for \(time.name) at \(time.preferredTime.hourAndMinute())")
                DispatchQueue.main.async {
                    time.notificationIdentifier = id
                }
            }
            completion?(request, error)
        }
    }
}
