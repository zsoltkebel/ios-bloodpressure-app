//
//  ContentView.swift
//  blood_pressure
//
//  Created by Zsolt Kébel on 25/01/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var showingSheet = false
    
    var body2: some View {
        RemindersView()
    }
    var body: some View {
        NavigationStack {
            AddData()
                .toolbar {
                    ToolbarItem {
                        Menu("Menu", systemImage: "ellipsis.circle") {
                            Button("Reminders", systemImage: "clock") {
                                showingSheet.toggle()
                            }
                        }
                    }
                }
                .sheet(isPresented: $showingSheet) {
                    NavigationStack {
                        RemindersView()
                    }
                }
        }
    }
}

#Preview {
    ContentView()
}
