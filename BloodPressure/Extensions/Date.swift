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
}
