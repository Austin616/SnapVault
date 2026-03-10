//
//  PresetEditorView.swift
//  SnapVault
//

import AppKit
import SwiftUI

struct PresetEditorView: View {
    let existingPresets: [ScreenshotPreset]
    let presetToEdit: ScreenshotPreset?
    let onSave: (ScreenshotPreset) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var folderPath: String
    @State private var type: ScreenshotType
    @State private var shortcut: ShortcutDefinition?

    init(
        existingPresets: [ScreenshotPreset],
        presetToEdit: ScreenshotPreset?,
        onSave: @escaping (ScreenshotPreset) -> Void
    ) {
        self.existingPresets = existingPresets
        self.presetToEdit = presetToEdit
        self.onSave = onSave

        _name = State(initialValue: presetToEdit?.name ?? "")
        _folderPath = State(initialValue: presetToEdit?.folderPath ?? "")
        _type = State(initialValue: presetToEdit?.type ?? .fullScreen)
        _shortcut = State(initialValue: presetToEdit?.shortcut)
    }

    private var duplicateShortcutName: String? {
        guard let shortcut else { return nil }

        return existingPresets.first(where: { preset in
            preset.id != presetToEdit?.id && preset.shortcut.isSameCombination(as: shortcut)
        })?.name
    }

    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !folderPath.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        shortcut != nil &&
        duplicateShortcutName == nil
    }

    private var title: String {
        presetToEdit == nil ? "Add Preset" : "Edit Preset"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Form {
                TextField("Preset Name", text: $name)

                HStack {
                    TextField("Destination Folder", text: $folderPath)
                    Button("Browse...") {
                        pickFolder()
                    }
                }

                Picker("Screenshot Type", selection: $type) {
                    Text("Full Screen").tag(ScreenshotType.fullScreen)
                    Text("Selected Area").tag(ScreenshotType.selectedArea)
                }

                VStack(alignment: .leading, spacing: 6) {
                    ShortcutRecorderView(shortcut: $shortcut)

                    if let duplicateShortcutName {
                        Text("Shortcut already used by \"\(duplicateShortcutName)\".")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
            }
            .formStyle(.grouped)

            HStack {
                Spacer()
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
                Button("Save") {
                    savePreset()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!isFormValid)
            }
        }
        .padding(20)
        .frame(minWidth: 560, minHeight: 300)
        .navigationTitle(title)
    }

    private func pickFolder() {
        let panel = NSOpenPanel()
        panel.title = "Select Destination Folder"
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = true

        if panel.runModal() == .OK, let url = panel.url {
            folderPath = url.path
        }
    }

    private func savePreset() {
        guard let shortcut else { return }

        let savedPreset = ScreenshotPreset(
            id: presetToEdit?.id ?? UUID(),
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            folderPath: folderPath.trimmingCharacters(in: .whitespacesAndNewlines),
            shortcut: shortcut,
            type: type,
            isEnabled: presetToEdit?.isEnabled ?? true
        )

        onSave(savedPreset)
        dismiss()
    }
}

