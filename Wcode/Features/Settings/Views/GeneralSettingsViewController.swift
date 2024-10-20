//
//  GeneralSettingsViewController.swift
//  Wcode
//
//  Created by paige on 10/19/24.
//

import SwiftUI
import Settings

struct GeneralSettingsView: View {
    private let contentWidth: Double = 450.0
    var body: some View {
        Settings.Container(contentWidth: contentWidth) {
            Settings.Section(title: "") {
                
            }
        }
    }
}

struct AppearanceSettingsView: View {
    @State private var showGreeting = true
    private let contentWidth: Double = 450.0
    var body: some View {
        Settings.Container(contentWidth: contentWidth) {
            Settings.Section(title: "") {
                
            }
            Settings.Section(title: "") {
                Toggle("Show browser view", isOn: $showGreeting)
                Text("The browser view is intended for website development")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
    }
}

let GeneralSettingsViewController: () -> SettingsPane = {
    let paneView = Settings.Pane(
        identifier: .general,
        title: "General",
        toolbarIcon: NSImage(systemSymbolName: "gearshape", accessibilityDescription: nil)!
    ) {
        GeneralSettingsView()
    }

    return Settings.PaneHostingController(pane: paneView)
}

let AppearanceSettingsViewController: () -> SettingsPane = {
    let paneView = Settings.Pane(
        identifier: .appearance,
        title: "Appearance",
        toolbarIcon: NSImage(systemSymbolName: "paintbrush", accessibilityDescription: nil)!
    ) {
        AppearanceSettingsView()
    }

    return Settings.PaneHostingController(pane: paneView)
}

struct AppearanceSettings_Previews: PreviewProvider {
    static var previews: some View {
        AppearanceSettingsView()
    }
}
