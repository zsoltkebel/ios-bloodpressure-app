//
//  TimeItemContainer.swift
//  BloodPressure
//
//  Created by Zsolt Kébel on 17/02/2024.
//

import SwiftData

actor TimeItemContainer {

    @MainActor
    static func create(shouldCreateDefaults: inout Bool) -> ModelContainer {
        let schema = Schema([PartOfDay.self])
        let configuration = ModelConfiguration()
        let container = try! ModelContainer(for: schema, configurations: [configuration])
        if shouldCreateDefaults {
            PartOfDay.defaults.forEach { container.mainContext.insert($0) }
            shouldCreateDefaults = false
        }
        return container
    }
}
