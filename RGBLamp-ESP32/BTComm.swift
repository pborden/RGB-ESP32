//
//  BTComm.swift
//  RGBLamp
//
//  Created by Peter Borden on 3/14/20.
//  Copyright © 2020 Peter Borden. All rights reserved.
//

import UIKit
import CoreBluetooth

struct Hue {
    var name: String = ""
    var red: Float = 0.1
    var green: Float = 0.1
    var blue: Float = 0.1
    var alpha: Float = 0.1
}

class BTComm: NSObject {

        // set private variable as part of creating singleton so communication global among modules, runs continuously
        private static var sharedBTComm: BTComm = {
            let Z = BTComm()
            return Z
        }()
        
        var transmittedData: String = ""
        var receivedData: String = ""
        var connected: Bool = false
        
        // initialize global variables. Colors are global
        private init(transmittedData: String) {
            self.transmittedData = transmittedData
        }
        
        private init(receivedData: String) {
            self.receivedData = receivedData
        }
        
        // Shared is the class that shares BTComm across the program
        class func shared() -> BTComm {
            return sharedBTComm
        }
        // outlets for the field that shows the communication, input text field, send button
        // scroll view scrolls the text field when it reaches the end
        
        var centralManager: CBCentralManager!
        var blePeripheral: CBPeripheral!
        
        var txCharacteristic : CBCharacteristic?
        var rxCharacteristic : CBCharacteristic?
        var characteristicASCIIValue = NSString()
        var research = Hue(name: "Dummy", red: 0.9, green: 0.9, blue: 0.9, alpha: 0.9)   // research view controller settings
        
        override init() {
            super.init()
            centralManager = CBCentralManager(delegate: self, queue: nil)
        }
    }

    extension BTComm: CBCentralManagerDelegate {
        
        // find out if the bluetooth is powered on. If so, scan for the peripheral
        func centralManagerDidUpdateState(_ central: CBCentralManager) {
            switch central.state {
            case .unknown:
                print("central.state is .unknown")
            case .resetting:
                print("central.state is .resetting")
            case .unsupported:
                print("central.state is .unsupported")
            case .unauthorized:
                print("central.state is .unauthorized")
            case .poweredOff:
                print("central.state is .poweredOff")
            case .poweredOn:
                print("central.state is .poweredOn")
                centralManager.scanForPeripherals(withServices: [BLEService_UUID])
            @unknown default:
                print("unknown bluetooth error")
            }
        }
        
        // found the peripheral. stop scanning and connect
        func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber) {
            print(peripheral)
            let peripheralName = peripheral.name
            let peripheralID = peripheral.identifier
            print("Lamp name = \(peripheralName ?? "No name found")")
            print("Lamp ID = \(peripheralID)")
            
            blePeripheral = peripheral
            blePeripheral.delegate = self
            
            centralManager.stopScan()
            centralManager.connect(blePeripheral)
            
        }
        
        // after connected, find the services offered
        func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
            print("Connected!")
            connected = true
            blePeripheral.discoverServices([BLEService_UUID])
        }
    }

    // Extension handles discovered services
    extension BTComm: CBPeripheralDelegate {
        func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
            guard let services = peripheral.services else { return }
            for service in services {
                print(service)
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
        
        func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
            guard let characteristics = service.characteristics else { return }
            
            /*for characteristic in characteristics {
             print(characteristic)*/
            print("*******************************************************")
            
            print("Found \(characteristics.count) characteristics!")
            
            for characteristic in characteristics {
                //looks for the right characteristic
                
                if characteristic.uuid.isEqual(BLE_Characteristic_uuid_Rx)  {
                    rxCharacteristic = characteristic
                    
                    //Once found, subscribe to the this particular characteristic...
                    peripheral.setNotifyValue(true, for: rxCharacteristic!)
                    // We can return after calling CBPeripheral.setNotifyValue because CBPeripheralDelegate's
                    // didUpdateNotificationStateForCharacteristic method will be called automatically
                    peripheral.readValue(for: characteristic)
                    print("Rx Characteristic: \(characteristic.uuid)")
                    if rxCharacteristic!.properties.contains(.read) {
                        print("Rx Characteristic contains .read")
                    }
                    if rxCharacteristic!.properties.contains(.write) {
                        print("Rx Characteristic contains .write")
                    }
                    if rxCharacteristic!.properties.contains(.notify) {
                        print("Rx Characteristic contains .notify")
                    }
                }
                if characteristic.uuid.isEqual(BLE_Characteristic_uuid_Tx){
                    txCharacteristic = characteristic
                    print("Tx Characteristic: \(characteristic.uuid)")
                    if txCharacteristic!.properties.contains(.read) {
                        print("Tx Characteristic contains .read")
                    }
                    if txCharacteristic!.properties.contains(.write) {
                        print("Tx Characteristic contains .write")
                    }
                    if txCharacteristic!.properties.contains(.notify) {
                        print("Tx Characteristic contains .notify")
                    }
                }
                peripheral.setNotifyValue(true, for: (rxCharacteristic ?? nil)!)
            }
            
        }
        
        func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
            switch characteristic.uuid {
            case BLE_Characteristic_uuid_Tx:
                print(characteristic.value ?? "no value")
            case BLE_Characteristic_uuid_Rx:
                receivedData = rxData(from: characteristic)
               // print("Received data: " + receivedData)
            default:
                print("Unhandled Characteristic UUID: \(characteristic.uuid)")
            }
        }
        
    //    Receive data from bluetooth
        func rxData(from characteristic: CBCharacteristic) -> String {
            guard let charcteristicData = characteristic.value else { return "empty"}
            let byteArray = [UInt8](charcteristicData)
            let stringArray = String(data: Data(byteArray), encoding: .utf8)
            return stringArray ?? "empty"
        }
        
    //    Write a fully formatted string to the bluetooth
        func writeValue(data: String){
            let valueString = (data as NSString).data(using: String.Encoding.utf8.rawValue)
            //change the "data" to valueString
            if let blePeripheral = blePeripheral{
                if let txCharacteristic = txCharacteristic {
                    blePeripheral.writeValue(valueString!, for: txCharacteristic, type: CBCharacteristicWriteType.withResponse)
                }
            }
        }
        
       /* func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
            if error != nil {
                connected = false
                return
            }
            // Successfully wrote value to characteristic
        } */

}
