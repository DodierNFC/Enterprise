//
//  ReplaceYourQRCodesApp.swift
//  ReplaceYourQRCodes
//
//  Created by Dodier NFC on 10/16/25.
//

import SwiftUI

@main
struct ReplaceYourQRCodesApp: App {
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .opacity(showSplash ? 0 : 1)
                if showSplash {
                    SplashView()
                        .transition(.opacity)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showSplash = false
                    }
                }
            }
        }
    }
}
