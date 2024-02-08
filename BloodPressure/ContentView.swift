//
//  ContentView.swift
//  blood_pressure
//
//  Created by Zsolt Kébel on 25/01/2024.
//

import SwiftUI
import HealthKit

struct SimpleNumberInput: View {
    let text: String
    let value: Binding<Int?>
    
    @FocusState private var focused: Bool
    
    var body: some View {
        HStack {
            Text(text).foregroundStyle(.gray).onTapGesture(perform: {
                focused = true
            })
            TextField("", value: value, format: .number)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .focused($focused)
        }
    }
}

struct ContentView: View {
    @State private var date = Date()  // date and time of the measurement
    @State private var systolic: Int?
    @State private var diastolic: Int?
    @State private var heartRate: Int?
    
    private var healtKitManager = HealthKitManager()
    
    // the toggle for showing-hiding the "Now" button next to the date and time picker
    @State private var showingNowButton = false
    // the toggle for showing "Health access is denied open Settings" to enable alert
    @State private var showingAccessDeniedAlert = false
    
    @State private var showingSaved = false
    
    @State private var showingSheet = false
    
    var body2: some View {
        ScheduleView()
    }
    var body: some View {
        NavigationStack {
            ZStack {
                Form {
                    HStack {
                        DatePicker(
                            "Date",
                            selection: $date,
                            displayedComponents: [.date, .hourAndMinute]
                        ).foregroundStyle(.gray)
                            .datePickerStyle(.compact)
                        if showingNowButton || !Calendar.current.isDate(date, equalTo: Date(), toGranularity: .minute) {
                            Button {
                                date = Date()
                                showingNowButton = false
                                refreshNowButtonNextMinute()
                            } label: {
                                Text("Now")
                            }.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                        }
                    }
                    Section(header: Text("Blood Pressure")) {
                        SimpleNumberInput(text: "Systolic", value: $systolic)
                        SimpleNumberInput(text: "Diastolic", value: $diastolic)
                    }
                    Section(header: Text("Heart Rate")) {
                        SimpleNumberInput(text: "BPM", value: $heartRate)
                    }
                    
                }
                VStack {
                    Spacer()
                    Button {
                        onAddDataPressed()
                    } label: {
                        if showingSaved {
                            Label("Saved Successfully", systemImage: "checkmark").frame(maxWidth: .infinity, maxHeight: 36)
                        } else {
                            Label("Add to Health", systemImage: "plus").frame(maxWidth: .infinity, maxHeight: 36)
                        }
                    }
                    .disabled(systolic == nil || diastolic == nil || heartRate == nil).labelStyle(.titleAndIcon).buttonStyle(.borderedProminent).padding()
                    .alert(
                        "Can't access your Health Data",
                        isPresented: $showingAccessDeniedAlert
                    ) {
                        Button("OK") {
                            // Handle the acknowledgement.
                        }
                        Button("Open Settings") {
                            // Get the settings URL and open it
                            // Settings url would be URL(string: UIApplication.openSettingsURLString)
                            if let url = URL(string: "App-Prefs:HEALTH&path=SOURCES_ITEM") {
                                UIApplication.shared.open(url)
                            }
                        }
                    } message: {
                        Text("Go to Settings > Health > Data Accesss & Devices > blood_pressure and click \"Turn On All\"")
                    }
                }
            }
            .navigationTitle("Add Data")
            .toolbar {
                ToolbarItem {
                    Menu("Menu", systemImage: "ellipsis.circle") {
                        Button("Reminders", systemImage: "clock") {
                            showingSheet.toggle()
                        }
                        
                    }
                }
            }
        }
        .onAppear {
            refreshNowButtonNextMinute()
        }
        .sheet(isPresented: $showingSheet) {
            NavigationStack {
                ScheduleView()
            }
        }
    }
    
    func refreshNowButtonNextMinute() {
        let nextMinute = DispatchTime.now() + 60 - Double(Calendar.current.component(.second, from: Date()))
        DispatchQueue.main.asyncAfter(deadline: nextMinute) {
            showingNowButton = true
        }
    }
    
    func wid(text: String, value: Binding<Int>) -> any View {
        return HStack {
            Text(text)
            TextField("input", value: value, format: .number).keyboardType(.numberPad).multilineTextAlignment(.trailing)
        }
    }
    
    func onAddDataPressed() {
        healtKitManager.authorizationRequestHealthKit { available, error in
            guard healtKitManager.isSharingAuthorized() else {
                print("not auhtorised")
                showingAccessDeniedAlert = true
                return
            }
            healtKitManager.saveBloodPressureMeasurement(date: date, systolic: systolic!, diastolic: diastolic!, heartRate: heartRate!) { comp, error in
                if error == nil {
                    systolic = nil
                    diastolic = nil
                    heartRate = nil
                    showingSaved = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        showingSaved = false
                    }
                    clearRelevantNotification()
                }
            }
        }
        
    }
    
    func clearRelevantNotification() {
        UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
            notifications.forEach { notification in
                let diff = date.timeIntervalSince(notification.date)
                if abs(diff) < 60 * 60 {
                    UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [notification.request.identifier])
                }
            }
        }
    }
    
}

#Preview {
    ContentView()
}
