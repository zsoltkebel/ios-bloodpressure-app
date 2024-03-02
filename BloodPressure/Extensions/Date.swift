//
//  Date.swift
//  BloodPressure
//
//  Created by Zsolt Kébel on 02/03/2024.
//

import Foundation

extension Date {
    func minutePrecision() -> Date? {
        Calendar.current.date(bySetting: .second, value: 0, of: self)?.advanced(by: -60)
    }
    
    func relativeString() -> String {
        let relativeDateFormatter = DateFormatter()
        relativeDateFormatter.timeStyle = .short
        relativeDateFormatter.dateStyle = .medium
        relativeDateFormatter.locale = Locale(identifier: "en_GB")
        relativeDateFormatter.doesRelativeDateFormatting = true
        
        return relativeDateFormatter.string(from: self)
    }
    
    func relativeDateString() -> String {
        if Calendar.current.isDateInToday(self) {
            return "Today"
        }
        if Calendar.current.isDateInYesterday(self) {
            return "Yesterday"
        }
        return self.formatted(.dateTime.weekday(.wide).day().month())
    }
    
    static func timeToday(minutesSinceMidnight: Int) -> Date? {
        return Calendar.current.date(from: DateComponents(hour: 10))
    }
    
    func minutesSinceMidnight() -> Int {
        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: self)
        return dateComponents.hour! * 60 + dateComponents.minute!
    }

    static func time(_ hour: Int, _ minute: Int) -> Date {
        return Calendar.current.date(from: DateComponents(hour: hour, minute: minute))!
    }
    
    func hourAndMinute() -> DateComponents {
        return self.components([.hour, .minute])
    }
    
    func components(_ dateComponents: Set<Calendar.Component>) -> DateComponents {
        return Calendar.current.dateComponents(dateComponents, from: self)
    }
    
    /// Same hour and minute on the first date (1st January 1)
    func on1January1() -> Date {
        let hourAndMinute = self.hourAndMinute()
        return Date.time(hourAndMinute.hour!, hourAndMinute.minute!)
    }
    
    func setTime(from timeString: String) -> Date {
        let parts = timeString.split(separator: ":")
        return Calendar.current.date(bySettingHour: Int(parts[0])!, minute: Int(parts[1])!, second: 0, of: self)!
    }
    
    func sameTime(on date: Date = .now) -> Date? {
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: self)
        return Calendar.current.date(bySettingHour: components.hour!, minute: components.minute!, second: components.second!, of: date)
    }
}
