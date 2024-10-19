//
//  SettingsView.swift
//  Wcode
//
//  Created by paige on 10/18/24.
//

import SwiftUI

struct TabItem {
    let id: String
    let icon: String
    let title: String
}

extension View {
    func apply<V: View>(@ViewBuilder _ block: (Self) -> V) -> V { block(self) }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct SettingsView: View {
    @State private var selectedTab: TabItem?
    @State private var hoveredTab: TabItem?
    @Environment(\.colorScheme) var colorScheme

    private let tabs: [TabItem] = [
        TabItem(id: "General", icon: "gearshape", title: "General"),
        TabItem(id: "Accounts", icon: "person.crop.circle", title: "Accounts"),
        TabItem(id: "Advanced", icon: "flame", title: "Advanced")
    ]
    
    init() {
        _selectedTab = State(initialValue: tabs.first!)
    }

    var body: some View {
        VStack {
            HStack(spacing: 1) {
                ForEach(tabs, id: \.id) { tab in
                    Button(action: {
                        selectedTab = tab
                    }) {
                        VStack {
                            Image(systemName: tab.icon)
                                .font(.system(size: 20))
                            Text(tab.title)
                                .font(.caption)
                        }
                        .foregroundColor(selectedTab?.id == tab.id ? .accentColor : .gray)
                        .padding(5)
                    }
                    .buttonStyle(.plain)
                    .background(selectedTab?.id == tab.id || hoveredTab?.id == tab.id ? .gray.opacity(0.1) : Color.clear)
                    .cornerRadius(5)
                    .onHover(perform: { hovered in
                        hoveredTab = hovered ? tab : nil
                    })
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 20)
            .padding()
            .background(colorScheme == .dark ? Color(hex: "383838") : Color(hex: "fbfbfb"))
            Text("h")
                .padding(10)
                .font(.largeTitle)
                .multilineTextAlignment(.center)
        }.frame(width: 300)
    }
}
