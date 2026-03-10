//
//  SnapVaultApp.swift
//  SnapVault
//
//  Created by Austin Tran on 3/10/26.
//

import SwiftUI

@main
struct SnapVaultApp: App {
    @StateObject private var presetStore: PresetStore
    private let hotkeyCoordinator: HotkeyCoordinator

    @MainActor
    init() {
        let store = PresetStore()
        _presetStore = StateObject(wrappedValue: store)
        hotkeyCoordinator = HotkeyCoordinator(presetStore: store)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(presetStore)
                .frame(minWidth: 700, minHeight: 460)
                .onAppear {
                    _ = hotkeyCoordinator
                }
        }

        Settings {
            PresetsView()
                .environmentObject(presetStore)
                .frame(width: 700, height: 460)
                .onAppear {
                    _ = hotkeyCoordinator
                }
        }
    }
}
