//
//  CodeEditorViewWrapper.swift
//  Wcode
//
//  Created by paige on 10/21/24.
//

import SwiftUI
import WcodeWebView

class Coordinator {
    var codeEditorView: CodeEditorView

    init() {
        self.codeEditorView = CodeEditorView()
    }
}

struct CodeEditorViewWrapper: NSViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> CodeEditorView {
        return context.coordinator.codeEditorView
    }

    func updateNSView(_ nsView: CodeEditorView, context: Context) {
        
    }
}

struct WorkspaceView: View {
    @State private var showingInspector: Bool? = false
    @State private var action = WebViewAction.idle
    @State private var state = WebViewState.empty
    @State private var urlString: String = "https://www.apple.com/"
    @State private var inspectorWidth: CGFloat = 0
    @State private var isPresented: Bool = true
    
    var body: some View {
        NavigationSplitView {
            FileTreeView()
            .frame(minWidth: 250)
            .toolbar { Button(action: toggleSidebar, label: { Image(systemName: "sidebar.left") }) }
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
        })/*.sheet(isPresented: $isPresented) {
            WelcomeSheet()
                .presentationBackground(.ultraThinMaterial)
        }*/
        
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
    WorkspaceView()
}
