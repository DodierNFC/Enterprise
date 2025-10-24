//
//  TagListView.swift
//  NFC Business Management
//
//  Created by Dodier NFC on 10/16/25.
//

import SwiftUI

struct TagListView: View {
    @StateObject private var tagManager = NFCTagManager()
    @StateObject private var subscriptionManager = SubscriptionManager()
    @State private var showingAddTag = false
    @State private var showingPaywall = false
    @State private var searchText = ""
    @State private var selectedFilter: TagFilter = .all
    
    enum TagFilter: String, CaseIterable {
        case all = "All"
        case locked = "Locked"
        case unlocked = "Unlocked"
        case recent = "Recent"
    }
    
    var filteredTags: [NFCTag] {
        let filtered = tagManager.tags.filter { tag in
            let matchesSearch = searchText.isEmpty || 
                tag.name.localizedCaseInsensitiveContains(searchText) ||
                tag.url.localizedCaseInsensitiveContains(searchText) ||
                tag.notes.localizedCaseInsensitiveContains(searchText)
            
            let matchesFilter: Bool
            switch selectedFilter {
            case .all:
                matchesFilter = true
            case .locked:
                matchesFilter = tag.isLocked
            case .unlocked:
                matchesFilter = !tag.isLocked
            case .recent:
                matchesFilter = tag.createdAt > Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            }
            
            return matchesSearch && matchesFilter
        }
        
        return filtered.sorted { $0.createdAt > $1.createdAt }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with stats
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("NFC Tag Manager Pro")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                if subscriptionManager.isPremium {
                                    Image(systemName: "crown.fill")
                                        .foregroundColor(.yellow)
                                        .font(.caption)
                                }
                            }
                            
                            HStack {
                                Text("\(tagManager.totalTags) tags • \(tagManager.lockedTags) locked")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                if !subscriptionManager.isPremium {
                                    Text("• \(subscriptionManager.maxFreeTags - subscriptionManager.tagCount) remaining")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                        Spacer()
                        Button(action: { 
                            if subscriptionManager.canCreateTag() {
                                showingAddTag = true 
                            } else {
                                showingPaywall = true
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Filter tabs
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(TagFilter.allCases, id: \.self) { filter in
                                Button(action: { selectedFilter = filter }) {
                                    Text(filter.rawValue)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(selectedFilter == filter ? Color.blue : Color.gray.opacity(0.2))
                                        .foregroundColor(selectedFilter == filter ? .white : .primary)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
                .background(Color(.systemBackground))
                
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search tags...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Tags list
                if filteredTags.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "tag")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No tags found")
                            .font(.title3)
                            .fontWeight(.medium)
                        Text("Create your first NFC tag to get started")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredTags) { tag in
                                TagRowView(tag: tag, tagManager: tagManager)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingAddTag) {
            AddTagView(tagManager: tagManager, subscriptionManager: subscriptionManager)
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView(subscriptionManager: subscriptionManager)
        }
    }
}

struct TagRowView: View {
    let tag: NFCTag
    @ObservedObject var tagManager: NFCTagManager
    @State private var showingDetails = false
    
    var body: some View {
        Button(action: { showingDetails = true }) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: tag.tagType.icon)
                                .foregroundColor(.blue)
                            Text(tag.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Spacer()
                            if tag.isLocked {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.orange)
                            }
                        }
                        
                        Text(tag.url)
                            .font(.caption)
                            .foregroundColor(.blue)
                            .lineLimit(1)
                        
                        HStack {
                            Text(tag.tagType.rawValue)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(4)
                            
                            if let location = tag.locationName {
                                Text("📍 \(location)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text(tag.createdAt, style: .date)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                if !tag.notes.isEmpty {
                    Text(tag.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack {
                    Text("Access count: \(tag.accessCount)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if let lastAccess = tag.lastAccessed {
                        Text("Last: \(lastAccess, style: .relative)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetails) {
            TagDetailView(tag: tag, tagManager: tagManager)
        }
    }
}

#Preview {
    TagListView()
}
