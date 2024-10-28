//
//  FontPickerDelegate.swift
//  Wcode
//
//  Created by paige on 10/21/24.
//

/// src: https://github.com/tyagishi/FontPicker/

import SwiftUI

class FontPickerDelegate {
    var parent: FontPicker

    init(_ parent: FontPicker) {
        self.parent = parent
    }
    
    @objc
    func changeFont(_ id: Any) {
        parent.fontSelected()
    }

}

public struct FontPicker: View {
    let label: LocalizedStringKey?
    
    @Binding var font: NSFont
    @State var fontPickerDelegate: FontPickerDelegate?
    
    public init(_ titlekey: LocalizedStringKey? = nil, selection: Binding<NSFont>) {
        self.label = titlekey
        self._font = selection
    }
    
    public var body: some View {
        HStack {
            if let label {
                Text(label)
            } else {
                EmptyView()
            }
            
            Button {
                if NSFontPanel.shared.isVisible {
                    NSFontPanel.shared.orderOut(nil)
                    
                    if NSFontManager.shared.target === self.fontPickerDelegate {
                        return
                    }
                }
                
                self.fontPickerDelegate = FontPickerDelegate(self)
                NSFontManager.shared.target = self.fontPickerDelegate
                NSFontPanel.shared.setPanelFont(self.font, isMultiple: false)
                NSFontPanel.shared.orderBack(nil)
            } label: {
                Image(systemName: "textformat")
                    .resizable()
                    .scaledToFit()
                    .padding(2)
            }
        }
    }
    
    func fontSelected() {
        self.font = NSFontPanel.shared.convert(self.font)
    }
}
