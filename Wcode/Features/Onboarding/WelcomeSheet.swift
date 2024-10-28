//
//  WelcomeSheet.swift
//  Wcode
//
//  Created by paige on 10/21/24.
//

import SwiftUI

struct WelcomeSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showWelcomeContent = false
    @State private var showAppIcon = true
    @State private var showFeatureRows = false
    
    var body: some View {
        VStack {
            Image(nsImage: NSApp.applicationIconImage)
                .frame(height: showAppIcon ? 180 : 0)
                .scaleEffect(showAppIcon ? 1 : 0)
                .opacity(showAppIcon ? 1 : 0)
                .animation(.spring().delay(0.3), value: showAppIcon)
                .padding(.bottom, -15)
            
            Text("Welcome to Wcode")
                .font(.largeTitle)
                .fontWeight(.bold)
                .opacity(showWelcomeContent ? 1 : 0)
                .animation(.spring().delay(0.4), value: showWelcomeContent)
                .animation(.spring(.bouncy).delay(0.4), value: showAppIcon)

            VStack(spacing: 30) {
                    FeatureRow(icon: "globe", title: "gm", description: "gm")
                        .opacity(showFeatureRows ? 1 : 0)
                        .scaleEffect(showFeatureRows ? 1 : 0)
                        .animation(.spring(.bouncy(extraBounce: -0.1)).delay(0.3), value: showFeatureRows)
                    
                    FeatureRow(icon: "folder", title: "gm", description: "gm")
                        .opacity(showFeatureRows ? 1 : 0)
                        .scaleEffect(showFeatureRows ? 1 : 0)
                        .animation(.spring(.bouncy(extraBounce: 0.2)).delay(0.4), value: showFeatureRows)
                    
                    FeatureRow(icon: "gear", title: "gm", description: "gm")
                        .opacity(showFeatureRows ? 1 : 0)
                        .scaleEffect(showFeatureRows ? 1 : 0)
                        .animation(.spring(.bouncy(extraBounce: 0.3)).delay(0.5), value: showFeatureRows)
            }
            .padding(.top)
            .padding(.horizontal)
            
            Spacer()

            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("gm")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "ff8ad8"))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
            }
            .opacity(showFeatureRows ? 1 : -1)
            .scaleEffect(showFeatureRows ? 1 : 0)
            .frame(height: showFeatureRows ? 50 : 0)
            .animation(.spring(.bouncy).delay(0.9), value: showFeatureRows)
            .buttonStyle(.plain)
        }
        .frame(width: 500, height: 450)
        .opacity(showWelcomeContent ? 1 : 0)
        .scaleEffect(showWelcomeContent ? 1 : 0.8)
        .animation(.spring(duration: 2), value: showWelcomeContent)
        .onAppear {
            withAnimation(.spring(duration: 2).delay(0.3)) {
                showWelcomeContent = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showAppIcon = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showFeatureRows = true
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: icon)
                .font(.system(size: 35))
                .foregroundStyle(Color(hex: "ff8ad8"))
                .frame(width: 60)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
    }
}

#Preview {
    WelcomeSheet()
        .padding()
}
