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
    var name: String
    var preferredTime: Date // Only used for time
    @Attribute(.unique)
    var notificationIdentifier: String?
    var notificationBody: String // To customise notification
        
//    var isNotificationEnabled: Bool { return notificationIdentifier != nil }
    
    init() {
        self.name = ""
        self.preferredTime = Date.time(8, 00)
        self.notificationIdentifier = nil
        self.notificationBody = ""
    }
    
    init(name: String, preferredTime: Date, notificationIdentifier: String? = nil, notificationBody: String? = nil) {
        self.name = name
        self.preferredTime = preferredTime
        self.notificationIdentifier = notificationIdentifier
        self.notificationBody = notificationBody ?? ""
        
//        let minuteDiff = Calendar.current.dateComponents([.minute], from: startDate, to: endDate)
//        self.notificationDate = Calendar.current.date(byAdding: DateComponents(minute: minuteDiff.minute! / 2), to: startDate)!
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
        let trigger = UNCalendarNotificationTrigger(dateMatching: self.preferredTime.hourAndMinute(), repeats: true)
        
        // choose a random identifier
        let id = UUID().uuidString
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        // add our notification request
        UNUserNotificationCenter.current().add(request) { error in
            if error == nil {
                print("Added notification for \(self.name) at \(self.preferredTime.hourAndMinute())")
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
    
    func range(on day: Date = .distantPast) -> ClosedRange<Date> {
        let cal = Calendar.current
        let components = cal.dateComponents([.hour, .minute, .second], from: self.preferredTime)
        let timeOnDay = cal.date(bySettingHour: components.hour!, minute: components.minute!, second: components.second!, of: day)!
        let start = cal.date(byAdding: .hour, value: -1, to: timeOnDay)!
        let end = cal.date(byAdding: .hour, value: 1, to: timeOnDay)!
        return start...end
    }
    
//    var notificationTimeComponents: DateComponents { Calendar.current.dateComponents([.hour, .minute], from: self.notificationDate)}
    
    var isNotificationEnabled: Bool { self.notificationIdentifier != nil }
    
//    var date: Date {
//        let minuteDiff = Calendar.current.dateComponents([.minute], from: startDate, to: endDate)
//        return Calendar.current.date(byAdding: DateComponents(minute: minuteDiff.minute! / 2), to: startDate)!
//    }
}

extension PartOfDay {
    static var morning: PartOfDay {
        PartOfDay(name: "Morning", preferredTime: Date.time(8, 00))
    }
    
    static var afternoon: PartOfDay {
        PartOfDay(name: "Afternoon", preferredTime: Date.time(16, 00))
    }
    
    static var evening: PartOfDay {
        PartOfDay(name: "Evening", preferredTime: Date.time(20, 00))
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
