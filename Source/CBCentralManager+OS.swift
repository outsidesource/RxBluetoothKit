//
//  CBCentralManager+OS.swift
//  Klipsch-Connect
//
//  Created by Brody Robertson on 7/1/20.
//  Copyright © 2020 Klipsch. All rights reserved.
//

import Foundation
import CoreBluetooth

public class CBCentralManagerDelegateBox: NSObject, CBCentralManagerDelegate {
    
    var delegates: [CBCentralManagerDelegate] = []
    
    func addDelegate(_ delegate: CBCentralManagerDelegate) {
        
        /// Guard against duplicate delegate
        guard !delegates.contains(where: { existingDelegate -> Bool in
            /// Leverage NSObjectProtocol
            return existingDelegate.isEqual(delegate)
        }) else {
            return
        }
        
        self.delegates.append(delegate)
        
    }
    
    func removeDelegate(_ delegate: CBCentralManagerDelegate) {
        
        /// Guard against duplicate delegate
        delegates.removeAll { existingDelegate -> Bool in
            /// Leverage NSObjectProtocol
            existingDelegate.isEqual(delegate)
        }
        
    }
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        delegates.forEach {
            $0.centralManagerDidUpdateState(central)
        }
    }
    
    public func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        delegates.forEach {
            $0.centralManager?(central, willRestoreState: dict)
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        delegates.forEach {
            $0.centralManager?(central, didDiscover: peripheral, advertisementData: advertisementData, rssi: RSSI)
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        delegates.forEach {
            $0.centralManager?(central, didConnect: peripheral)
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        delegates.forEach {
            $0.centralManager?(central, didFailToConnect: peripheral, error: error)
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        delegates.forEach {
            $0.centralManager?(central, didDisconnectPeripheral: peripheral, error: error)
        }
    }
    
    public func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral) {
        delegates.forEach {
            if #available(iOS 13.0, *) {
                $0.centralManager?(central, connectionEventDidOccur: event, for: peripheral)
            }
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didUpdateANCSAuthorizationFor peripheral: CBPeripheral) {
        delegates.forEach {
            if #available(iOS 13.0, *) {
                $0.centralManager?(central, didUpdateANCSAuthorizationFor: peripheral)
            }
        }
    }
    
}

public extension CBCentralManager {
    
    static var delegateBoxes = [Int:CBCentralManagerDelegateBox]()
    
    /// Returns array of CBCentralManagerDelegate using extension hack
    private var delegateBox: CBCentralManagerDelegateBox? {

        get {
            return CBCentralManager.delegateBoxes[self.hash]
        }

        set(newValue) {
            CBCentralManager.delegateBoxes[self.hash] = newValue
            self.delegate = newValue
        }
    }

    func addDelegate(_ delegate: CBCentralManagerDelegate) {

        if let delegateBox = self.delegateBox {
            delegateBox.addDelegate(delegate)
        } else {
            let delgateBoxes = CBCentralManager.delegateBoxes
            let delegateBox = CBCentralManagerDelegateBox()
            delegateBox.addDelegate(delegate)
            self.delegateBox = delegateBox
        }

    }

    func removeDelegate(_ delegate: CBCentralManagerDelegate) {

        guard let delegateBox = self.delegateBox else {
            return
        }
        
        delegateBox.removeDelegate(delegate)
        
    }
}
