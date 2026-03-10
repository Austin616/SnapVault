//
//  ContentView.swift
//  SnapVault
//
//  Created by Austin Tran on 3/10/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        PresetsView()
    }
}

#Preview {
    ContentView()
        .environmentObject(PresetStore())
}
