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
    
    let binary_bluethooth_name = "AB Shutter 3"
    let binary_bluetooth = CBUUID(string: "0x183B")
    
    // to check availability of bluethooth
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            central.scanForPeripherals(withServices: nil, options: nil)
        } else {
            print("Bluetooth not available.")
        }
    }
    
    // To scan for and connect to bluetooth device
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard peripheral.name != nil && peripheral.name?.starts(with: self.binary_bluethooth_name) ?? false else { return } // 1.
        print("discovered peripheral: \(peripheral.name!)")
        
        
        let device = (advertisementData as NSDictionary)
            .object(forKey: CBAdvertisementDataLocalNameKey)
            as? NSString
        
        if device?.contains(binary_bluethooth_name) == true {
            self.manager.stopScan()
            
            self.peripheral = peripheral
            self.peripheral.delegate = self
            
            manager.connect(peripheral, options: nil)
        }
    }
    
    // ensure connection and get list of services
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("connected to: \(String(describing: peripheral.name))")
        peripheral.discoverServices(nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            let thisService = service.uuid
            print("discovered service: \(thisService)")
            if service.uuid == binary_bluetooth {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            let thisCharacteristic = characteristic.uuid.uuidString
            print("discovered characteristic: \(characteristic) | read=\(characteristic.properties.contains(.read)) | write=\(characteristic.properties.contains(.write))")
            
            if thisCharacteristic == "?????????" {
                self.peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        var count = 0;
        
        if characteristic.uuid.uuidString == "???????" {
            self.setRandomBackgroundColor()
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
