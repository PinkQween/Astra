//
//  AccessorySetupKitManager.swift
//  Astra
//
//  Created by Hanna Skairipa on 3/17/25.
//

import AccessorySetupKit
import CoreBluetooth
import UIKit
import os

/// Manages the discovery and connection of accessories using AccessorySetupKit.
class AccessorySetupKitManager: ObservableObject {
    
    /// Shared logger instance for debugging and error reporting.
    private let logger = Logger(subsystem: "com.yourapp.astra", category: "AccessorySetupKit")
    
    /// The accessory session for managing device connections.
    @Published private(set) var session: ASAccessorySession
    
    /// Descriptor used to define accessory discovery parameters.
    private let deviceDescriptor: ASDiscoveryDescriptor
    
    /// Stores any error messages from the accessory session.
    @Published var lastError: String?
    
    /// Initializes the accessory session and sets up event handling.
    init() {
        session = ASAccessorySession()
        deviceDescriptor = ASDiscoveryDescriptor()
        
        // Activate session and handle events
        session.activate(on: .main, eventHandler: { [weak self] event in
            self?.handleSessionEvent(event)
        })
    }
    
    /// Handles events from the AccessorySetupKit session.
    /// - Parameter event: The event received from the accessory session.
    private func handleSessionEvent(_ event: ASAccessoryEvent) {
        switch event.eventType {
        case .activated:
            logger.info("Session activated. Available accessories: \(self.session.accessories.count)")
            
        case .accessoryAdded:
            if let newAccessory = event.accessory {
                logger.info("New accessory added: \(newAccessory)")
            }
            
        case .accessoryChanged:
            logger.info("Accessory properties changed.")
            
        case .accessoryRemoved:
            logger.info("Accessory removed.")
            
        case .pickerDidPresent:
            logger.info("Picker presented.")
            
        case .pickerDidDismiss:
            logger.info("Picker dismissed.")
            
        case .pickerSetupFailed:
            lastError = "Accessory picker setup failed."
            logger.error("Picker setup failed.")
            
        case .migrationComplete:
            logger.info("Migration of accessory completed.")
            
        default:
            logger.warning("Unknown event: \(event.eventType.rawValue)")
        }
    }
    
    /// Displays the accessory picker for users to select an accessory.
    ///
    /// This method presents a picker allowing users to select a Bluetooth accessory.
    /// It configures the picker with a descriptor for the accessory and an associated display image.
    /// If the system image fails to load, an error is logged and displayed.
    ///
    /// - Note: Ensure that the Bluetooth UUID is correctly set before invoking this method.
    func showAccessoryPicker() {
        let POWDRDescriptor = ASDiscoveryDescriptor()
        POWDRDescriptor.bluetoothServiceUUID = CBUUID(string: "12345678-1234-5678-1234-56789abcdef0") // Replace with actual UUID
        
        guard let skiingIcon = UIImage(systemName: "figure.skiing.downhill") else {
            lastError = "Failed to load system image for accessory picker."
            logger.error("Failed to load system image for accessory picker.")
            return
        }
        
        let pinkDisplayItem = ASPickerDisplayItem(
            name: "P.O.W.D.R",
            productImage: skiingIcon,
            descriptor: POWDRDescriptor
        )
        
        session.showPicker(for: [pinkDisplayItem]) { [weak self] error in
            if let error = error {
                self?.lastError = error.localizedDescription
                self?.logger.error("Error showing picker: \(error.localizedDescription)")
            }
        }
    }
}
