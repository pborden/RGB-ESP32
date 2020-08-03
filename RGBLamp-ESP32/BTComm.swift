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
        
        /*required init?(coder aDecoder: NSCoder) {
         let txData = aDecoder.decodeObject(forKey: self.txData) as? String
         fatalError("init(coder:) has not been implemented")
         } */
        
        // initialize global variables. Colors are global
        private init(transmittedData: String) {
            self.transmittedData = transmittedData
        }
        
        private init(receivedData: String) {
            self.receivedData = receivedData
        }
        /*
        init(white: String) {
            self.white = white
        }
        init(red: String) {
            self.red = red
        }
        init(green: String) {
            self.green = green
        }
        init(blue: String) {
            self.blue = blue
        }
        init(alpha: String) {
            self.alpha = alpha
        }
       init(frequency: String) {
            self.frequency = frequency
        }
        init(dutyCycle: String) {
            self.dutyCycle = dutyCycle
        }  */
        
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
        /*var white: String?
        var red: String?
        var green: String?
        var blue: String?
        var alpha: String?
        var frequency: String?
        var dutyCycle: String? */
        
        //var whiteSettings = WhiteLight()
       // var bulbLumens: String = ""
        //var bulbDistance: String = "10"
        //var lensDescriptions: [String] = [] // Array of keys for lenses found in ColorViewController; used in LensTableViewController
       // var research = Hue(name: "Dummy", red: 0.9, green: 0.9, blue: 0.9, alpha: 0.9)   // research view controller settings
        //var sensitivity = ColoredLight()
        //var flicker = FlickerLight()
       // var latestLens: String = "No Lens Chosen"  // last lens chosen in Simulate Tinted Lens Mode
       // var practitionerName: String = "Practitioner"  // name on summary screen
        
       // var flickerMode: Bool = false
        //var flickerColor: String = "w"
        //var flickerFrequency: Int = 60
        //var flickerDutyCycle: Int = 50
        
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
            
            blePeripheral = peripheral
            blePeripheral.delegate = self
            
            centralManager.stopScan()
            centralManager.connect(blePeripheral)
            
        }
        
        // after connected, find the services offered
        func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
            print("Connected!")
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

    //    Write a header value (r, g, b, w) and an integer to bluetooth
    //    Adds a comma as an end of string marker and a carriage return
    //    Used only in flicker mode. Other modes format string in base 32 and wirte directly with writeValue
      /*  func writeData(header: String, value: Int) {
            let delayInSeconds = 0.01 // changed from 0.001
            let appendString = "\n"
            let endOfString = ","
            let outputText = header + "\(value)" + endOfString
            for character in outputText {
                let inputText = "\(character)" + appendString
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
                self.writeValue(data: "\(inputText)")
                //print("\(character)")
                }
            }
            //print("\n")
        } */
}
