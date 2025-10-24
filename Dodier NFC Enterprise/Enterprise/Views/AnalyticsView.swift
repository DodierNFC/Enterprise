//
//  AnalyticsView.swift
//  NFC Business Management
//
//  Created by Dodier NFC on 10/16/25.
//

import SwiftUI
import Charts

struct AnalyticsView: View {
    @ObservedObject var tagManager: NFCTagManager
    @State private var selectedTimeframe: Timeframe = .all
    
    enum Timeframe: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
        case all = "All Time"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Analytics Dashboard")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Track your NFC tag performance")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    // Timeframe Picker
                    Picker("Timeframe", selection: $selectedTimeframe) {
                        ForEach(Timeframe.allCases, id: \.self) { timeframe in
                            Text(timeframe.rawValue).tag(timeframe)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // Overview Cards
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        StatCard(
                            title: "Total Tags",
                            value: "\(tagManager.totalTags)",
                            icon: "tag.fill",
                            color: .blue
                        )
                        
                        StatCard(
                            title: "Locked Tags",
                            value: "\(tagManager.lockedTags)",
                            icon: "lock.fill",
                            color: .orange
                        )
                        
                        StatCard(
                            title: "Most Used",
                            value: tagManager.mostUsedTag?.name ?? "None",
                            icon: "star.fill",
                            color: .yellow
                        )
                        
                        StatCard(
                            title: "Access Count",
                            value: "\(tagManager.tags.reduce(0) { $0 + $1.accessCount })",
                            icon: "chart.line.uptrend.xyaxis",
                            color: .green
                        )
                    }
                    .padding(.horizontal)
                    
                    // Tag Type Distribution
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Tag Type Distribution")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if !tagManager.tagsByType.isEmpty {
                            VStack(spacing: 12) {
                                ForEach(Array(tagManager.tagsByType.keys.sorted()), id: \.self) { tagType in
                                    HStack {
                                        Image(systemName: tagType.icon)
                                            .foregroundColor(.blue)
                                            .frame(width: 20)
                                        
                                        Text(tagType.rawValue)
                                            .font(.body)
                                        
                                        Spacer()
                                        
                                        Text("\(tagManager.tagsByType[tagType] ?? 0)")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }
                    
                    // Recent Activity
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recent Activity")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            ForEach(tagManager.tags.sorted { $0.createdAt > $1.createdAt }.prefix(5)) { tag in
                                HStack {
                                    Image(systemName: tag.tagType.icon)
                                        .foregroundColor(.blue)
                                        .frame(width: 20)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(tag.name)
                                            .font(.body)
                                            .fontWeight(.medium)
                                        Text("Created \(tag.createdAt, style: .relative)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    if tag.isLocked {
                                        Image(systemName: "lock.fill")
                                            .foregroundColor(.orange)
                                            .font(.caption)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    // Security Overview
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Security Overview")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            SecurityStatRow(
                                title: "Unlocked Tags",
                                count: tagManager.tags.filter { !$0.isLocked }.count,
                                color: .green
                            )
                            
                            SecurityStatRow(
                                title: "Locked Tags",
                                count: tagManager.tags.filter { $0.isLocked && $0.securityLevel == .locked }.count,
                                color: .orange
                            )
                            
                            SecurityStatRow(
                                title: "Password Protected",
                                count: tagManager.tags.filter { $0.securityLevel == .passwordProtected }.count,
                                color: .red
                            )
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct SecurityStatRow: View {
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text(title)
                .font(.body)
            
            Spacer()
            
            Text("\(count)")
                .font(.headline)
                .fontWeight(.bold)
        }
    }
}

#Preview {
    AnalyticsView(tagManager: NFCTagManager())
}
