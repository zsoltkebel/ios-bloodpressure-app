//
//  SetupView.swift
//  BloodPressure
//
//  Created by Zsolt Kébel on 17/02/2024.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    @Query(sort: \PartOfDay.preferredTime) var times: [PartOfDay]
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ForEach(times) { time in
                        TimeOfDayListItem(timeOfDay: time)
                    }
                    Button("Add Time") {
                        //TODO: implement add custom time feature
                    }
                } header: {
                    Text("Times of Day")
                } footer: {
                    Text("Select the times you want to track your blood pressure and heartrate throughout the day.")
                }
                //TODO: Future feature
//                Section {
//                    NotificationsToggleView(times: times)
//                } header: {
//                    Text("Notifications")
//                }
            }
            .navigationTitle("Times")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: PartOfDay.self) { time in
                UpdateTimeOfDayView(timeOfDay: time)
            }
            .toolbar(content: {
                ToolbarItem {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                    
                }
            })
        }
    }
    
}

#Preview {
    SettingsView()
        .modelContainer(PreviewSampleData.container)
}

struct NotificationsToggleView: View {
    @Environment(\.scenePhase) var scenePhase
    
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = false
    
    @State private var settings: UNNotificationSettings?
    
    var times: [PartOfDay]
    
    var body: some View {
        Toggle("Recieve Reminders", isOn: $notificationsEnabled)
            .disabled(settings?.authorizationStatus == .denied || settings?.authorizationStatus == .notDetermined)
            .onChange(of: notificationsEnabled) {
//                if notificationsEnabled {
//                    times.filter({ $0.isTracked }).forEach({ $0.addNotification() })
//                } else {
//                    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
//                    times.filter({ $0.isTracked }).forEach({ $0.removePendingNotification() })
//                }
            }
            .task {
                await onViewBecomesActive()
            }
            .onChange(of: scenePhase, { _, newPhase in
                if newPhase == .active {
                    print("Active")
                    Task {
                        await onViewBecomesActive()
                    }
                }
            })
        buildOpenSettingButtonIfNeeded()
    }
    
    func onViewBecomesActive() async {
        self.settings = await UNUserNotificationCenter.current().notificationSettings()
        // For debugging
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        print(requests.count)
    }
    
    @ViewBuilder
    func buildOpenSettingButtonIfNeeded() -> some View {
        if settings?.authorizationStatus == .denied {
            Section {
                Button {
                    if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                        UIApplication.shared.open(appSettings)
                    }
                } label: {
                    Text("Open Settings")
                }
            } footer: {
                Text("Notifications are disabled for this app. Open Settings to enable them.")
            }
        }
    }
    
}
