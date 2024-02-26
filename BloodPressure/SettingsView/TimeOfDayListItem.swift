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
                Text(timeOfDay.preferredTime, style: .time)
                    .foregroundStyle(.secondary)
                Image(systemName: timeOfDay.isNotificationEnabled ? "bell" : "bell.slash")
                    .imageScale(.small)
                    .foregroundStyle(.secondary)
                    .padding([.horizontal], 4)
            }
        }
    }
}

#Preview {
    ModelContainerPreview(PreviewSampleData.inMemoryContainer) {
        List {
            TimeOfDayListItem(timeOfDay: PartOfDay.morning)
        }
    }
}
