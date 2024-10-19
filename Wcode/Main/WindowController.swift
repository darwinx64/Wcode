//
//  WindowController.swift
//  Wcode
//
//  Created by samara on 1/24/24.
//

import Foundation
import Cocoa

class SidebarView: NSView {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// our main `WindowController`; contains xcodeview to the left, webview right
class WindowController: NSWindowController, NSToolbarDelegate, NSToolbarItemValidation {
    public var xcodeView: XcodeView!
    var websiteView: WebView!

    private var webviewVisible: Bool = true

    private var websiteViewWidthConstraint: NSLayoutConstraint?

    override init(window: NSWindow?) {
        super.init(window: nil)

        windowFrameAutosaveName = "window"
        shouldCascadeWindows = false

        self.window = createWindow()
        configureToolbar()

        xcodeView = XcodeView(frame: .zero)
        websiteView = WebView(frame: .zero)

        setupSplitViewController()

        self.window!.center()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        self.contentViewController = nil
    }

    /// create and configure the main window
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
        window.toolbarStyle = .unifiedCompact
        window.titleVisibility = .hidden

        return window
    }

    func validateToolbarItem(_ item: NSToolbarItem) -> Bool {
        return true
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.toggleSidebar, .toggleWebview, .sidebarTrackingSeparator]
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.toggleSidebar, .toggleWebview, .sidebarTrackingSeparator]
    }
    
    @objc func toggleWebviewAction(_ sender: Any?) {
        webviewVisible.toggle()
        DispatchQueue.main.async {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.3
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                self.websiteViewWidthConstraint?.animator().constant = self.webviewVisible ? 0 : 300
            })
        }
    }
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar isInsertedIntoToolbar: Bool) -> NSToolbarItem? {
        var toolbarItem: NSToolbarItem?
        switch itemIdentifier {
        case .toggleSidebar:
            let toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier.toggleSidebar)
            toolbarItem.label = "Navigator Sidebar"
            toolbarItem.paletteLabel = " Navigator Sidebar"
            toolbarItem.toolTip = "Hide or show the Navigator"
            toolbarItem.isBordered = true
            toolbarItem.image = NSImage(
                systemSymbolName: "sidebar.leading",
                accessibilityDescription: nil
            )?.withSymbolConfiguration(.init(scale: .large))
            return toolbarItem
        case .sidebarTrackingSeparator:
            let item = NSToolbarItem(itemIdentifier: .sidebarTrackingSeparator)
            toolbarItem = item
        case .toggleWebview:
            let toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier.toggleWebview)
            toolbarItem.label = "Webview"
            toolbarItem.paletteLabel = "Webview"
            toolbarItem.toolTip = "Hide or show the Webview"
            toolbarItem.isBordered = true
            toolbarItem.action = #selector(toggleWebviewAction)
            toolbarItem.image = NSImage(
                systemSymbolName: "globe",
                accessibilityDescription: nil
            )?.withSymbolConfiguration(.init(scale: .large))
            return toolbarItem
        default:
            toolbarItem = nil
        }
        toolbarItem?.isBordered = true
        
        return toolbarItem
    }

    /// configures the window's toolbar
    internal func configureToolbar() {
        let toolbar = NSToolbar(identifier: UUID().uuidString)
        toolbar.delegate = self
        toolbar.displayMode = .labelOnly
        toolbar.showsBaselineSeparator = false
        self.window?.toolbar = toolbar
    }

    /// sets up the layout of views within a stack view
    private func setupSplitViewController() {
        let splitViewController = NSSplitViewController()

        let sidebarViewController = NSViewController()
        sidebarViewController.view = SidebarView()

        let mainContentViewController = NSViewController()
        let stackView = NSStackView(views: [xcodeView, websiteView])
        stackView.distribution = .fillEqually
        mainContentViewController.view = stackView
        
        websiteViewWidthConstraint = websiteView.widthAnchor.constraint(equalToConstant: 300)
        websiteViewWidthConstraint?.isActive = true

        let sidebarItem = NSSplitViewItem(sidebarWithViewController: sidebarViewController)
        sidebarItem.allowsFullHeightLayout = true
        sidebarItem.minimumThickness = 200
        sidebarItem.maximumThickness = 300
        sidebarItem.canCollapse = true
        sidebarItem.isCollapsed = false

        let mainContentItem = NSSplitViewItem(viewController: mainContentViewController)
        mainContentItem.allowsFullHeightLayout = false

        splitViewController.addSplitViewItem(sidebarItem)
        splitViewController.addSplitViewItem(mainContentItem)

        self.contentViewController = splitViewController

        NSLayoutConstraint.activate([
            splitViewController.view.leadingAnchor.constraint(equalTo: window!.contentView!.leadingAnchor),
            splitViewController.view.trailingAnchor.constraint(equalTo: window!.contentView!.trailingAnchor),
            splitViewController.view.topAnchor.constraint(equalTo: window!.contentView!.topAnchor),
            splitViewController.view.bottomAnchor.constraint(equalTo: window!.contentView!.bottomAnchor)
        ])
    }
}

private extension NSToolbarItem.Identifier {
    static let toggleWebview: NSToolbarItem.Identifier = NSToolbarItem.Identifier(rawValue: "ToggleWebview")
}
