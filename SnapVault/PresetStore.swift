//
//  PresetStore.swift
//  SnapVault
//

import Combine
import Foundation

@MainActor
final class PresetStore: ObservableObject {
    @Published private(set) var presets: [ScreenshotPreset] = []

    private let fileManager: FileManager
    private let storageURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(
        fileManager: FileManager = .default,
        storageURL: URL? = nil
    ) {
        self.fileManager = fileManager
        self.storageURL = storageURL ?? Self.defaultStorageURL(fileManager: fileManager)
        loadPresets()
    }

    func addPreset(_ preset: ScreenshotPreset) {
        presets.append(preset)
        savePresets()
    }

    func updatePreset(_ preset: ScreenshotPreset) {
        guard let index = presets.firstIndex(where: { $0.id == preset.id }) else {
            return
        }

        presets[index] = preset
        savePresets()
    }

    func deletePresets(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            presets.remove(at: index)
        }
        savePresets()
    }

    func deletePreset(id: UUID) {
        presets.removeAll { $0.id == id }
        savePresets()
    }

    func replacePresets(_ presets: [ScreenshotPreset]) {
        self.presets = presets
        savePresets()
    }

    private func loadPresets() {
        guard fileManager.fileExists(atPath: storageURL.path) else {
            presets = []
            return
        }

        do {
            let data = try Data(contentsOf: storageURL)
            presets = try decoder.decode([ScreenshotPreset].self, from: data)
        } catch {
            presets = []
        }
    }

    private func savePresets() {
        do {
            let directoryURL = storageURL.deletingLastPathComponent()
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            let data = try encoder.encode(presets)
            try data.write(to: storageURL, options: .atomic)
        } catch {
            assertionFailure("Failed to persist presets: \(error)")
        }
    }

    private static func defaultStorageURL(fileManager: FileManager) -> URL {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return appSupport
            .appendingPathComponent("SnapVault", isDirectory: true)
            .appendingPathComponent("presets.json", isDirectory: false)
    }
}
