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
    HistoryView(readings: [Reading(sys: 120, dia: 80, heartRate: 70, date: Date()), Reading(sys: 120, dia: 80, heartRate: 70, date: Date())])
}

struct ReadingListItem: View {
    let date = Date()
    let reading: Reading
    
    @State private var isOn = true
    @State private var isOn2 = true

    
    var body: some View {
        Section(content: {
            HStack {
                Text("Morning")
                Spacer()
                Image(systemName: "checkmark.circle.fill")
            }
            HStack {
                Text("Evening")
                Spacer()
                Image(systemName: "plus.circle")
            }
            HStack {
                Image(systemName: "sunrise")
                Image(systemName: "sun.max")
                Image(systemName: "moonset")
            }
            HStack {
                Toggle(isOn: $isOn) {
                    if isOn {
                        VStack {
                            Label("Morning", systemImage: "sunrise")
                                .labelStyle(.iconOnly)
                            Label("Morning", systemImage: "checkmark")
                                .labelStyle(.titleOnly)
                        }
                    } else {
                        Text("Morning")
                    }
                }
                .toggleStyle(.button)
                Toggle(isOn: $isOn2) {
                    if isOn2 {
                        VStack {
                            Label("Morning", systemImage: "sun.max")
                                .labelStyle(.iconOnly)
                            Label("Afternoon", systemImage: "checkmark")
                                .labelStyle(.titleOnly)
                        }
                    } else {
                        Text("Morning")
                    }
                }
                .toggleStyle(.button)
//                Toggle("Afternoon", isOn: $isOn)
//                    .toggleStyle(.button)
//                    .buttonStyle(.borderedProminent)
//                Spacer()
//                Button(action: {
//                    
//                }, label: {
//                    Text("Evening")
//                })
            }
//            HStack {
//                VStack(alignment: .trailing, content: {
//                    Text(String(format: "%.f", reading.sys))
//                        .bold()
//                    Text(String(format: "%.f", reading.dia))
//                        .bold()
//                        .foregroundStyle(.secondary)
//                })
//                Spacer()
//                Text(reading.date, style: .date)
//                Text(reading.date, style: .time)
//            }
        }, header: {
            Text("Today")
                .font(.subheadline)
        })
    }
}
