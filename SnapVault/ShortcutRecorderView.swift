//
//  ShortcutRecorderView.swift
//  SnapVault
//

import AppKit
import Carbon.HIToolbox
import SwiftUI

struct ShortcutRecorderView: View {
    @Binding var shortcut: ShortcutDefinition?

    @State private var isRecording = false
    @State private var monitor: Any?

    var body: some View {
        HStack {
            Text("Shortcut")
                .frame(width: 120, alignment: .leading)

            Button {
                isRecording ? stopRecording() : startRecording()
            } label: {
                Text(recorderTitle)
                    .frame(minWidth: 170)
            }
            .buttonStyle(.borderedProminent)

            if shortcut != nil {
                Button("Clear") {
                    shortcut = nil
                }
            }
        }
        .onDisappear {
            stopRecording()
        }
    }

    private var recorderTitle: String {
        if isRecording {
            return "Press Shortcut..."
        }

        return shortcut?.display ?? "Record Shortcut"
    }

    private func startRecording() {
        isRecording = true

        monitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { event in
            guard isRecording else { return event }

            if event.keyCode == UInt16(kVK_Escape) {
                stopRecording()
                return nil
            }

            guard let recordedShortcut = ShortcutDefinition.from(event: event) else {
                NSSound.beep()
                return nil
            }

            shortcut = recordedShortcut
            stopRecording()
            return nil
        }
    }

    private func stopRecording() {
        isRecording = false

        if let monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
    }
}

