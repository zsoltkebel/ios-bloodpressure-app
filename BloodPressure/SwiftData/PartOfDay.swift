//
//  TimeItem.swift
//  BloodPressure
//
//  Created by Zsolt Kébel on 17/02/2024.
//

import SwiftData
import NotificationCenter


@Model
final class PartOfDay {
    @Attribute(.unique)
    let name: String
    let startDate: Date
    let endDate: Date
    var isTracked: Bool
    @Attribute(.unique)
    var notificationIdentifier: String?
    var notificationDate: Date
        
//    var isNotificationEnabled: Bool { return notificationIdentifier != nil }
    
    init(name: String, startDate: Date, endDate: Date, isTracked: Bool, notificationIdentifier: String? = nil) {
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.isTracked = isTracked
        self.notificationIdentifier = notificationIdentifier
        
        let minuteDiff = Calendar.current.dateComponents([.minute], from: startDate, to: endDate)
        self.notificationDate = Calendar.current.date(byAdding: DateComponents(minute: minuteDiff.minute! / 2), to: startDate)!
    }
}

extension PartOfDay {
    func updateNotification(completion: ((UNNotificationRequest, Error?) -> Void)? = nil) {
        self.removePendingNotification()
        self.addNotification(completion: completion)
    }
    
    func addNotification(completion: ((UNNotificationRequest, Error?) -> Void)? = nil) {
        let content = UNMutableNotificationContent()
        content.title = "\(self.name) Reminder"
        content.body = "It's time to measure your blood pressure."
        content.sound = UNNotificationSound.default
        
        // show this notification five seconds from now
        let trigger = UNCalendarNotificationTrigger(dateMatching: self.notificationDate.hourAndMinute(), repeats: true)
        
        // choose a random identifier
        let id = UUID().uuidString
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        // add our notification request
        UNUserNotificationCenter.current().add(request) { error in
            if error == nil {
                print("Added notification for \(self.name) at \(self.notificationDate.hourAndMinute())")
                self.notificationIdentifier = id
            }
            completion?(request, error)
        }
    }
    
    func removePendingNotification() {
        if let notificationIdentifier = self.notificationIdentifier {
            print("Removed notification for \(self.name) with ID \(String(describing: self.notificationIdentifier))")
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
            self.notificationIdentifier = nil
        }
    }
}

extension PartOfDay {
    var range: ClosedRange<Date> { self.startDate...self.endDate }
    
    var notificationTimeComponents: DateComponents { Calendar.current.dateComponents([.hour, .minute], from: self.notificationDate)}
    
    var isNotificationEnabled: Bool { self.notificationIdentifier != nil }
    
    var date: Date {
        let minuteDiff = Calendar.current.dateComponents([.minute], from: startDate, to: endDate)
        return Calendar.current.date(byAdding: DateComponents(minute: minuteDiff.minute! / 2), to: startDate)!
    }
}

extension PartOfDay {
    static var morning: PartOfDay {
        PartOfDay(name: "Morning", startDate: Date.time(0, 00), endDate: Date.time(12, 00), isTracked: false)
    }
    
    static var afternoon: PartOfDay {
        PartOfDay(name: "Afternoon", startDate: Date.time(12, 00), endDate: Date.time(17, 00), isTracked: false)
    }
    
    static var evening: PartOfDay {
        PartOfDay(name: "Evening", startDate: Date.time(17, 00), endDate: Date.time(24, 00), isTracked: false)
    }
    
    static var defaults: [PartOfDay] = [.morning, .afternoon, .evening]
}





extension Date {
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
}

extension Calendar {
    static func date(from minutesSinceMidnight: Int) -> Date? {
        let hour = minutesSinceMidnight / 60
        let minute = minutesSinceMidnight % 60
        return self.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date())
    }
}

extension Date {
//    func timeOfDay() -> TimeOfDay {
//        let secondsSinceMidnight = Calendar.current.datecom
//    }
}
