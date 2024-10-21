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

struct CodeEditorViewWrapper: NSViewRepresentable {
    func makeNSView(context: Context) -> CodeEditorView {
        let codeEditorView = CodeEditorView()
        return codeEditorView
    }
    func updateNSView(_ nsView: CodeEditorView, context: Context) {}
}

struct ContentView: View {
    @State private var showingInspector: Bool? = false
    @State private var action = WebViewAction.idle
    @State private var state = WebViewState.empty
    @State private var urlString: String = "https://www.google.com/"
    @State private var inspectorWidth: CGFloat = 0
    var body: some View {
        NavigationSplitView {
            List {
                VStack {
                    Color(NSColor.secondarySystemFill)
                        .frame(height: 1)
                        .padding(.horizontal, -200)
                        .padding(.top, -3.501)
                    
                    let icons = ["folder.fill", "bookmark", "magnifyingglass", "exclamationmark.triangle", "checkmark.diamond", "ladybug", "tag"]
                    let accentIconIndex = 0

                    HStack {
                        ForEach(icons.indices, id: \.self) { index in
                            Image(systemName: icons[index])
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundStyle(index == accentIconIndex ? Color.accentColor : Color.secondary)
                                .frame(height: 13)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.top, -3.501)
                    
                    Color(NSColor.secondarySystemFill)
                        .frame(height: 1)
                        .padding(.horizontal, -200)
                }
                Section("Meow") {}
            }
            .frame(minWidth: 250)
            .toolbar { Button(action: toggleSidebar, label: { Image(systemName: "sidebar.left") }) }
            .listStyle(SidebarListStyle())
        } detail: {
            CodeEditorViewWrapper()
        }
        .presentedWindowToolbarStyle(.unifiedCompact)
        .inspector(isPresented: Binding(
            get: { showingInspector ?? false },
            set: { newValue in showingInspector = newValue ? true : nil }
        ), content: {
            GeometryReader { geometry in
                BrowserView(showingInspector: $showingInspector, action: $action, state: $state, urlString: $urlString)
                    .onChange(of: geometry.size) {
                        inspectorWidth = geometry.size.width
                    }
            }.inspectorColumnWidth(min: 150, ideal: 350, max: 500)
                .toolbar() {
                    Button(action: toggleInspector) {
                        Image(systemName: "sidebar.right")
                            .help("Toggle Browser")
                    }
                    if showingInspector ?? false {
                        NavigationButton(action: {
                            action = .goBack
                        }, iconName: "chevron.backward")
                        .disabled(!state.canGoBack)
                        
                        NavigationButton(action: {
                            action = .goForward
                        }, iconName: "chevron.forward")
                        .disabled(!state.canGoForward)
                    }
                    TextField("", text: $urlString)
                        .truncationMode(.tail)
                        .frame(width: (inspectorWidth - 130))
                        .onSubmit {
                            
                        }
                }
        })
        
    }
    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?
            .tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
    private func toggleInspector() {
        if (showingInspector ?? false) {
            showingInspector = false
        } else {
            showingInspector = true
        }
    }
}

#Preview {
    ContentView()
}

class WindowController: NSWindowController {
    public var contentView: ContentView!
    public var hostingView: NSHostingView<ContentView>!
    public var codeEditorView: CodeEditorView!

    override init(window: NSWindow?) {
        super.init(window: nil)

        windowFrameAutosaveName = "window"
        shouldCascadeWindows = false

        self.window = createWindow()

        self.window!.center()
        
        self.contentView = ContentView()
        self.hostingView = NSHostingView(rootView: contentView)
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
