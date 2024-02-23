//
//  HistoryView.swift
//  BloodPressure
//
//  Created by Zsolt Kébel on 11/02/2024.
//

import SwiftUI
import HealthKit

class Reading: Identifiable {
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
}

struct HistoryView: View {
    @State var readings: [Reading] = []
    
    let m = HealthKitManager()
    
    @State var dict: [Date: [Reading]] = [:]
    @State var showingAddSheet = false
    
    var body: some View {
        List {
            Button("Add Reading") {
                self.showingAddSheet.toggle()
            }
            .padding(.customVertical)
            ForEach(Array(dict.keys).sorted(by: >), id: \.self) { date in
                DaySection(day: date, readings: dict[date] ?? [])
            }
        }
//        List(readings) { reading in
//            ReadingListItem(reading: reading)
//        }
        .task {
            await withCheckedContinuation { continuation in
                m.authorizationRequestHealthKit { authorized, error in
                    m.readSampleByBloodPressure { readings in
                        print(readings)
                        DispatchQueue.main.async {
                            self.readings = readings
                            
                            continuation.resume()
                            
                            print(self.dict)
                        }
                        
                        
                    }
                }
            }
            
            await withCheckedContinuation { continuation in
                m.fetchHeartRateData { samples in
                    self.readings.forEach { reading in
                        reading.heartRate = (samples.first(where: { $0.startDate == reading.date })?.quantity.doubleValue(for: .count().unitDivided(by: .minute()))) ?? 0
                    }
                    continuation.resume()
                }
            }
            
            self.dict = Dictionary(grouping: readings, by: { element in
                Calendar.current.startOfDay(for: element.date)
            })
            
        }
        .sheet(isPresented: $showingAddSheet, content: {
            AddData()
        })
        .navigationTitle("History")
    }
}

#Preview {
    HistoryView(readings: [Reading(sys: 120, dia: 80, heartRate: 70, date: Date()), Reading(sys: 120, dia: 80, heartRate: 70, date: Date())])
}

struct DaySection: View {
    
    var day: Date
    var readings: [Reading]
    
    var body: some View {
        Section {
            ForEach(readings.sorted(by: { $0.date > $1.date })) { reading in
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(Int(reading.sys))/\(Int(reading.dia))")
                        Text("\(Int(reading.heartRate))")
                    }
                    Spacer()
                    Text(reading.date, style: .time)
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text(day.relativeDateString())
        }
    }
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
