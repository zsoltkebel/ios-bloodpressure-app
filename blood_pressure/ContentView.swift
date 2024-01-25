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
    @State private var date = Date()
    @State private var systolic: Int?
    @State private var diastolic: Int?
    @State private var heartRate: Int?
    
    @State private var healthKitAccessError: Bool = false
    
    private var hman = HealthKitManager()
    
    @State private var showNowButton = false
    
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
                        if showNowButton || !Calendar.current.isDate(date, equalTo: Date(), toGranularity: .minute) {
                            Button {
                                date = Date()
                                showNowButton = false
                                refreshNowButtonNextMinute()
                            } label: {
                                Text("Now")
                            }
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
                        save()
                    } label: {
                        Label("Add to Health", systemImage: "plus").frame(maxWidth: .infinity, maxHeight: 36)
                    }
                    
                    .disabled(systolic == nil || diastolic == nil || heartRate == nil).labelStyle(.titleAndIcon).buttonStyle(.borderedProminent).padding()
                    .alert(
                        "Failed to save data to Health",
                        isPresented: $healthKitAccessError
                    ) {
                        Button("OK") {
                            // Handle the acknowledgement.
                            healthKitAccessError = false
                        }
                    } message: {
                        Text("Error while accessing Health data.")
                    }
                }
            }.navigationTitle("Add Data")
                .onAppear(perform: {
                    refreshNowButtonNextMinute()
                })
        }
    }
    
    func refreshNowButtonNextMinute() {
        let nextMinute = DispatchTime.now() + 60 - Double(Calendar.current.component(.second, from: Date()))
        DispatchQueue.main.asyncAfter(deadline: nextMinute) {
            showNowButton = true
        }
    }
    
    func wid(text: String, value: Binding<Int>) -> any View {
        return HStack {
            Text(text)
            TextField("input", value: value, format: .number).keyboardType(.numberPad).multilineTextAlignment(.trailing)
        }
    }
    
    func save() {
        if HKHealthStore.isHealthDataAvailable() {
            // Add code to use HealthKit here.
            hman.authorizationRequestHealthKit { available, error in
                hman.saveBloodPressureMeasurement(date: date, systolic: systolic!, diastolic: diastolic!, heartRate: heartRate!) { comp, error in
                    healthKitAccessError = error != nil
                    if error == nil {
                        systolic = nil
                        diastolic = nil
                        heartRate = nil
                    }
                }
            }
        } else {
            healthKitAccessError = true
            print("wrong")
        }
    }
    
}

#Preview {
    ContentView()
}

class HealthKitManager {
    fileprivate let healthKitStore = HKHealthStore()
    func authorizationRequestHealthKit(completion: @escaping (Bool, Error?) -> Void) {
        // 1
        if !HKHealthStore.isHealthDataAvailable() {
            let error = NSError(domain: "com.chariotsolutions.mobile", code: 999,
                                userInfo: [NSLocalizedDescriptionKey : "Healthkit not available on this device"])
            completion(false, error)
            print("HealthKit not available on this device")
            return
        }
        // 2
        let readTypes: Set<HKSampleType> = [HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodPressureDiastolic)!,
                                            HKSampleType.quantityType(forIdentifier: .bloodPressureSystolic)!,
                                            HKSampleType.quantityType(forIdentifier: .heartRate)!]
        let writeTypes: Set<HKSampleType> = [HKSampleType.quantityType(forIdentifier: .bloodPressureDiastolic)!,
                                             HKSampleType.quantityType(forIdentifier: .bloodPressureSystolic)!,
                                             HKSampleType.quantityType(forIdentifier: .heartRate)!]
        // 3
        healthKitStore.requestAuthorization(toShare: writeTypes, read: readTypes) { (success: Bool, error: Error?) in
            completion(success, error)
        }
        print("here")
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
