//
//  Strain.swift
//  BLEDeviceConnector
//
//  Created by Pavan N on 03/05/19.
//  Copyright © 2019 Pavan N. All rights reserved.
//

import Foundation

import Foundation

struct Strain {
    let value : UInt16
    //let timestamp : Double
}

struct ExportCSVStruct {
    let UUID: UUID
    let strainGauge: [String]
    let HeartRate: Int
}


//            try! csv.write(row: [csvData.UUID.uuidString,csvData.strainGauge[0].value.description,csvData.strainGauge[1].value.description,csvData.strainGauge[2].value.description,csvData.strainGauge[3].value.description,csvData.strainGauge[4].value.description,csvData.strainGauge[5].value.description,csvData.strainGauge[6].value.description,])
// try! csv.write(row: ["id", "name"])
// Write fields separately
