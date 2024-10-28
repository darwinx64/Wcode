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
    
    @State private var scale: CGFloat = 1
    
    @State private var scaleCaption: CGFloat = 1
    @State private var heightCaption: CGFloat = 0
    
    var body: some View {
        Settings.Container(contentWidth: contentWidth) {
            Settings.Section(title: "") {
                VStack {
                    Text("General")
                        .font(.headline)
                        .scaleEffect(scale)
                    Text("soon™")
                        .frame(height: heightCaption)
                        .scaleEffect(scaleCaption)
                }
                .onAppear {
                    scaleCaption = 0
                    heightCaption = 0
                    scale = 0
                    withAnimation(NavigationButtonStyle().buttonSpring.delay(1)) {
                        scaleCaption = 1
                        heightCaption = 10
                    }
                    withAnimation(NavigationButtonStyle().buttonSpring) {
                        scale = 1
                    }
                }
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .frame(height: 100)
            }
        }
    }
}

struct CodeEditorAppearancePreview: View {
    @Binding var codeBg: Color
    @Binding var codeFont: NSFont
    
    @State private var width: CGFloat? = 600
    @State private var height: CGFloat? = 200
    
    var body: some View {
        TextEditor(text: .constant("iOS is designed to be reliable and secure from the moment you turn on your device."))
            .font(Font(codeFont))
            .frame(width: width, height: height)
            .onAppear {
                width = 0
                height = 0
                withAnimation(.spring) {
                    width = 600
                    height = 200
                }
            }
    }
}

struct AppearanceSettingsView: View {
    private let contentWidth: Double = 450.0
    
    @State private var codeBg: Color = Color.red
    @State private var codeFont: NSFont = NSFont(name: "SF Mono Medium", size: 19.0)!
    
    @State private var codeEditorShown = false
    
    var body: some View {
        Settings.Container(contentWidth: contentWidth) {
            Settings.Section(title: "") {
                HStack(alignment: .center) {
                    Button { codeEditorShown = true } label: { Image(systemName: "eye.fill").foregroundStyle(.tint) }.buttonStyle(.plain)
                    ColorPicker("Code editor background", selection: $codeBg)
                }
                HStack(alignment: .center) {
                    Button { codeEditorShown = true } label: { Image(systemName: "eye.fill").foregroundStyle(.tint) }.buttonStyle(.plain)
                    FontPicker("Code editor font", selection: $codeFont)
                }
            }
        }.sheet(isPresented: $codeEditorShown) {
            CodeEditorAppearancePreview(codeBg: $codeBg, codeFont: $codeFont)
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
        GeneralSettingsView()
    }
}
