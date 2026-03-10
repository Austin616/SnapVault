//
//  HotkeyManager.swift
//  SnapVault
//

import Carbon.HIToolbox
import Foundation

final class HotkeyManager {
    var onPresetTriggered: ((UUID) -> Void)?

    private let signature: OSType = 0x53564C54 // "SVLT"

    private var handlerRef: EventHandlerRef?
    private var nextHotKeyID: UInt32 = 1
    private var hotKeyRefs: [UUID: EventHotKeyRef] = [:]
    private var hotKeyIDToPresetID: [UInt32: UUID] = [:]

    init() {
        installHandler()
    }

    deinit {
        unregisterAll()
        if let handlerRef {
            RemoveEventHandler(handlerRef)
        }
    }

    func register(presets: [ScreenshotPreset]) {
        unregisterAll()

        for preset in presets where preset.isEnabled {
            registerHotKey(for: preset)
        }
    }

    func unregisterAll() {
        hotKeyRefs.values.forEach { hotKeyRef in
            UnregisterEventHotKey(hotKeyRef)
        }

        hotKeyRefs.removeAll()
        hotKeyIDToPresetID.removeAll()
    }

    private func installHandler() {
        var eventSpec = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let selfPointer = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        let callback: EventHandlerUPP = { _, eventRef, userData in
            guard let userData, let eventRef else { return noErr }
            let manager = Unmanaged<HotkeyManager>.fromOpaque(userData).takeUnretainedValue()
            return manager.handleHotKeyEvent(eventRef)
        }

        InstallEventHandler(
            GetEventDispatcherTarget(),
            callback,
            1,
            &eventSpec,
            selfPointer,
            &handlerRef
        )
    }

    private func registerHotKey(for preset: ScreenshotPreset) {
        var hotKeyRef: EventHotKeyRef?
        let hotKeyIDValue = nextHotKeyID
        nextHotKeyID += 1

        var hotKeyID = EventHotKeyID(signature: signature, id: hotKeyIDValue)

        let status = RegisterEventHotKey(
            preset.shortcut.keyCode,
            preset.shortcut.modifiers,
            hotKeyID,
            GetEventDispatcherTarget(),
            0,
            &hotKeyRef
        )

        guard status == noErr, let hotKeyRef else {
            NSLog("Failed to register hotkey for preset %@", preset.name)
            return
        }

        hotKeyRefs[preset.id] = hotKeyRef
        hotKeyIDToPresetID[hotKeyIDValue] = preset.id
    }

    private func handleHotKeyEvent(_ eventRef: EventRef) -> OSStatus {
        var hotKeyID = EventHotKeyID()
        let result = GetEventParameter(
            eventRef,
            EventParamName(kEventParamDirectObject),
            EventParamType(typeEventHotKeyID),
            nil,
            MemoryLayout<EventHotKeyID>.size,
            nil,
            &hotKeyID
        )

        guard result == noErr, let presetID = hotKeyIDToPresetID[hotKeyID.id] else {
            return noErr
        }

        DispatchQueue.main.async { [weak self] in
            self?.onPresetTriggered?(presetID)
        }

        return noErr
    }
}

