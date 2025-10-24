//
//  ContentView.swift
//  ReplaceYourQRCodes
//
//  Created by Dodier NFC on 10/16/25.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct ContentView: View {
    @StateObject private var viewModel = QRNFCViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // App logo centered
                    Image("DodierNFC")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 120)
                        .accessibilityLabel("Dodier NFC")
                    
                    if viewModel.isScanning {
                        QRScannerView(viewModel: viewModel)
                            .frame(height: 420)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue, lineWidth: 2)
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 420)
                            .overlay(
                                VStack {
                                    Image(systemName: "qrcode.viewfinder")
                                        .font(.system(size: 50))
                                        .foregroundColor(.gray)
                                    Text("Tap below")
                                        .foregroundColor(.gray)
                                }
                            )
                    }
                    
                    VStack(spacing: 15) {
                        if let detectedURL = viewModel.detectedURL {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Detected URL:")
                                    .font(.headline)
                                Text(detectedURL)
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .lineLimit(3)
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                            
                            Button(action: {
                                viewModel.writeToNFC()
                            }) {
                                HStack {
                                    if viewModel.isWritingNFC {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "nfc")
                                    }
                                    Text(viewModel.isWritingNFC ? "Writing to NFC..." : "Write to NFC Tag")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hex: "#394084"))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .disabled(viewModel.isWritingNFC)
                            
                            Button("Scan Another QR Code") {
                                viewModel.startScanning()
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "#394084"))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        } else {
                        Button(action: {
                            viewModel.startScanning()
                        }) {
                            HStack {
                                Image(systemName: "qrcode.viewfinder")
                                Text("Scan")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "#394084"))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        
                        Button(action: {
                            if let url = URL(string: "https://www.tagstand.com/products/clear-pet-sticker-ntag213-25mm/") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack {
                                Image(systemName: "cart")
                                Text("Buy NFC Tags")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "#394084"))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        
                        Button(action: {
                            if let url = URL(string: "https://apps.apple.com/us/app/dodier-nfc/id6746334723") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack {
                                Image(systemName: "star.fill")
                                Text("Get Premium")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "#394084"))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
                .navigationBarHidden(true)
            }
            .alert(item: $viewModel.alertMessage) { (alertMessage: AlertMessage) in
                if alertMessage.title == "QR Code Detected" {
                    return Alert(
                        title: Text(alertMessage.title),
                        message: Text(alertMessage.message),
                        primaryButton: .default(Text("Write to NFC")) {
                            viewModel.writeToNFC()
                        },
                        secondaryButton: .cancel(Text("Cancel"))
                    )
                } else {
                    return Alert(
                        title: Text(alertMessage.title),
                        message: Text(alertMessage.message),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        }
    }
}

struct AlertMessage: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct SplashView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            VStack(spacing: 16) {
                // Splash logo image
                Image("DodierNFC")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 160)
                    .accessibilityLabel("Dodier NFC")
            }
            .padding(24)
        }
    }
}
