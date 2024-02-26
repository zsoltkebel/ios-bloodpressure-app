//
//  ContentView.swift
//  blood_pressure
//
//  Created by Zsolt Kébel on 25/01/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var showingSheet = false
    
    var body: some View {
        NavigationStack {
            DaySummaryView()
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
    }
}

#Preview {
    ContentView()
        .modelContainer(PreviewSampleData.container)
}
