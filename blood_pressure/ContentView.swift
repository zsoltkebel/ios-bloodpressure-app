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
            .onAppear {
                refreshNowButtonNextMinute()
            }
            .navigationTitle("Add Data")
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
                }
            }
        }
        
    }
    
}

#Preview {
    ContentView()
}

class HealthKitManager {
    fileprivate let healthKitStore = HKHealthStore()
    
    private let systolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic)!
    private let diastolicType = HKSampleType.quantityType(forIdentifier: .bloodPressureDiastolic)!
    private let heartRateType = HKSampleType.quantityType(forIdentifier: .heartRate)!
    
    func isSharingAuthorized() -> Bool {
        let systolicStatus = healthKitStore.authorizationStatus(for: systolicType)
        let diastolicStatus = healthKitStore.authorizationStatus(for: diastolicType)
        let heartRateStatus = healthKitStore.authorizationStatus(for: heartRateType)
        return systolicStatus == HKAuthorizationStatus.sharingAuthorized && diastolicStatus == HKAuthorizationStatus.sharingAuthorized && heartRateStatus == HKAuthorizationStatus.sharingAuthorized
    }
    
    func authorizationRequestHealthKit(completion: @escaping (Bool, Error?) -> Void) {
        // 1
        guard HKHealthStore.isHealthDataAvailable() else {
            let error = NSError(domain: "com.zsoltkebel.mobile", code: 999,
                                userInfo: [NSLocalizedDescriptionKey : "Healthkit not available on this device"])
            completion(false, error)
            print("HealthKit not available on this device")
            return
        }
        // 2
        let types: Set<HKSampleType> = [systolicType, diastolicType, heartRateType]
        // 3
        healthKitStore.requestAuthorization(toShare: types, read: types) { (success: Bool, error: Error?) in
            completion(success, error)
        }
    }
    
    func saveBloodPressureMeasurement(date startDate: Date = Date(), systolic: Int, diastolic: Int, heartRate: Int, completion: @escaping (Bool, Error?) -> Void) {
        // 1
        let endDate = startDate
        // 2
        let systolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic)!
        let systolicQuantity = HKQuantity(unit: HKUnit.millimeterOfMercury(), doubleValue: Double(systolic))
        let systolicSample = HKQuantitySample(type: systolicType, quantity: systolicQuantity, start: startDate, end: endDate)
        let diastolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic)!
        let diastolicQuantity = HKQuantity(unit: HKUnit.millimeterOfMercury(), doubleValue: Double(diastolic))
        let diastolicSample = HKQuantitySample(type: diastolicType, quantity: diastolicQuantity, start: startDate, end: endDate)
        // 3
        let bpCorrelationType = HKCorrelationType.correlationType(forIdentifier: .bloodPressure)!
        let bpCorrelation = Set(arrayLiteral: systolicSample, diastolicSample)
        let bloodPressureSample = HKCorrelation(type: bpCorrelationType , start: startDate, end: endDate, objects: bpCorrelation)
        // 4
        let beatsCountUnit = HKUnit.count()
        let heartRateQuantity = HKQuantity(unit: beatsCountUnit.unitDivided(by: HKUnit.minute()), doubleValue: Double(heartRate))
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let heartRateSample = HKQuantitySample(type: heartRateType, quantity: heartRateQuantity, start: startDate, end: endDate)
        // 5
        healthKitStore.save([bloodPressureSample, heartRateSample]) { (success: Bool, error: Error?) in
            completion(success, error)
        }
    }
}
