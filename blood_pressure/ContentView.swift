//
//  ContentView.swift
//  blood_pressure
//
//  Created by Zsolt Kébel on 25/01/2024.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    @State private var systolic: Int?
    @State private var diastolic: Int?
    @State private var heartRate: Int?
    
    @State private var healthKitAccessError: Bool = false
    
    private var hman = HealthKitManager()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            TextField("Systolic", value: $systolic, format: .number).keyboardType(.numberPad)
            TextField("Diastolic", value: $diastolic, format: .number).keyboardType(.numberPad)
            TextField("Heart Rate", value: $heartRate, format: .number).keyboardType(.numberPad)
            Button(action: save) {
                Text("Record")
            }.buttonStyle(.borderedProminent)
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
        .padding()
    }
    
    func save() {
        if HKHealthStore.isHealthDataAvailable() {
            // Add code to use HealthKit here.
            hman.authorizationRequestHealthKit { available, error in
                hman.saveBloodPressureMeasurement(systolic: systolic!, diastolic: diastolic!, heartRate: heartRate!) { comp, error in
                    healthKitAccessError = error != nil
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
    
    func saveBloodPressureMeasurement(systolic: Int, diastolic: Int, heartRate: Int, completion: @escaping (Bool, Error?) -> Void) {
        // 1
        let startDate = Date()
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
