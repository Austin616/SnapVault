//
//  SnapVaultApp.swift
//  SnapVault
//
//  Created by Austin Tran on 3/10/26.
//

import SwiftUI

@main
struct SnapVaultApp: App {
    @StateObject private var presetStore = PresetStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(presetStore)
                .frame(minWidth: 700, minHeight: 460)
        }

        Settings {
            PresetsView()
                .environmentObject(presetStore)
                .frame(width: 700, height: 460)
        }
    }
}
