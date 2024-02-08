//
//  HealthKitManager.swift
//  blood_pressure
//
//  Created by Zsolt Kébel on 08/02/2024.
//

import Foundation
import HealthKit

class HealthKitManager {
    fileprivate let healthKitStore = HKHealthStore()
    
    private let systolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic)!
    private let diastolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic)!
    private let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    
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
