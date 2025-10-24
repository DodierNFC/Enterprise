//
//  TagDetailView.swift
//  NFC Business Management
//
//  Created by Dodier NFC on 10/16/25.
//

import SwiftUI
import MapKit

struct TagDetailView: View {
    let tag: NFCTag
    @ObservedObject var tagManager: NFCTagManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditView = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: tag.tagType.icon)
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text(tag.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        HStack {
                            Text(tag.tagType.rawValue)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(6)
                            
                            if tag.isLocked {
                                HStack {
                                    Image(systemName: "lock.fill")
                                    Text(tag.securityLevel.rawValue)
                                }
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.orange.opacity(0.1))
                                .foregroundColor(.orange)
                                .cornerRadius(6)
                            }
                        }
                    }
                    .padding()
                    
                    // URL Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("URL")
                            .font(.headline)
                        Text(tag.url)
                            .font(.body)
                            .foregroundColor(.blue)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        
                        Button(action: copyURL) {
                            HStack {
                                Image(systemName: "doc.on.doc")
                                Text("Copy URL")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                    }
                    
                    // Notes Section
                    if !tag.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Notes")
                                .font(.headline)
                            Text(tag.notes)
                                .font(.body)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                    }
                    
                    // Location Section
                    if let location = tag.location {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Location")
                                .font(.headline)
                            
                            Map(coordinateRegion: .constant(MKCoordinateRegion(
                                center: location,
                                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                            )), annotationItems: [MapAnnotation(coordinate: location)]) { _ in
                                MapPin(coordinate: location, tint: .red)
                            }
                            .frame(height: 200)
                            .cornerRadius(8)
                            
                            if let locationName = tag.locationName {
                                Text("📍 \(locationName)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Statistics Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Statistics")
                            .font(.headline)
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text("Created:")
                                Spacer()
                                Text(tag.createdAt, style: .date)
                                    .fontWeight(.medium)
                            }
                            
                            HStack {
                                Text("Access Count:")
                                Spacer()
                                Text("\(tag.accessCount)")
                                    .fontWeight(.medium)
                            }
                            
                            if let lastAccess = tag.lastAccessed {
                                HStack {
                                    Text("Last Accessed:")
                                    Spacer()
                                    Text(lastAccess, style: .relative)
                                        .fontWeight(.medium)
                                }
                            }
                            
                            HStack {
                                Text("Capacity:")
                                Spacer()
                                Text(tag.tagType.capacity)
                                    .fontWeight(.medium)
                            }
                        }
                        .font(.caption)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: { showingEditView = true }) {
                            HStack {
                                Image(systemName: "pencil")
                                Text("Edit Tag")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        
                        Button(action: { showingDeleteAlert = true }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete Tag")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Tag Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditView) {
            EditTagView(tag: tag, tagManager: tagManager)
        }
        .alert("Delete Tag", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                tagManager.deleteTag(tag)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this tag? This action cannot be undone.")
        }
    }
    
    private func copyURL() {
        UIPasteboard.general.string = tag.url
        // Could add a toast notification here
    }
}

struct MapAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

#Preview {
    let sampleTag = NFCTag(name: "Business Card", url: "https://dodiernfc.com")
    return TagDetailView(tag: sampleTag, tagManager: NFCTagManager())
}
