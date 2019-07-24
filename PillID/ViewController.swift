//
//  ViewController.swift
//  PillID
//
//  Created by Shruti Sharma on 7/22/19.
//  Copyright © 2019 Shruti Sharma. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController,CBCentralManagerDelegate,
CBPeripheralDelegate {
    var manager:CBCentralManager!
    var peripheral:CBPeripheral!
    
    let binary_bluethooth_name = "AB Shutter3"
    let binary_bluetooth_service = CBUUID(string: "0x183B")
    let binary_bluetooth_characteristic = CBUUID(string: "2131")
    
    let number_of_pictures = 16
    
    // 1. to check availability of bluethooth and scan for
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            print ("Bluetooth is available")
            print ("Scanning for devices")
            central.scanForPeripherals(withServices: nil, options: nil)
        } else {
            print ("Bluetooth in invalid state \(central.state)")
            print("Bluetooth not available.")
        }
    }
    
    // 2. Connect to bluetooth device
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print ("Discovered Devices")
//        guard peripheral.name != nil && peripheral.name?.starts(with: self.binary_bluethooth_name) ?? false else { return }
        print("\(peripheral)")
        
        if (peripheral.identifier.uuidString == binary_bluetooth_service.uuidString) {
            self.manager.stopScan()
            self.peripheral = peripheral
            self.peripheral.delegate = self
            self.manager.connect(self.peripheral, options: nil)
            print ("Connecting to peripheral")
            // or add [binary_bluetooth_service] to scanForPeripherals withService
        }
    }
    
    // 3. For when the connection is completed. To discover services
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connected to: \(String(describing: peripheral.name))")
        peripheral.discoverServices(nil)
        print ("Discovering services")
    }
    
    // 4. When services are discovered, find characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print ("Services discovered")
        for service in peripheral.services! {
            let thisService = service.uuid
            print("discovered service: \(thisService)")
            if service.uuid == binary_bluetooth_service {
                peripheral.discoverCharacteristics(nil, for: service)
                print ("Finding characteristics")
            }
        }
    }
    
    // 5. Once characteristics are found for
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print ("Foun d characteristics")
        for characteristic in service.characteristics! {
            let thisCharacteristic = characteristic.uuid.uuidString
            print("discovered characteristic: \(characteristic) | read=\(characteristic.properties.contains(.read)) | write=\(characteristic.properties.contains(.write))")
            
            if thisCharacteristic == "?????????" {
                self.peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        var count = 1;
        
        if ((characteristic.uuid == binary_bluetooth_characteristic) &&
            (count == number_of_pictures)) {
            self.setRandomBackgroundColor()
            count = 1
        } else {
            count += 1
        }
    }
    
    func setRandomBackgroundColor() {
        let colors = [
            UIColor(red: 233/255, green: 203/255, blue: 198/255, alpha: 1),
            UIColor(red: 38/255, green: 188/255, blue: 192/255, alpha: 1),
            UIColor(red: 253/255, green: 221/255, blue: 164/255, alpha: 1),
            UIColor(red: 235/255, green: 154/255, blue: 171/255, alpha: 1),
            UIColor(red: 87/255, green: 141/255, blue: 155/255, alpha: 1)
        ]
        let randomColor = Int(arc4random_uniform(UInt32 (colors.count)))
        self.view.backgroundColor = colors[randomColor]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setRandomBackgroundColor()
        manager = CBCentralManager(delegate: self, queue: nil)
    }
}
