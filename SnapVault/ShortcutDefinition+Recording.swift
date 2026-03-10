//
//  ShortcutDefinition+Recording.swift
//  SnapVault
//

import AppKit
import Carbon.HIToolbox
import Foundation

extension ShortcutDefinition {
    static func from(event: NSEvent) -> ShortcutDefinition? {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        let modifiers = carbonModifiers(from: flags)

        // Require at least one modifier to avoid plain character shortcuts.
        guard modifiers != 0 else { return nil }

        let keyCode = UInt32(event.keyCode)
        return ShortcutDefinition(
            keyCode: keyCode,
            modifiers: modifiers,
            display: ShortcutFormatter.displayString(keyCode: keyCode, modifiers: modifiers)
        )
    }

    static func carbonModifiers(from flags: NSEvent.ModifierFlags) -> UInt32 {
        var modifiers: UInt32 = 0

        if flags.contains(.command) {
            modifiers |= UInt32(cmdKey)
        }
        if flags.contains(.shift) {
            modifiers |= UInt32(shiftKey)
        }
        if flags.contains(.option) {
            modifiers |= UInt32(optionKey)
        }
        if flags.contains(.control) {
            modifiers |= UInt32(controlKey)
        }

        return modifiers
    }

    func isSameCombination(as other: ShortcutDefinition) -> Bool {
        keyCode == other.keyCode && modifiers == other.modifiers
    }
}

enum ShortcutFormatter {
    static func displayString(keyCode: UInt32, modifiers: UInt32) -> String {
        var parts: [String] = []

        if modifiers & UInt32(cmdKey) != 0 {
            parts.append("Cmd")
        }
        if modifiers & UInt32(shiftKey) != 0 {
            parts.append("Shift")
        }
        if modifiers & UInt32(optionKey) != 0 {
            parts.append("Option")
        }
        if modifiers & UInt32(controlKey) != 0 {
            parts.append("Ctrl")
        }

        parts.append(keyName(for: UInt16(keyCode)))
        return parts.joined(separator: "+")
    }

    private static func keyName(for keyCode: UInt16) -> String {
        switch keyCode {
        case 0: return "A"
        case 1: return "S"
        case 2: return "D"
        case 3: return "F"
        case 4: return "H"
        case 5: return "G"
        case 6: return "Z"
        case 7: return "X"
        case 8: return "C"
        case 9: return "V"
        case 11: return "B"
        case 12: return "Q"
        case 13: return "W"
        case 14: return "E"
        case 15: return "R"
        case 16: return "Y"
        case 17: return "T"
        case 18: return "1"
        case 19: return "2"
        case 20: return "3"
        case 21: return "4"
        case 22: return "6"
        case 23: return "5"
        case 24: return "="
        case 25: return "9"
        case 26: return "7"
        case 27: return "-"
        case 28: return "8"
        case 29: return "0"
        case 30: return "]"
        case 31: return "O"
        case 32: return "U"
        case 33: return "["
        case 34: return "I"
        case 35: return "P"
        case 36: return "Return"
        case 37: return "L"
        case 38: return "J"
        case 39: return "'"
        case 40: return "K"
        case 41: return ";"
        case 42: return "\\"
        case 43: return ","
        case 44: return "/"
        case 45: return "N"
        case 46: return "M"
        case 47: return "."
        case 49: return "Space"
        case 50: return "`"
        case 51: return "Delete"
        case 53: return "Esc"
        case 122: return "F1"
        case 120: return "F2"
        case 99: return "F3"
        case 118: return "F4"
        case 96: return "F5"
        case 97: return "F6"
        case 98: return "F7"
        case 100: return "F8"
        case 101: return "F9"
        case 109: return "F10"
        case 103: return "F11"
        case 111: return "F12"
        case 123: return "Left"
        case 124: return "Right"
        case 125: return "Down"
        case 126: return "Up"
        default: return "Key \(keyCode)"
        }
    }
}

