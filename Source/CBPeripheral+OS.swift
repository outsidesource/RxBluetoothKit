//
//  CBPeripheral+OS.swift
//  Klipsch-Connect
//
//  Created by Brody Robertson on 7/6/20.
//  Copyright © 2020 Klipsch. All rights reserved.
//

import Foundation
import CoreBluetooth

public class CBPeripheralDelegateBox: NSObject, CBPeripheralDelegate {
    
    var delegates: [CBPeripheralDelegate] = []
    
    func addDelegate(_ delegate: CBPeripheralDelegate) {
        
        /// Guard against duplicate delegate
        guard !delegates.contains(where: { existingDelegate -> Bool in
            /// Leverage NSObjectProtocol
            return existingDelegate.isEqual(delegate)
        }) else {
            return
        }
        
        self.delegates.append(delegate)
        
    }
    
    func removeDelegate(_ delegate: CBPeripheralDelegate) {
        
        /// Guard against duplicate delegate
        delegates.removeAll { existingDelegate -> Bool in
            /// Leverage NSObjectProtocol
            existingDelegate.isEqual(delegate)
        }
        
    }
    
    public func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        delegates.forEach {
            $0.peripheralDidUpdateName?(peripheral)
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        delegates.forEach {
            $0.peripheral?(peripheral, didModifyServices: invalidatedServices)
        }
    }

    /// Deprecated in iOS 8.0
//    public func peripheralDidUpdateRSSI(_ peripheral: CBPeripheral, error: Error?) {
//        delegates.forEach {
//            $0.peripheralDidUpdateRSSI?(peripheral, error: error)
//        }
//    }

    @available(OSX 10.13, *)
    public func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        delegates.forEach {
            $0.peripheral?(peripheral, didReadRSSI: RSSI, error: error)
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        delegates.forEach {
            $0.peripheral?(peripheral, didDiscoverServices: error)
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
        delegates.forEach {
            $0.peripheral?(peripheral, didDiscoverIncludedServicesFor: service, error: error)
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        delegates.forEach {
            $0.peripheral?(peripheral, didDiscoverCharacteristicsFor: service, error: error)
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        delegates.forEach {
            $0.peripheral?(peripheral, didUpdateValueFor: characteristic, error: error)
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        delegates.forEach {
            $0.peripheral?(peripheral, didWriteValueFor: characteristic, error: error)
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        delegates.forEach {
            $0.peripheral?(peripheral, didUpdateNotificationStateFor: characteristic, error: error)
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        delegates.forEach {
            $0.peripheral?(peripheral, didDiscoverDescriptorsFor: characteristic, error: error)
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        delegates.forEach {
            $0.peripheral?(peripheral, didUpdateValueFor: descriptor, error: error)
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        delegates.forEach {
            $0.peripheral?(peripheral, didWriteValueFor: descriptor, error: error)
        }
    }

    public func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        delegates.forEach {
            $0.peripheralIsReady?(toSendWriteWithoutResponse: peripheral)
        }
    }

    @available(OSX 10.13, *)
    @available(iOS 11.0, *)
    public func peripheral(_ peripheral: CBPeripheral, didOpen channel: CBL2CAPChannel?, error: Error?) {
        delegates.forEach {
            $0.peripheral?(peripheral, didOpen: channel, error: error)
        }
    }
    
}

public extension CBPeripheral {
    
    static var delegateBoxes = [Int:CBPeripheralDelegateBox]()
    
    /// Returns array of CBPeripheralDelegate using extension hack
    private var delegateBox: CBPeripheralDelegateBox? {

        get {
            return CBPeripheral.delegateBoxes[self.hash]
        }

        set(newValue) {
            CBPeripheral.delegateBoxes[self.hash] = newValue
            self.delegate = newValue
        }
    }

    @objc func addDelegate(_ delegate: CBPeripheralDelegate) {

        if let delegateBox = self.delegateBox {
            delegateBox.addDelegate(delegate)
        } else {
            let delegateBox = CBPeripheralDelegateBox()
            delegateBox.addDelegate(delegate)
            self.delegateBox = delegateBox
        }

    }

    @objc func removeDelegate(_ delegate: CBPeripheralDelegate) {

        guard let delegateBox = self.delegateBox else {
            return
        }
        
        delegateBox.removeDelegate(delegate)
        
    }
}
