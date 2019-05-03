//
//  PeripheralVC.swift
//  BLEDeviceConnector
//
//  Created by Pavan N on 03/05/19.
//  Copyright © 2019 Pavan N. All rights reserved.
//

import Cocoa
import CoreBluetooth

class PeripheralVC: NSViewController, CBPeripheralDelegate{
    @IBOutlet var strainGaugeTextView: NSTextView!
    @IBOutlet weak var deviceInfoTextView: NSTextView!
    @IBOutlet var heartRateTextView: NSTextView!
    
    var peripherial: CBPeripheral?
    var batteryCount = 1
    var firmwareCount = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        peripherial?.delegate = self
        append(toTextView: deviceInfoTextView, text: "\nName : \(peripherial?.name ?? "Device")")
        append(toTextView: deviceInfoTextView, text: decodePeripheralState(peripheralState: peripherial!.state))
        peripherial?.discoverServices(nil)
    }
    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.title = peripherial?.name ?? "BLEDevice"
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            if service.uuid == BREATHING_SERVICE {
                peripheral.discoverCharacteristics([BREATHING_CHARACTERISTIC], for: service)
            }
            if service.uuid == HEART_RATE_SERVICE {
                peripheral.discoverCharacteristics([HEART_RATE_CHARACTERISTIC], for: service)
            }
            if service.uuid == BATTERY_SERVICE {
                peripheral.discoverCharacteristics([BATTERY_CHARACTERISTIC], for: service)
            }
            if service.uuid == DEVICE_INFORMATION_SERVICE {
                peripheral.discoverCharacteristics([FIRMWARE_CHARACTERISTIC], for: service)
            }
            
        }
    }
    @IBAction func disconnectDevice(_ sender: Any) {
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            //heart rate
            if characteristic.uuid == HEART_RATE_CHARACTERISTIC {
                peripheral.readValue(for: characteristic)
            }
            if characteristic.uuid == HEART_RATE_CHARACTERISTIC {
                peripheral.setNotifyValue(true, for: characteristic)
            }
            //breathing service
            if characteristic.uuid == BREATHING_CHARACTERISTIC {
                peripheral.readValue(for: characteristic)
            }
            if characteristic.uuid == BREATHING_CHARACTERISTIC {
                peripheral.setNotifyValue(true, for: characteristic)
            }
            //firmware service
            if characteristic.uuid == FIRMWARE_CHARACTERISTIC {
                peripheral.readValue(for: characteristic)
            }
            if characteristic.uuid == FIRMWARE_CHARACTERISTIC {
                peripheral.setNotifyValue(false, for: characteristic)
            }
            //battery service
            if characteristic.uuid == BATTERY_CHARACTERISTIC {
                peripheral.readValue(for: characteristic)
            }
            if characteristic.uuid == BATTERY_CHARACTERISTIC {
                peripheral.setNotifyValue(false, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if characteristic.uuid == BREATHING_CHARACTERISTIC {
            //let heartRate = deriveBeatsPerMinute(using: characteristic)
            //print(peripheral.identifier)
            DispatchQueue.main.async { () -> Void in
                self.extractStrainGauge(value: characteristic.value!)
            }
        }
        
        if characteristic.uuid == HEART_RATE_CHARACTERISTIC {
            DispatchQueue.main.async { () -> Void in
                self.append(toTextView: self.heartRateTextView, text: String("\(self.extractHeartRate(characteristic.value))"))
            }
        }
        
        if characteristic.uuid == FIRMWARE_CHARACTERISTIC {
            DispatchQueue.main.async { () -> Void in
                if self.firmwareCount < 2 {
                    self.append(toTextView: self.deviceInfoTextView, text:"Firmware: \(String(data: characteristic.value!, encoding: .utf8) ?? "NAN")")
                    self.firmwareCount += 1
                }
            }
        }
        
        if characteristic.uuid == BATTERY_CHARACTERISTIC {
            DispatchQueue.main.async { () -> Void in
                if self.batteryCount < 2 {
                    let battery = (characteristic.value!.withUnsafeBytes { (values : UnsafePointer<UInt8>)->UInt8 in return values[0] })
                    self.append(toTextView: self.deviceInfoTextView,
                                text: "Battery: \(battery)%")
                    self.batteryCount += 1
                }
            }
        }
    }
    
    
    func extractStrainGauge(value : Data) {
        value.withUnsafeBytes { (values: UnsafePointer<UInt16>) in
            let timestamp = self.currentTimeMilliseconds()
            var readings = [Strain]()
            for i in 0 ..< 7 {
                let data = Strain(value: values[i], timestamp: timestamp + 50 * Double(i))
                readings.append(data)
                append(toTextView: strainGaugeTextView, text: String("\(data.value)"))
            }
        }
    }
    
    func currentTimeMilliseconds() -> Double {
        return Date().timeIntervalSince1970 * 1000.0
    }
    
    func extractHeartRate(_ data : Data?) -> Int {
        guard let data = data else { return 0}
        var buffer = [UInt8](repeating: 0x00, count: data.count)
        (data as NSData).getBytes(&buffer, length: buffer.count)
        
        var bpm:UInt16?
        if (buffer.count >= 2){
            if (buffer[0] & 0x01 == 0){
                bpm = UInt16(buffer[1]);
            }else {
                bpm = UInt16(buffer[1]) << 8
                bpm =  bpm! | UInt16(buffer[2])
            }
        }
        
        if let actualBPM = bpm {
            return Int(actualBPM)
        } else {
            return 0
        }
    }
    
    
    func decodePeripheralState(peripheralState: CBPeripheralState) -> String {
        
        switch peripheralState {
        case .disconnected:
            return("Peripheral state: disconnected")
        case .connected:
            return("Peripheral state: connected")
        case .connecting:
            return("Peripheral state: connecting")
        case .disconnecting:
            return("Peripheral state: disconnecting")
        @unknown default:
            return "Unknown State"
        }
    }
    
    func append(toTextView:NSTextView ,text: String?) {
        DispatchQueue.main.async(execute: {
            let attr = NSAttributedString(string: "\(text ?? "")\n")
            toTextView.textStorage?.append(attr)
            toTextView.scrollToEndOfDocument(nil)
        })
    }

}
