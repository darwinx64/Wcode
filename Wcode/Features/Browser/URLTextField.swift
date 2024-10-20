//
//  URLTextField.swift
//  Wcode
//
//  Created by tiramisu on 10/19/24.
//

import SwiftUI
import SwiftUIWebView

struct URLFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .textFieldStyle(PlainTextFieldStyle())
            .padding()
        
    }
}

struct URLTextField: View {
    @Binding var urlString: String
    @FocusState var isTextFieldFocused: Bool
    let onSubmit: () -> Void
    
    var body: some View {
        ZStack {
            TextField("Enter URL", text: $urlString, onCommit: onSubmit)
                .truncationMode(.tail)
                .focused($isTextFieldFocused)
                .opacity(isTextFieldFocused ? 1 : 0.5)
                .animation(.easeInOut(duration: 0.1), value: isTextFieldFocused)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding([.bottom, .top], 0)
                .onSubmit {
                    onSubmit()
                }
        }
    }
}

struct URLTextFieldTestView: View {
    @State private var urlString: String = "https://www.apple.com"
    
    @State private var action = WebViewAction.idle
    @State private var state = WebViewState.empty
    
    var body: some View {
        VStack {
            URLTextField(urlString: $urlString, onSubmit: {})
            TextField("", text: .constant(""))
        }
    }
}

#Preview {
    URLTextFieldTestView()
        .padding()
}
