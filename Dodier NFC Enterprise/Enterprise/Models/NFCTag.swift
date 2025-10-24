//
//  NFCTag.swift
//  NFC Business Management
//
//  Created by Dodier NFC on 10/16/25.
//

import Foundation
import CoreLocation

enum NFCTagType: String, CaseIterable, Codable {
    case ntag213 = "NTAG213"
    case ntag215 = "NTAG215" 
    case ntag216 = "NTAG216"
    case ntag210 = "NTAG210"
    case mifareClassic = "MIFARE Classic"
    case unknown = "Unknown"
    
    var capacity: String {
        switch self {
        case .ntag213: return "144 bytes"
        case .ntag215: return "504 bytes"
        case .ntag216: return "924 bytes"
        case .ntag210: return "48 bytes"
        case .mifareClassic: return "1KB"
        case .unknown: return "Unknown"
        }
    }
    
    var icon: String {
        switch self {
        case .ntag213: return "tag.fill"
        case .ntag215: return "tag.circle.fill"
        case .ntag216: return "tag.square.fill"
        case .ntag210: return "tag"
        case .mifareClassic: return "creditcard.fill"
        case .unknown: return "questionmark.circle.fill"
        }
    }
}

enum TagSecurityLevel: String, CaseIterable, Codable {
    case unlocked = "Unlocked"
    case locked = "Locked"
    case passwordProtected = "Password Protected"
    case readOnly = "Read Only"
}

struct NFCTag: Identifiable, Codable {
    let id = UUID()
    var name: String
    var url: String
    var notes: String
    var tagType: NFCTagType
    var securityLevel: TagSecurityLevel
    var password: String?
    var createdAt: Date
    var location: CLLocationCoordinate2D?
    var locationName: String?
    var isLocked: Bool
    var lastAccessed: Date?
    var accessCount: Int
    
    init(name: String, url: String, tagType: NFCTagType = .ntag213) {
        self.name = name
        self.url = url
        self.notes = ""
        self.tagType = tagType
        self.securityLevel = .unlocked
        self.password = nil
        self.createdAt = Date()
        self.location = nil
        self.locationName = nil
        self.isLocked = false
        self.lastAccessed = nil
        self.accessCount = 0
    }
}

// MARK: - CLLocationCoordinate2D Codable Extension
extension CLLocationCoordinate2D: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
    
    private enum CodingKeys: String, CodingKey {
        case latitude, longitude
    }
}
