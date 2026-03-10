//
//  PresetsView.swift
//  SnapVault
//

import SwiftUI

struct PresetsView: View {
    @EnvironmentObject private var presetStore: PresetStore

    @State private var selectedPresetID: UUID?
    @State private var editorMode: EditorMode?

    private enum EditorMode: Identifiable {
        case add
        case edit(ScreenshotPreset)

        var id: String {
            switch self {
            case .add:
                return "add"
            case .edit(let preset):
                return "edit-\(preset.id.uuidString)"
            }
        }

        var presetToEdit: ScreenshotPreset? {
            switch self {
            case .add:
                return nil
            case .edit(let preset):
                return preset
            }
        }
    }

    private var selectedPreset: ScreenshotPreset? {
        guard let selectedPresetID else { return nil }
        return presetStore.presets.first(where: { $0.id == selectedPresetID })
    }

    var body: some View {
        NavigationStack {
            Group {
                if presetStore.presets.isEmpty {
                    ContentUnavailableView(
                        "No Presets Yet",
                        systemImage: "camera.on.rectangle",
                        description: Text("Create a preset to route screenshots into a specific folder.")
                    )
                } else {
                    List(selection: $selectedPresetID) {
                        ForEach(presetStore.presets) { preset in
                            PresetRow(preset: preset)
                                .tag(preset.id)
                                .contextMenu {
                                    Button("Edit") {
                                        editorMode = .edit(preset)
                                    }

                                    Button("Delete", role: .destructive) {
                                        presetStore.deletePreset(id: preset.id)
                                        if selectedPresetID == preset.id {
                                            selectedPresetID = nil
                                        }
                                    }
                                }
                        }
                        .onDelete(perform: presetStore.deletePresets)
                    }
                }
            }
            .navigationTitle("Screenshot Presets")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button {
                        editorMode = .add
                    } label: {
                        Label("Add Preset", systemImage: "plus")
                    }

                    Button {
                        guard let selectedPreset else { return }
                        editorMode = .edit(selectedPreset)
                    } label: {
                        Label("Edit Preset", systemImage: "pencil")
                    }
                    .disabled(selectedPreset == nil)

                    Button(role: .destructive) {
                        guard let selectedPresetID else { return }
                        presetStore.deletePreset(id: selectedPresetID)
                        self.selectedPresetID = nil
                    } label: {
                        Label("Delete Preset", systemImage: "trash")
                    }
                    .disabled(selectedPresetID == nil)
                }
            }
        }
        .sheet(item: $editorMode) { mode in
            PresetEditorView(
                existingPresets: presetStore.presets,
                presetToEdit: mode.presetToEdit
            ) { updatedPreset in
                if mode.presetToEdit == nil {
                    presetStore.addPreset(updatedPreset)
                } else {
                    presetStore.updatePreset(updatedPreset)
                }
            }
        }
    }
}

private struct PresetRow: View {
    let preset: ScreenshotPreset

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(preset.name)
                    .font(.headline)
                Spacer()
                Text(preset.shortcut.display)
                    .font(.subheadline.monospaced())
                    .foregroundStyle(.secondary)
            }

            Text(preset.folderPath)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)

            Text(preset.type == .fullScreen ? "Full Screen" : "Selected Area")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

