//
//  PressActions.swift
//  Wcode
//
//  Created by paige on 10/21/24.
//

import SwiftUI

struct PressActions: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged({ _ in
                        onPress()
                    })
                    .onEnded({ _ in
                        onRelease()
                    })
            )
    }
}
