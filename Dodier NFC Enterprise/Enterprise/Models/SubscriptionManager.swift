//
//  SubscriptionManager.swift
//  NFC Business Management
//
//  Created by Dodier NFC on 10/16/25.
//

import Foundation
import StoreKit
import SwiftUI

class SubscriptionManager: ObservableObject {
    @Published var isPremium = false
    @Published var subscriptionStatus: SubscriptionStatus = .free
    @Published var tagCount = 0
    @Published var maxFreeTags = 10
    
    enum SubscriptionStatus {
        case free
        case premium
        case expired
    }
    
    init() {
        loadSubscriptionStatus()
        loadTagCount()
    }
    
    // MARK: - Subscription Management
    
    func purchasePremium() {
        // In a real app, this would integrate with StoreKit
        // For demo purposes, we'll simulate the purchase
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isPremium = true
            self.subscriptionStatus = .premium
            self.saveSubscriptionStatus()
        }
    }
    
    func restorePurchases() {
        // In a real app, this would restore from App Store
        // For demo purposes, we'll check local storage
        loadSubscriptionStatus()
    }
    
    func cancelSubscription() {
        isPremium = false
        subscriptionStatus = .free
        saveSubscriptionStatus()
    }
    
    // MARK: - Tag Limits
    
    func canCreateTag() -> Bool {
        if isPremium {
            return true
        }
        return tagCount < maxFreeTags
    }
    
    func canLockTag() -> Bool {
        return isPremium
    }
    
    func incrementTagCount() {
        tagCount += 1
        saveTagCount()
    }
    
    func decrementTagCount() {
        tagCount = max(0, tagCount - 1)
        saveTagCount()
    }
    
    // MARK: - Premium Features
    
    func hasUnlimitedTags() -> Bool {
        return isPremium
    }
    
    func hasTagLocking() -> Bool {
        return isPremium
    }
    
    func hasAdvancedAnalytics() -> Bool {
        return isPremium
    }
    
    func hasCloudSync() -> Bool {
        return isPremium
    }
    
    // MARK: - Persistence
    
    private func saveSubscriptionStatus() {
        UserDefaults.standard.set(isPremium, forKey: "isPremium")
        UserDefaults.standard.set(subscriptionStatus.rawValue, forKey: "subscriptionStatus")
    }
    
    private func loadSubscriptionStatus() {
        isPremium = UserDefaults.standard.bool(forKey: "isPremium")
        let statusString = UserDefaults.standard.string(forKey: "subscriptionStatus") ?? "free"
        subscriptionStatus = SubscriptionStatus(rawValue: statusString) ?? .free
    }
    
    private func saveTagCount() {
        UserDefaults.standard.set(tagCount, forKey: "tagCount")
    }
    
    private func loadTagCount() {
        tagCount = UserDefaults.standard.integer(forKey: "tagCount")
    }
}

extension SubscriptionManager.SubscriptionStatus: RawRepresentable {
    var rawValue: String {
        switch self {
        case .free: return "free"
        case .premium: return "premium"
        case .expired: return "expired"
        }
    }
    
    init?(rawValue: String) {
        switch rawValue {
        case "free": self = .free
        case "premium": self = .premium
        case "expired": self = .expired
        default: return nil
        }
    }
}
