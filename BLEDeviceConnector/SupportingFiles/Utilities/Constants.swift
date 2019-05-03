//
//  Constants.swift
//  BLEDeviceConnector
//
//  Created by Pavan N on 03/05/19.
//  Copyright © 2019 Pavan N. All rights reserved.
//

import Foundation
import CoreBluetooth

var discoveredPeripherials = [CBPeripheral]()

let HEART_RATE_MONITOR_UUID = "0000180d-0000-1000-8000-00805f9b34fb"
let STRAIN_GAUGE_UUID = "0000ffb0-0000-1000-8000-00805f9b34fb"

let BREATHING_SERVICE = CBUUID(string:"0xffb0")
let BREATHING_CHARACTERISTIC = CBUUID(string:"0xffb3")

let HEART_RATE_SERVICE = CBUUID(string:"0x180d")
let HEART_RATE_CHARACTERISTIC = CBUUID(string:"0x2a37")

let BATTERY_SERVICE = CBUUID(string:"0x180f")
let BATTERY_CHARACTERISTIC = CBUUID(string:"0x2a19")
let DEVICE_INFORMATION_SERVICE = CBUUID(string:"0x180a")
let FIRMWARE_CHARACTERISTIC = CBUUID(string:"0x2a26")

