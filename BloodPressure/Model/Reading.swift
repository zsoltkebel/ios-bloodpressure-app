//
//  HistoryView.swift
//  BloodPressure
//
//  Created by Zsolt Kébel on 11/02/2024.
//
import Foundation

class Reading: Identifiable, Hashable {
    static func == (lhs: Reading, rhs: Reading) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(sys)
        hasher.combine(dia)
        hasher.combine(heartRate)
        hasher.combine(date)
    }
    
    var sys: Double
    var dia: Double
    var heartRate: Double
    var date: Date
    
    var id: Double { return date.timeIntervalSince1970 }
    
    init(sys: Double, dia: Double, heartRate: Double, date: Date) {
        self.sys = sys
        self.dia = dia
        self.heartRate = heartRate
        self.date = date
    }
    
    static var examples = [
        Reading(sys: 120, dia: 80, heartRate: 76, date: Calendar.current.date(bySettingHour: 8, minute: 34, second: 0, of: Date())!),
        Reading(sys: 120, dia: 80, heartRate: 76, date: Calendar.current.date(bySettingHour: 14, minute: 21, second: 0, of: Date())!),
        Reading(sys: 120, dia: 80, heartRate: 76, date: Calendar.current.date(bySettingHour: 20, minute: 15, second: 0, of: Date())!)
    ]
}
