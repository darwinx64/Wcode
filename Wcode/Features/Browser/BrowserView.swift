//
//  ContentView.swift
//  Wcode
//
//  Created by paige on 10/19/24.
//

import SwiftUI
import WebKit
import WcodeWebView

/// detect if user clicks mouse back/forward btn
class MouseEventView: NSView {
    var onMouseEvent: ((NSEvent) -> Void)?
    
    override func otherMouseDown(with event: NSEvent) {
        if event.buttonNumber == 3 {
            onMouseEvent?(event)
        } else if event.buttonNumber == 4 {
            onMouseEvent?(event)
        }
    }
    
    override func otherMouseUp(with event: NSEvent) {
        if event.buttonNumber == 3 {
            onMouseEvent?(event)
        } else if event.buttonNumber == 4 {
            onMouseEvent?(event)
        }
    }
}

struct MouseEventRepresentable: NSViewRepresentable {
    var onMouseEvent: (NSEvent) -> Void
    
    func makeNSView(context: Context) -> NSView {
        let view = MouseEventView()
        view.onMouseEvent = onMouseEvent
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) { }
}

struct NavigationIndicator: View {
    var systemName: String
    var down: Bool
    var alignment: Alignment
    
    var body: some View {
        Circle()
            .fill(Color.black.opacity(0.5))
            .frame(width: down ? 50 : 0, height: down ? 50 : 0)
            .animation(NavigationButtonStyle().buttonSpring, value: down)
            .overlay(
                Image(systemName: systemName)
                    .font(.system(size: down ? 24 : 0, weight: .bold))
                    .rotationEffect(.degrees(down ? 0 : 180))
                    .animation(NavigationButtonStyle().buttonSpring, value: down)
            )
            .padding(alignment == .leading ? .leading : .trailing, 10)
    }
}

struct BrowserView: View {
    @Binding var showingInspector: Bool?
    @Binding var urlString: String
    @Binding var action: WebViewAction
    @Binding var state: WebViewState

    private var refreshAnimationDuration: Double = 0.3
    
    @State private var refreshRotationDegrees: Double = 0
    
    @State private var backDown = false
    @State private var forwardDown = false
    
    init(showingInspector: Binding<Bool?> = Binding.constant(nil), action: Binding<WebViewAction>, state: Binding<WebViewState>, urlString: Binding<String>) {
        self._showingInspector = showingInspector
        self._action = action
        self._state = state
        self._urlString = urlString
    }
    
    var body: some View {
        VStack {
            ZStack{
                WebView(action: $action, state: $state)
                    .overlay {
                        if state.isLoading {
                            ProgressView()
                        }
                        GeometryReader { geometry in
                            VStack {
                                Spacer()
                                HStack {
                                    NavigationIndicator(systemName: "arrow.backward", down: backDown, alignment: .leading)
                                    Spacer()
                                    NavigationIndicator(systemName: "arrow.forward", down: forwardDown, alignment: .trailing)
                                }
                                .foregroundColor(.white)
                                .padding([.leading, .trailing], 10)
                                Spacer()
                            }
                        }
                    }
                MouseEventRepresentable { event in
                    if event.buttonNumber == 3 && state.canGoBack {
                        switch event.type {
                        case .otherMouseUp:
                            action = .goBack
                            backDown = false
                        case .otherMouseDown:
                            backDown = true
                        default:
                            break
                        }
                    } else if event.buttonNumber == 4 && state.canGoForward {
                        switch event.type {
                        case .otherMouseUp:
                            action = .goForward
                            forwardDown = false
                        case .otherMouseDown:
                            forwardDown = true
                        default:
                            break
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding(.top, 0)
        .background(Rectangle().fill(.ultraThinMaterial))
        .onAppear {
            loadUrl()
        }
        .onChange(of: urlString) {
            loadUrl()
        }
    }

    private func loadUrl() {
        if let url = URL(string: urlString) {
            action = .load(URLRequest(url: url))
        }
    }
}
