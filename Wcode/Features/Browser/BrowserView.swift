//
//  ContentView.swift
//  Wcode
//
//  Created by tiramisu on 10/19/24.
//

import SwiftUI
import WebKit
import SwiftUIWebView

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

extension View {
    func apply<V: View>(@ViewBuilder _ block: (Self) -> V) -> V { block(self) }
}

struct BrowserView: View {
    @Binding var showingInspector: Bool?
    
    @State private var urlString: String = "https://www.apple.com"
    
    @State private var action = WebViewAction.idle
    @State private var state = WebViewState.empty

    private var refreshAnimationDuration: Double = 0.3
    
    @State private var refreshRotationDegrees: Double = 0
    
    @State private var backDown = false
    @State private var forwardDown = false
    
    init(showingInspector: Binding<Bool?> = Binding.constant(nil)) {
        self._showingInspector = showingInspector
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
        .toolbar {
            ToolbarItemGroup {
                if showingInspector ?? false {
                    NavigationButton(action: {
                        action = .goBack
                    }, iconName: "chevron.backward", isVisible: state.canGoBack && (showingInspector ?? false))
                    
                    NavigationButton(action: {
                        action = .goForward
                    }, iconName: "chevron.forward", isVisible: state.canGoForward && (showingInspector ?? false))
                    
                    ZStack(alignment: .trailing) {
                        URLTextField(urlString: $urlString, onSubmit: loadUrl)
                        
                        Button(action: {
                            action = .reload
                            refreshRotationDegrees += 360
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 10, weight: .light))
                                .tint(.primary.opacity(0.5))
                                .rotationEffect(.degrees(refreshRotationDegrees))
                                .animation(.easeInOut(duration: refreshAnimationDuration), value: refreshRotationDegrees)
                        }
                        .buttonStyle(NavigationButtonStyle())
                        .padding(.trailing, 3)
                        .scaleEffect((showingInspector ?? false) ? 1 : 0)
                    }
                }
            }
        }
        .padding(.top, 0)
        .background(Rectangle().fill(.ultraThinMaterial))
        .onAppear {
            loadUrl()
        }
    }

    private func loadUrl() {
        if let url = URL(string: urlString) {
            action = .load(URLRequest(url: url))
        }
    }
}


#Preview {
    BrowserView()
}
