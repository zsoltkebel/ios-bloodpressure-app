//
//  ContentView.swift
//  blood_pressure
//
//  Created by Zsolt Kébel on 25/01/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var showingSheet = false
    @State private var showingNotificationSheet = false
    
    var body: some View {
        NavigationStack {
            //            SetupView()
            //            HistoryView()
//            AddData()
            WelcomeView()
            //            Trackingsetup()
                .toolbar {
                    ToolbarItem {
                        Menu("Menu", systemImage: "ellipsis.circle") {
                            Button("Reminders", systemImage: "bell") {
                                showingSheet.toggle()
                            }
                        }
                    }
                }
                .sheet(isPresented: $showingSheet) {
                    SettingsView()
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(PreviewSampleData.container)
}
