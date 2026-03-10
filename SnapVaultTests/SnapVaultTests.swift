//
//  SnapVaultTests.swift
//  SnapVaultTests
//
//  Created by Austin Tran on 3/10/26.
//

import Testing
@testable import SnapVault
import Foundation

struct SnapVaultTests {

    @Test
    func presetCodableRoundTrip() throws {
        let original = ScreenshotPreset(
            id: UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE")!,
            name: "School",
            folderPath: "~/Pictures/Screenshots/School",
            shortcut: ShortcutDefinition(keyCode: 18, modifiers: 1179648, display: "Cmd+Shift+1"),
            type: .fullScreen,
            isEnabled: true
        )

        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ScreenshotPreset.self, from: encoded)

        #expect(decoded == original)
    }

    @Test
    @MainActor
    func presetStorePersistsAndLoads() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("SnapVaultTests-\(UUID().uuidString)", isDirectory: true)
        let storageURL = tempDir.appendingPathComponent("presets.json", isDirectory: false)

        let firstStore = PresetStore(storageURL: storageURL)
        #expect(firstStore.presets.isEmpty)

        let preset = ScreenshotPreset(
            name: "Receipts",
            folderPath: "~/Pictures/Screenshots/Receipts",
            shortcut: ShortcutDefinition(keyCode: 19, modifiers: 1179648, display: "Cmd+Shift+2"),
            type: .selectedArea
        )

        firstStore.addPreset(preset)
        #expect(FileManager.default.fileExists(atPath: storageURL.path))

        let secondStore = PresetStore(storageURL: storageURL)
        #expect(secondStore.presets.count == 1)
        #expect(secondStore.presets[0] == preset)

        try? FileManager.default.removeItem(at: tempDir)
    }

}
