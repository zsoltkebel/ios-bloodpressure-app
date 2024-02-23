//
//  MeasurementTimeSelectorView.swift
//  BloodPressure
//
//  Created by Zsolt Kébel on 22/02/2024.
//

import SwiftUI

enum DateSelection: String {
    case lastAppOpen, custom
}

struct MeasurementTimeSelectorView: View {
    @Environment(\.dismiss) var dismiss

    @Binding var date: Date
    
//    var selectNow: (() -> Void)?
    
    @Binding var dateSelection: DateSelection
    
    var body: some View {
        Form {
            Section {
                DatePicker("Date", selection: $date, displayedComponents: [.date])
                    .datePickerStyle(.graphical)
                    .onChange(of: date) {
                        dateSelection = .custom
                    }
                
                
            } header: {
                Text("Date")
            }
            Section {
                DatePicker("Time", selection: $date, displayedComponents: [.hourAndMinute])
                    .datePickerStyle(.wheel)
            } header: {
                Text("Time")
            }
            Section {
                if dateSelection == .custom {
                    Button("Select Current Time") {
                        // Set date to now
//                        selectNow?()
////                        date = Date()
                        dateSelection = .lastAppOpen
                        dismiss()
                    }
                }
            }
        }
        .navigationTitle("Date & Time")
        .toolbarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        MeasurementTimeSelectorView(date: .constant(Date()), dateSelection: .constant(.lastAppOpen))
    }
}
