//
//  DefaultDirectoryView.swift
//  Mist
//
//  Created by Mac Justice on 1/10/2026.
//

import SwiftUI

struct DefaultDirectoryView: View {
    var title: String
    @Binding var directory: String
    @State private var openPanel: NSOpenPanel = .init()

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading) {
                    Text(title)
                    FooterText(directory.isEmpty ? "No default directory set. Mist will open the last used location." : "Mist will open this directory when downloading Firmwares and Installers.")
                }
                Spacer()
                Button("Clear") { directory = "" }
                    .disabled(directory.isEmpty)
                Button("Select...") { selectDirectory() }
            }
            if !directory.isEmpty {
                PathControl(path: $directory)
                    .disabled(true)
            }
        }
    }

    private func selectDirectory() {
        openPanel.prompt = "Select"
        openPanel.canCreateDirectories = true
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.resolvesAliases = true
        openPanel.allowsMultipleSelection = false

        if !directory.isEmpty {
            openPanel.directoryURL = URL(fileURLWithPath: directory)
        }

        let response: NSApplication.ModalResponse = openPanel.runModal()

        guard
            response == .OK,
            let url: URL = openPanel.url else {
            return
        }

        directory = url.path
    }
}

struct DefaultDirectoryView_Previews: PreviewProvider {
    static var previews: some View {
        DefaultDirectoryView(title: "Default download directory:", directory: .constant(.cacheDirectory))
    }
}
