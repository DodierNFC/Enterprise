//
//  PaywallView.swift
//  NFC Business Management
//
//  Created by Dodier NFC on 10/16/25.
//

import SwiftUI

struct PaywallView: View {
    @ObservedObject var subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss
    @State private var isPurchasing = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)
                        
                        Text("Unlock Premium")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Get unlimited NFC tag management with advanced security features")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top)
                    
                    // Pricing
                    VStack(spacing: 16) {
                        VStack(spacing: 8) {
                            Text("Premium Plan")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            HStack(alignment: .bottom, spacing: 4) {
                                Text("$15")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                Text("/month")
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                        
                        Text("Cancel anytime • 7-day free trial")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Features
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Premium Features")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        VStack(spacing: 16) {
                            PremiumFeatureRow(
                                icon: "infinity",
                                title: "Unlimited Tags",
                                description: "Create as many NFC tags as you need",
                                isPremium: true
                            )
                            
                            PremiumFeatureRow(
                                icon: "lock.fill",
                                title: "Tag Locking",
                                description: "Secure your tags with password protection",
                                isPremium: true
                            )
                            
                            PremiumFeatureRow(
                                icon: "chart.bar.fill",
                                title: "Advanced Analytics",
                                description: "Detailed insights and performance metrics",
                                isPremium: true
                            )
                            
                            PremiumFeatureRow(
                                icon: "icloud.fill",
                                title: "Cloud Sync",
                                description: "Sync your tags across all devices",
                                isPremium: true
                            )
                            
                            PremiumFeatureRow(
                                icon: "location.fill",
                                title: "Location Tracking",
                                description: "Track where your tags were created",
                                isPremium: true
                            )
                            
                            PremiumFeatureRow(
                                icon: "star.fill",
                                title: "Priority Support",
                                description: "Get help when you need it most",
                                isPremium: true
                            )
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    // Current Usage
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Current Usage")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text("Tags Created")
                                Spacer()
                                Text("\(subscriptionManager.tagCount)/\(subscriptionManager.maxFreeTags)")
                                    .fontWeight(.bold)
                            }
                            
                            ProgressView(value: Double(subscriptionManager.tagCount), total: Double(subscriptionManager.maxFreeTags))
                                .tint(.blue)
                            
                            if subscriptionManager.tagCount >= subscriptionManager.maxFreeTags {
                                Text("You've reached your free limit!")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            } else {
                                Text("\(subscriptionManager.maxFreeTags - subscriptionManager.tagCount) tags remaining")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                    
                    // Purchase Button
                    VStack(spacing: 16) {
                        Button(action: purchasePremium) {
                            HStack {
                                if isPurchasing {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .foregroundColor(.white)
                                } else {
                                    Image(systemName: "crown.fill")
                                }
                                Text(isPurchasing ? "Processing..." : "Start Free Trial")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(isPurchasing)
                        
                        Button(action: restorePurchases) {
                            Text("Restore Purchases")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Terms
                    VStack(spacing: 8) {
                        Text("By subscribing, you agree to our Terms of Service and Privacy Policy")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        HStack(spacing: 20) {
                            Button("Terms of Service") {
                                // Open terms
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                            
                            Button("Privacy Policy") {
                                // Open privacy
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Premium")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func purchasePremium() {
        isPurchasing = true
        subscriptionManager.purchasePremium()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isPurchasing = false
            dismiss()
        }
    }
    
    private func restorePurchases() {
        subscriptionManager.restorePurchases()
    }
}

struct PremiumFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let isPremium: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(isPremium ? .blue : .gray)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isPremium {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
    }
}

#Preview {
    PaywallView(subscriptionManager: SubscriptionManager())
}
