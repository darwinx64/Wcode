//
//  NavigationButton.swift
//  Wcode
//
//  Created by paige on 10/19/24.
//

import SwiftUI
import SwiftUIWebView

struct NavigationButtonStyle: ButtonStyle {
    public var buttonSpring: Animation = .interpolatingSpring(stiffness: 210, damping: 20)
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.8 : 1)
            .animation(buttonSpring, value: configuration.isPressed)
    }
}

struct NavigationButton: View {
    let action: () -> Void
    let iconName: String

    var body: some View {
        Button(action: action) {
            Image(systemName: iconName)
        }
    }
}
