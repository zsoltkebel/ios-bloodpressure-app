//
//  HistoryView.swift
//  BloodPressure
//
//  Created by Zsolt Kébel on 11/02/2024.
//

import SwiftUI
import HealthKit

struct Reading: Identifiable {
    var sys: Double
    var dia: Double
    var heartRate: Double
    var date: Date
    
    var id: Double { return date.timeIntervalSince1970 }
}

struct HistoryView: View {
    @State var readings: [Reading] = []
    
    let m = HealthKitManager()
    var body: some View {
        List(readings) { reading in
            ReadingListItem(reading: reading)
        }.task {
            m.authorizationRequestHealthKit { authorized, error in
                m.readSampleByBloodPressure { readings in
                    print(readings)
                    DispatchQueue.main.async {
//                        self.readings = readings
                    }
                }
            }
        }
    }
}

#Preview {
    HistoryView(readings: [Reading(sys: 120, dia: 80, heartRate: 70, date: Date())])
}

struct ReadingListItem: View {
    let reading: Reading
    
    var body: some View {
        HStack {
            VStack(alignment: .trailing, content: {
                Text(String(format: "%.f", reading.sys))
                    .bold()
                Text(String(format: "%.f", reading.dia))
                    .bold()
                    .foregroundStyle(.secondary)
            })
            Spacer()
            Text(reading.date, style: .date)
            Text(reading.date, style: .time)
        }
    }
}
