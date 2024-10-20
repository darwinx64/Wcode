//
//  NavigationButton.swift
//  Wcode
//
//  Created by tiramisu on 10/19/24.
//

import SwiftUI

struct NavigationButtonStyle: ButtonStyle {
    public var buttonSpring: Animation = .interpolatingSpring(stiffness: 210, damping: 20)
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(.clear)
            .scaleEffect(configuration.isPressed ? 0.8 : 1)
            .animation(buttonSpring, value: configuration.isPressed)
    }
}

/// view for navigation buttons in the browser
/// (reload, back, forward)
struct NavigationButton: View {
    let action: () -> Void
    let iconName: String
    let isVisible: Bool

    var body: some View {
        Button(action: action) {
            Image(systemName: iconName)
                .font(.init(.system(size: 12, weight: .light)))
                .tint(.primary.opacity(0.5))
                .frame(width: isVisible ? 12 : 0, height: isVisible ? 12 : 0)
                .animation(NavigationButtonStyle().buttonSpring, value: isVisible)
        }
        .buttonStyle(NavigationButtonStyle())
        .scaleEffect(isVisible ? 1 : 0)
        .frame(width: 0, height: isVisible ? 12 : 0)
        .animation(NavigationButtonStyle().buttonSpring, value: isVisible)
        .accessibilityLabel("\(iconName) button")
        .accessibilityHint(isVisible ? "Go \(iconName == "chevron.backward" ? "back" : "forward")" : "")
    }
}
