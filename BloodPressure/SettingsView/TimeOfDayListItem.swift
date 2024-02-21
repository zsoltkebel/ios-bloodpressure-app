//
//  TimeOfDayListItem.swift
//  BloodPressure
//
//  Created by Zsolt Kébel on 18/02/2024.
//

import SwiftUI

struct TimeOfDayListItem: View {
    var timeOfDay: PartOfDay
    
    var body: some View {
        NavigationLink(value: timeOfDay) {
            HStack {
                Text(timeOfDay.name)
                Spacer()
                if timeOfDay.isTracked {
                    Text(timeOfDay.notificationDate, style: .time)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Off")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

#Preview {
    List {
        TimeOfDayListItem(timeOfDay: PartOfDay.morning)
    }
    .modelContainer(PreviewSampleData.container)
}
