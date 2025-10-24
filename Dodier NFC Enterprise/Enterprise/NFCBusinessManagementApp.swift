//
//  NFCBusinessManagementApp.swift
//  NFC Tag Manager Pro
//
//  Created by Dodier NFC on 10/16/25.
//

import SwiftUI

@main
struct NFCBusinessManagementApp: App {
    @StateObject private var tagManager = NFCTagManager()
    @StateObject private var subscriptionManager = SubscriptionManager()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                TagListView()
                    .tabItem {
                        Image(systemName: "tag")
                        Text("Tags")
                    }
                
                AnalyticsView(tagManager: tagManager)
                    .tabItem {
                        Image(systemName: "chart.bar")
                        Text("Analytics")
                    }
                
                SettingsView(subscriptionManager: subscriptionManager)
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
            }
            .environmentObject(tagManager)
            .environmentObject(subscriptionManager)
        }
    }
}

struct SettingsView: View {
    @ObservedObject var subscriptionManager: SubscriptionManager
    @State private var showingPaywall = false
    
    var body: some View {
        NavigationView {
            List {
                Section("Account") {
                    HStack {
                        Image(systemName: subscriptionManager.isPremium ? "crown.fill" : "person.circle.fill")
                            .foregroundColor(subscriptionManager.isPremium ? .yellow : .blue)
                        Text(subscriptionManager.isPremium ? "Premium Account" : "Free Account")
                        Spacer()
                        Text(subscriptionManager.isPremium ? "Active" : "Upgrade")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(subscriptionManager.isPremium ? Color.green : Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                    
                    if !subscriptionManager.isPremium {
                        Button(action: { showingPaywall = true }) {
                            HStack {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(.yellow)
                                Text("Upgrade to Premium")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
                
                Section("Features") {
                    SettingsRow(icon: "lock.fill", title: "Tag Security", subtitle: subscriptionManager.isPremium ? "Password protection & locking" : "Premium feature")
                    SettingsRow(icon: "location.fill", title: "Location Tracking", subtitle: subscriptionManager.isPremium ? "Track where tags were created" : "Premium feature")
                    SettingsRow(icon: "chart.bar.fill", title: "Analytics", subtitle: subscriptionManager.isPremium ? "Detailed usage statistics" : "Premium feature")
                    SettingsRow(icon: "icloud.fill", title: "Cloud Sync", subtitle: subscriptionManager.isPremium ? "Sync across devices" : "Premium feature")
                }
                
                Section("Support") {
                    SettingsRow(icon: "questionmark.circle.fill", title: "Help & Support", subtitle: "Get help with your tags")
                    SettingsRow(icon: "star.fill", title: "Rate App", subtitle: "Rate us on the App Store")
                    SettingsRow(icon: "envelope.fill", title: "Contact Us", subtitle: "Get in touch")
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView(subscriptionManager: subscriptionManager)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    NFCBusinessManagementApp()
}
