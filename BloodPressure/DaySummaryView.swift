//
//  DaySUmmary.swift
//  BloodPressure
//
//  Created by Zsolt Kébel on 24/02/2024.
//

import SwiftUI
import SwiftData
import Combine

struct DaySummaryView: View {
    
    var day: Date = .now
    
    @Query(sort: \PartOfDay.preferredTime) var times: [PartOfDay]

    @ObservedObject private var brain = Brain.shared
    
    @State private var showingAddSheet = false

    var body: some View {
        NavigationStack {
            List {
                Section("Summary") {
                    ForEach(times, id: \.self) { dayPart in
                        if let measurementDate = brain.measurementDate(for: dayPart.preferredTime.sameTime(on: day)!) {
                            NavigationLink {
                                Form {
                                    ReadingListItem(reading: brain.reading(at: measurementDate))
                                }
//                                PartOfDaySummary(value: brain.getReading(for: measurementDate))
                                    .navigationTitle(dayPart.name)
                            } label: {
                                Label("\(dayPart.name)", systemImage: "checkmark.circle.fill")
                            }
                        } else {
                            Label("\(dayPart.name)", systemImage: "circle.dotted")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
//                Section("All Readings") {
//                    ForEach(brain.dates, id: \.timeIntervalSince1970) { date in
//                        ReadingListItem(reading: brain.reading(at: date))
//                    }
//                }
            }
            .navigationTitle(day.relativeDateString())
            .toolbar(content: {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Button(action: {
                            showingAddSheet.toggle()
                        }, label: {
                            Image(systemName: "plus.circle.fill")
                                .imageScale(.large)
                            Text("Add Data")
                        })
                        .bold()
                        .sheet(isPresented: $showingAddSheet, content: {
                            AddData()
                        })
                        Spacer()
                    }
                }
            })
        }
    }
}

#Preview {
    ModelContainerPreview(PreviewSampleData.inMemoryContainer) {
        DaySummaryView(day: .init(timeIntervalSinceNow: -3 * 24 * 60 * 60))
    }
}

struct PartOfDaySummary: View {
    var value: Reading
    
    var body: some View {
        Form {
            Text(value.date, style: .date)
            Text(value.date, style: .time)
            Text("\(value.sys)")
            Text("\(value.dia)")
            Text("\(value.heartRate)")
        }
    }
}
