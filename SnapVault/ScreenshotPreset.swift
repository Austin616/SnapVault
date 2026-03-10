//
//  ScreenshotPreset.swift
//  SnapVault
//

import Foundation

struct ScreenshotPreset: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var folderPath: String
    var shortcut: ShortcutDefinition
    var type: ScreenshotType
    var isEnabled: Bool

    init(
        id: UUID = UUID(),
        name: String,
        folderPath: String,
        shortcut: ShortcutDefinition,
        type: ScreenshotType,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.name = name
        self.folderPath = folderPath
        self.shortcut = shortcut
        self.type = type
        self.isEnabled = isEnabled
    }
}

struct ShortcutDefinition: Codable, Equatable {
    var keyCode: UInt32
    var modifiers: UInt32
    var display: String
}

enum ScreenshotType: String, Codable, CaseIterable {
    case fullScreen
    case selectedArea
}
