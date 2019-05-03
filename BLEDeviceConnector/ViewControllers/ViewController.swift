//
//  ViewController.swift
//  BLEDeviceConnector
//
//  Created by Pavan N on 03/05/19.
//  Copyright © 2019 Pavan N. All rights reserved.
//

import Cocoa
import CoreBluetooth

var centralMangarGlabal: CBCentralManager?

class ViewController: NSViewController {
 //outlets
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var scanningBtn: NSButton!
    @IBOutlet weak var activityIndicator: NSProgressIndicator!
    
    var centralManager : CBCentralManager!
    var isScanning: Bool!
    var selectedPeripherial: CBPeripheral?
    var tableRowSelectedArray = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        let centralQueue: DispatchQueue = DispatchQueue(label: "com.iosbrain.centralQueueName", attributes: .concurrent)
        centralManager = CBCentralManager(delegate: self, queue: centralQueue)
        centralMangarGlabal = centralManager
    }
    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.title = "SweetZpot"
    }
    
    @IBAction func deviceScanning(_ sender: Any) {
        if centralManager.state == .poweredOn {
            if isScanning{
                stopScanning()
            }
            else if !isScanning{
                startScanning()
            }
        }
    }
    
    func startScanning(){
        isScanning = true
        centralManager.scanForPeripherals(withServices:nil)
        print("scanning started")
        DispatchQueue.main.async {
            self.scanningBtn.title = "Stop Scanning"
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimation(nil)
        }
    }
    
    func stopScanning(){
        isScanning = false
        centralManager.stopScan()
        print("scanning stopped")
        DispatchQueue.main.async {
            self.scanningBtn.title = "Start Scanning"
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimation(nil)
        }
    }
}

extension ViewController : CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("Bluetooth status is UNKNOWN")
        //bluetoothOffLabel.alpha = 1.0
        case .resetting:
            print("Bluetooth status is RESETTING")
        //bluetoothOffLabel.alpha = 1.0
        case .unsupported:
            print("Bluetooth status is UNSUPPORTED")
        //bluetoothOffLabel.alpha = 1.0
        case .unauthorized:
            print("Bluetooth status is UNAUTHORIZED")
        //bluetoothOffLabel.alpha = 1.0
        case .poweredOff:
            print("Bluetooth status is POWERED OFF")
        //bluetoothOffLabel.alpha = 1.0
        case .poweredOn:
            print("Bluetooth status is POWERED ON")
            startScanning()
        @unknown default:
            print("Unknown Error")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral.name)
        if !discoveredPeripherials.contains(peripheral){
            discoveredPeripherials.append(peripheral)
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connected to \(peripheral.name)")
        DispatchQueue.main.async { () -> Void in
            self.stopScanning()
            self.performSegue(withIdentifier: "toPeripherial", sender: nil)
        }
    }
}

extension ViewController : NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return discoveredPeripherials.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard let foundDevice =  discoveredPeripherials[row].name else {return "no Name"}
        return foundDevice
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let table = notification.object as! NSTableView
        let row = table.selectedRow
        if discoveredPeripherials.indices.contains(table.selectedRow), !tableRowSelectedArray.contains(row){
            tableRowSelectedArray.append(row)
            selectedPeripherial = discoveredPeripherials[table.selectedRow]
            centralManager.connect(selectedPeripherial!)
        }else{
            return
        }
    }
    
    //segue
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPeripherial" {
            let vc = segue.destinationController as! PeripheralVC
            vc.peripherial = selectedPeripherial
        }
    }

}

