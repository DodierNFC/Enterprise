//
//  QRNFCViewModel.swift
//  ReplaceYourQRCodes
//
//  Created by Dodier NFC on 10/16/25.
//

import Foundation
import SwiftUI
import Combine
import CoreNFC
import AVFoundation

class QRNFCViewModel: NSObject, ObservableObject {
    @Published var isScanning = false
    @Published var detectedURL: String?
    @Published var alertMessage: AlertMessage?
    @Published var isWritingNFC = false
    
    private var nfcSession: NFCNDEFReaderSession?
    
    override init() {
        super.init()
    }
    
    func startScanning() {
        detectedURL = nil
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch authorizationStatus {
        case .authorized:
            isScanning = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.isScanning = true
                    } else {
                        self.alertMessage = AlertMessage(
                            title: "Camera Access Denied",
                            message: "Enable Camera in Settings to scan QR codes."
                        )
                    }
                }
            }
        case .denied, .restricted:
            alertMessage = AlertMessage(
                title: "Camera Access Needed",
                message: "Please allow Camera access in Settings to scan QR codes."
            )
        @unknown default:
            alertMessage = AlertMessage(
                title: "Camera Error",
                message: "Unknown camera authorization status."
            )
        }
    }
    
    func stopScanning() {
        isScanning = false
    }
    
    func onQRCodeDetected(url: String) {
        if isValidURL(url) {
            detectedURL = url
            stopScanning()
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            alertMessage = AlertMessage(
                title: "QR Code Detected",
                message: "URL found: \(url)"
            )
        } else {
            alertMessage = AlertMessage(
                title: "Invalid QR Code",
                message: "The scanned QR code does not contain a valid URL"
            )
        }
    }
    
    func writeToNFC() {
        guard detectedURL != nil else { return }
        if !NFCNDEFReaderSession.readingAvailable {
            alertMessage = AlertMessage(
                title: "NFC Not Available",
                message: "NFC not available. Use a real device with NFC and ensure capability is enabled."
            )
            return
        }
        
        isWritingNFC = true
        DispatchQueue.main.async {
            self.nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
            self.nfcSession?.alertMessage = "Hold your iPhone near the NFC tag"
            self.nfcSession?.begin()
        }
    }
    
    private func isValidURL(_ string: String) -> Bool {
        guard let url = URL(string: string) else { return false }
        return url.scheme == "http" || url.scheme == "https"
    }
}

extension QRNFCViewModel: NFCNDEFReaderSessionDelegate {
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        guard tags.count == 1, let tag = tags.first else {
            session.alertMessage = "Please present only one tag"
            session.invalidate()
            return
        }
        
        session.connect(to: tag) { error in
            if error != nil {
                session.alertMessage = "Connection error. Please try again."
                session.invalidate()
                return
            }
            
            tag.queryNDEFStatus { status, capacity, error in
                guard error == nil else {
                    session.alertMessage = "Unable to query tag. Please try again."
                    session.invalidate()
                    return
                }
                
                switch status {
                case .notSupported:
                    session.alertMessage = "Tag is not NDEF compliant"
                    session.invalidate()
                case .readOnly:
                    session.alertMessage = "Tag is read-only"
                    session.invalidate()
                case .readWrite:
                    self.writeURL(to: tag, session: session)
                @unknown default:
                    session.alertMessage = "Unknown tag status"
                    session.invalidate()
                }
            }
        }
    }
    
    private func writeURL(to tag: NFCNDEFTag, session: NFCNDEFReaderSession) {
        guard let urlString = detectedURL,
              let url = URL(string: urlString),
              let payload = NFCNDEFPayload.wellKnownTypeURIPayload(url: url) else {
            session.alertMessage = "Invalid URL format"
            session.invalidate()
            return
        }
        
        let message = NFCNDEFMessage(records: [payload])
        
        tag.writeNDEF(message) { error in
            if error != nil {
                session.alertMessage = "Write error. Please try again."
                session.invalidate()
                DispatchQueue.main.async {
                    self.isWritingNFC = false
                    self.alertMessage = AlertMessage(
                        title: "Write Failed",
                        message: "Failed to write URL to NFC tag. Please try again."
                    )
                }
            } else {
                session.alertMessage = "Successfully written URL to NFC tag!"
                session.invalidate()
                
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                
                DispatchQueue.main.async {
                    self.isWritingNFC = false
                    self.alertMessage = AlertMessage(
                        title: "Success",
                        message: "URL successfully written to NFC tag!"
                    )
                    self.detectedURL = nil
                }
            }
        }
    }
    
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        DispatchQueue.main.async {
            self.isWritingNFC = false
            self.nfcSession = nil
            // Provide a friendly message if the user canceled
            if let nfcError = error as? NFCReaderError, nfcError.code == .readerSessionInvalidationErrorUserCanceled {
                self.alertMessage = nil
            }
        }
    }
}
