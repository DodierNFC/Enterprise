//
//  AddTagView.swift
//  NFC Business Management
//
//  Created by Dodier NFC on 10/16/25.
//

import SwiftUI

struct AddTagView: View {
    @ObservedObject var tagManager: NFCTagManager
    @ObservedObject var subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var tagName = ""
    @State private var tagURL = ""
    @State private var tagNotes = ""
    @State private var selectedTagType: NFCTagType = .ntag213
    @State private var password = ""
    @State private var shouldLock = false
    @State private var usePassword = false
    @State private var isWriting = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "tag.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        Text("Create New NFC Tag")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding(.top)
                    
                    VStack(spacing: 20) {
                        // Tag Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tag Name")
                                .font(.headline)
                            TextField("Enter a name for this tag", text: $tagName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        // URL
                        VStack(alignment: .leading, spacing: 8) {
                            Text("URL")
                                .font(.headline)
                            TextField("https://example.com", text: $tagURL)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.URL)
                                .autocapitalization(.none)
                        }
                        
                        // Tag Type
                        VStack(alignment: .leading, spacing: 8) {
                            Text("NFC Tag Type")
                                .font(.headline)
                            Picker("Tag Type", selection: $selectedTagType) {
                                ForEach(NFCTagType.allCases, id: \.self) { type in
                                    HStack {
                                        Image(systemName: type.icon)
                                        Text("\(type.rawValue) (\(type.capacity))")
                                    }
                                    .tag(type)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        
                        // Notes
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes (Optional)")
                                .font(.headline)
                            TextField("Add notes about this tag...", text: $tagNotes, axis: .vertical)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .lineLimit(3...6)
                        }
                        
                        // Security Options
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Security Options")
                                    .font(.headline)
                                
                                if !subscriptionManager.canLockTag() {
                                    Spacer()
                                    Button("Premium") {
                                        // Show paywall
                                    }
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.yellow)
                                    .foregroundColor(.black)
                                    .cornerRadius(4)
                                }
                            }
                            
                            Toggle("Lock tag after writing", isOn: $shouldLock)
                                .toggleStyle(SwitchToggleStyle(tint: .orange))
                                .disabled(!subscriptionManager.canLockTag())
                            
                            if shouldLock {
                                Toggle("Use password protection", isOn: $usePassword)
                                    .toggleStyle(SwitchToggleStyle(tint: .red))
                                
                                if usePassword {
                                    SecureField("Enter password", text: $password)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                            }
                            
                            if !subscriptionManager.canLockTag() {
                                Text("Tag locking is a premium feature. Upgrade to secure your tags.")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                    .padding(.top, 4)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // Write Button
                        Button(action: writeTag) {
                            HStack {
                                if isWriting {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .foregroundColor(.white)
                                } else {
                                    Image(systemName: "nfc")
                                }
                                Text(isWriting ? "Writing to NFC..." : "Write to NFC Tag")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isValidInput ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(!isValidInput || isWriting)
                        
                        // Tag Info
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tag Information")
                                .font(.headline)
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("Capacity:")
                                    Spacer()
                                    Text(selectedTagType.capacity)
                                        .fontWeight(.medium)
                                }
                                HStack {
                                    Text("Security:")
                                    Spacer()
                                    Text(shouldLock ? (usePassword ? "Password Protected" : "Locked") : "Unlocked")
                                        .fontWeight(.medium)
                                        .foregroundColor(shouldLock ? .orange : .green)
                                }
                            }
                            .font(.caption)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("New Tag")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var isValidInput: Bool {
        !tagName.isEmpty && !tagURL.isEmpty && URL(string: tagURL) != nil
    }
    
    private func writeTag() {
        isWriting = true
        
        // Simulate NFC writing process
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            tagManager.addTag(
                name: tagName,
                url: tagURL,
                tagType: selectedTagType,
                notes: tagNotes,
                password: usePassword ? password : nil,
                shouldLock: shouldLock
            )
            
            isWriting = false
            dismiss()
        }
    }
}

#Preview {
    AddTagView(tagManager: NFCTagManager(), subscriptionManager: SubscriptionManager())
}
