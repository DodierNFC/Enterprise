//
//  NFCTagManager.swift
//  NFC Business Management
//
//  Created by Dodier NFC on 10/16/25.
//

import Foundation
import CoreLocation
import SwiftUI
import Combine

class NFCTagManager: ObservableObject {
    @Published var tags: [NFCTag] = []
    @Published var selectedTag: NFCTag?
    @Published var isWriting = false
    @Published var alertMessage: AlertMessage?
    
    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocationCoordinate2D?
    private let subscriptionManager: SubscriptionManager
    
    init(subscriptionManager: SubscriptionManager = SubscriptionManager()) {
        self.subscriptionManager = subscriptionManager
        setupLocationManager()
        loadTags()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func addTag(name: String, url: String, tagType: NFCTagType, notes: String = "", password: String? = nil, shouldLock: Bool = false) {
        // Check if user can create more tags
        if !subscriptionManager.canCreateTag() {
            alertMessage = AlertMessage(
                title: "Tag Limit Reached",
                message: "You've reached your free limit of \(subscriptionManager.maxFreeTags) tags. Upgrade to Premium for unlimited tags."
            )
            return
        }
        
        // Check if user can lock tags (premium feature)
        if shouldLock && !subscriptionManager.canLockTag() {
            alertMessage = AlertMessage(
                title: "Premium Feature",
                message: "Tag locking is a premium feature. Upgrade to Premium to secure your tags."
            )
            return
        }
        
        var newTag = NFCTag(name: name, url: url, tagType: tagType)
        newTag.notes = notes
        newTag.password = password
        newTag.isLocked = shouldLock
        newTag.location = currentLocation
        newTag.locationName = getCurrentLocationName()
        
        if shouldLock {
            newTag.securityLevel = password != nil ? .passwordProtected : .locked
        }
        
        tags.append(newTag)
        subscriptionManager.incrementTagCount()
        saveTags()
    }
    
    func updateTag(_ tag: NFCTag) {
        if let index = tags.firstIndex(where: { $0.id == tag.id }) {
            tags[index] = tag
            saveTags()
        }
    }
    
    func deleteTag(_ tag: NFCTag) {
        tags.removeAll { $0.id == tag.id }
        subscriptionManager.decrementTagCount()
        saveTags()
    }
    
    func recordTagAccess(_ tag: NFCTag) {
        if let index = tags.firstIndex(where: { $0.id == tag.id }) {
            tags[index].lastAccessed = Date()
            tags[index].accessCount += 1
            saveTags()
        }
    }
    
    private func getCurrentLocationName() -> String? {
        // This would typically use reverse geocoding
        // For now, return a placeholder
        return "Current Location"
    }
    
    private func saveTags() {
        if let encoded = try? JSONEncoder().encode(tags) {
            UserDefaults.standard.set(encoded, forKey: "SavedNFCTags")
        }
    }
    
    private func loadTags() {
        if let data = UserDefaults.standard.data(forKey: "SavedNFCTags"),
           let decoded = try? JSONDecoder().decode([NFCTag].self, from: data) {
            tags = decoded
        }
    }
    
    // MARK: - Analytics
    var totalTags: Int {
        tags.count
    }
    
    var lockedTags: Int {
        tags.filter { $0.isLocked }.count
    }
    
    var mostUsedTag: NFCTag? {
        tags.max { $0.accessCount < $1.accessCount }
    }
    
    var tagsByType: [NFCTagType: Int] {
        Dictionary(grouping: tags, by: { $0.tagType }).mapValues { $0.count }
    }
}

// MARK: - CLLocationManagerDelegate
extension NFCTagManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}
