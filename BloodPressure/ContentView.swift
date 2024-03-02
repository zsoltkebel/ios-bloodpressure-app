//
//  ContentView.swift
//  blood_pressure
//
//  Created by Zsolt Kébel on 25/01/2024.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    
    @State private var today: Date = .now
    @State private var showingSheet = false
    
    var body: some View {
        NavigationStack {
            DaySummaryView(day: today)
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem {
                        Menu("Menu", systemImage: "ellipsis.circle") {
                            Button("Edit Times", systemImage: "pencil") {
                                showingSheet.toggle()
                            }
                        }
                    }
                }
                .sheet(isPresented: $showingSheet) {
                    SettingsView()
                        .presentationDetents([.medium, .large])
                }
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                today = .now.minutePrecision()!
                print("Updating today to \(today)")
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(PreviewSampleData.container)
}
