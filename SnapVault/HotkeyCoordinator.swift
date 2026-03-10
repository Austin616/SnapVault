//
//  HotkeyCoordinator.swift
//  SnapVault
//

import Combine
import Foundation

@MainActor
final class HotkeyCoordinator: ObservableObject {
    private let presetStore: PresetStore
    private let hotkeyManager: HotkeyManager
    private var cancellables: Set<AnyCancellable> = []

    init(
        presetStore: PresetStore,
        hotkeyManager: HotkeyManager = HotkeyManager()
    ) {
        self.presetStore = presetStore
        self.hotkeyManager = hotkeyManager

        bindHotkeys()
    }

    private func bindHotkeys() {
        hotkeyManager.onPresetTriggered = { [weak self] presetID in
            self?.handlePresetTrigger(presetID)
        }

        presetStore.$presets
            .sink { [weak self] presets in
                self?.hotkeyManager.register(presets: presets)
            }
            .store(in: &cancellables)

        hotkeyManager.register(presets: presetStore.presets)
    }

    private func handlePresetTrigger(_ presetID: UUID) {
        guard let preset = presetStore.presets.first(where: { $0.id == presetID }) else {
            return
        }

        // Capture is wired in Phase 4. This confirms hotkey routing works.
        NSLog("Hotkey triggered preset: %@", preset.name)
    }
}

