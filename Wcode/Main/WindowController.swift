//
//  WindowController.swift
//  Wcode
//
//  Created by samara on 1/24/24.
//

import Foundation
import Cocoa
import SwiftUI
import WcodeWebView

#Preview {
    WorkspaceView()
}

class WindowController: NSWindowController {
    public var workspaceView: WorkspaceView!
    public var hostingView: NSHostingView<WorkspaceView>!
    public var codeEditorView: CodeEditorView!

    override init(window: NSWindow?) {
        super.init(window: nil)

        windowFrameAutosaveName = "window"
        shouldCascadeWindows = false

        self.window = createWindow()

        self.window!.center()
        
        self.workspaceView = WorkspaceView()
        self.hostingView = NSHostingView(rootView: workspaceView)
        self.hostingView.sceneBridgingOptions = [.toolbars]

        self.hostingView.frame = self.window!.contentView!.bounds
        self.hostingView.autoresizingMask = [.width, .height]
        
        self.window!.contentView?.addSubview(self.hostingView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit { self.contentViewController = nil }

    private func createWindow() -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1100, height: 900),
            styleMask: [.closable, .miniaturizable, .resizable, .titled, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.minSize = NSSize(width: 600, height: 600)
        window.tabbingMode = .preferred
        window.becomeFirstResponder()
        window.animationBehavior = .documentWindow
        window.titlebarSeparatorStyle = .automatic
        window.titleVisibility = .hidden
        return window
    }
}
