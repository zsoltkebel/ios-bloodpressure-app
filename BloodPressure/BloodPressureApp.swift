//
//  blood_pressureApp.swift
//  blood_pressure
//
//  Created by Zsolt Kébel on 25/01/2024.
//

import SwiftUI
import SwiftData
import NotificationCenter

@main
struct blood_pressureApp: App {
    
    @AppStorage("isFirstTimeLaunch") private var isFirstTimeLaunch: Bool = true

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(TimeItemContainer.create(shouldCreateDefaults: &isFirstTimeLaunch))
    }
}
