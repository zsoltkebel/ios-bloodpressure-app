//
//  TodayValues.swift
//  BloodPressure
//
//  Created by Zsolt Kébel on 24/02/2024.
//

import Foundation
import HealthKit
import Combine

class Brain: ObservableObject {
    
    static var shared = Brain()
    
    @Published var readingsToday: [HKCorrelation] = []
    @Published var heartRateSamples: [HKQuantitySample] = []

    @Published var readings: [Reading] = []
    
    var dates: [Date] {
        var dates = readingsToday.map { $0.startDate }
        let otherDates = heartRateSamples.filter({ !dates.contains($0.startDate) }).map { $0.startDate }
        dates.append(contentsOf: otherDates)
        return dates
    }
    
    // Start by reading all matching data.
    var anchorBP: HKQueryAnchor? = nil
    var anchorHR: HKQueryAnchor? = nil

    var store = HKHealthStore()
    
    // Tasks for updating blood pressure and heart rate readings as they come in
    var updateBloodPressureTask: Cancellable?
    var updateHeartRateTask: Cancellable?

    init() {
        initBloodPressureQuery()
        initHeartRateQuery()
    }
    
    deinit {
        updateBloodPressureTask?.cancel()
        updateHeartRateTask?.cancel()
    }
    
    func reading(at date: Date) -> Reading {
        let bloodPressureCorrelation = readingsToday.first(where: { $0.startDate == date })
        let heartRateQuantitySample = heartRateSamples.first(where: { $0.startDate == date })

        var systolic = 0.0
        var diastolic = 0.0
        if let sys = bloodPressureCorrelation?.objects(for: HKQuantityType(.bloodPressureSystolic)).first as? HKQuantitySample,
           let dia = bloodPressureCorrelation?.objects(for: HKQuantityType(.bloodPressureDiastolic)).first as? HKQuantitySample {
            
            systolic = sys.quantity.doubleValue(for: HKUnit.millimeterOfMercury())
            diastolic = dia.quantity.doubleValue(for: HKUnit.millimeterOfMercury())
        }
        
        let heartRate = heartRateQuantitySample?.quantity.doubleValue(for: .count().unitDivided(by: .minute())) ?? 0.0
        
        return Reading(sys: systolic, dia: diastolic, heartRate: heartRate, date: date)
    }
    
    func dates(in range: ClosedRange<Date>) -> [Date] {
        return dates.filter({ range.contains($0) })
    }
    
    func measurementDate(for date: Date) -> Date? {
        let datesNearTime = dates.filter({ abs($0.timeIntervalSince1970 - date.timeIntervalSince1970) < 1 * 60 * 60})
        let m = datesNearTime.min { lhs, rhs in
            return abs(lhs.timeIntervalSince(date)) < abs(rhs.timeIntervalSince(date))
        }
        return m
    }
    
    func initBloodPressureQuery() {
        let type = HKCorrelationType(.bloodPressure)
        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: Date()), end: Calendar.current.date(bySettingHour: 24, minute: 0, second: 0, of: Date()))
        
        // Create a query descriptor.
        let anchorDescriptor =
        HKAnchoredObjectQueryDescriptor(
            predicates: [.correlation(type: type, predicate: predicate)],
            anchor: anchorBP
        )

        let updateQueue = anchorDescriptor.results(for: store)

        let updateTask = Task {
            for try await update in updateQueue {
                // Process the update here.
                await start(update: update)
            }
        }
    }
    
    func initHeartRateQuery() {
        let heartRateType = HKQuantityType(.heartRate)
        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: Date()), end: Calendar.current.date(bySettingHour: 24, minute: 0, second: 0, of: Date()))
        
        // Create a query descriptor.
        let anchorDescriptor =
        HKAnchoredObjectQueryDescriptor(
            predicates: [.quantitySample(type: heartRateType, predicate: predicate)],
            anchor: anchorHR
        )

        let updateQueue = anchorDescriptor.results(for: store)

        let updateTask = Task {
            for try await update in updateQueue {
                // Process the update here.
                await updateHeartRateSamples(update: update)
            }
        }
    }
    
    @MainActor
    func start(update: HKAnchoredObjectQueryDescriptor<HKCorrelation>.Result) {
        readingsToday.append(contentsOf: update.addedSamples)
        update.deletedObjects.forEach { deletedObject in
            readingsToday.removeAll(where: { $0.uuid == deletedObject.uuid })
        }
        print("Updated list: (\(readingsToday.count))")
        print(readingsToday)
    }
    
    @MainActor
    func updateHeartRateSamples(update: HKAnchoredObjectQueryDescriptor<HKQuantitySample>.Result) {
//        for sample in update.addedSamples {
//            if let matchingReading = readings.first(where: { $0.date == sample.startDate }) {
//                if let sample = sample as? HKQuantitySample {
//                    matchingReading.heartRate = sample.quantity.doubleValue(for: .count().unitDivided(by: .minute()))
//                }
//            } else {
//                
//            }
//        }
//        
        heartRateSamples.append(contentsOf: update.addedSamples)
        update.deletedObjects.forEach { deletedObject in
            heartRateSamples.removeAll(where: { $0.uuid == deletedObject.uuid })
        }
        print("Updated list: (\(heartRateSamples.count))")
        print(heartRateSamples)
    }
}
