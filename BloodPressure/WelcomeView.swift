//
//  WelcomeView.swift
//  BloodPressure
//
//  Created by Zsolt Kébel on 23/02/2024.
//

import SwiftUI

struct WelcomeView: View {
    
    @State private var showingAddSheet = true
    
    var body: some View {
        NavigationStack {
            Button {
                self.showingAddSheet.toggle()
            } label: {
                Text("Add Data")
                    .padding()
            }
            .buttonStyle(.bordered)
        }.sheet(isPresented: $showingAddSheet, content: {
            AddData()
        })
    }
}

#Preview {
    WelcomeView()
}
