//
//  ReadingListItem.swift
//  BloodPressure
//
//  Created by Zsolt Kébel on 24/02/2024.
//

import SwiftUI

struct ReadingListItem: View {
    var reading: Reading
    
    var body: some View {
        Section {
            HStack {
                HStack {
                    VStack(alignment: .leading, content: {
                        Text("SYS")
                            .foregroundStyle(.secondary)
                        Text("DIA")
                            .foregroundStyle(.secondary)
                    })
                    Spacer(minLength: 10)
                    if reading.sys == 0 || reading.dia == 0 {
                        Text("No Data")
                            .fontWeight(.bold)
                    } else {
                        VStack(alignment: .trailing, content: {
                            Text("\(Int(reading.sys))")
                                .fontWeight(.bold)
                            Text("\(Int(reading.dia))")
                                .fontWeight(.bold)
                        })
                    }
                }
                Divider()
                    .padding([.horizontal], 14)
                HStack {
                    Text("Heart\nRate")
                        .foregroundStyle(.secondary)
                    Spacer(minLength: 10)
                    if reading.heartRate == 0 {
                        Text("No Data")
                            .fontWeight(.bold)
                    } else {
                        Text("\(Int(reading.heartRate))")
                            .fontWeight(.bold)
                    }
                }
            }
            .font(.title2)
            .padding(4)
        } header: {
            Text(reading.date, style: .time)
        }
    }
}

#Preview {
    List {
        ReadingListItem(reading: Reading.examples[0])
    }
}
