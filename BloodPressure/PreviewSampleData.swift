//
//  PreviewSampleData.swift
//  BloodPressure
//
//  Created by Zsolt Kébel on 18/02/2024.
//

import SwiftData

actor PreviewSampleData {
    
    @MainActor
    static var container: ModelContainer = {
        return try! inMemoryContainer()
    }()
    
    static var inMemoryContainer: () throws -> ModelContainer = {
        let schema = Schema([PartOfDay.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [configuration])
        let sampleData: [any PersistentModel] = [
            PartOfDay.morning,
            PartOfDay.afternoon,
            PartOfDay.evening
        ]
        Task { @MainActor in
            sampleData.forEach {
                container.mainContext.insert($0)
            }
        }
        return container
    }
}
