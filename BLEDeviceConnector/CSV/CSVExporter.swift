//
//  CSVExporter.swift
//  SweetZpot Dataflow
//
//  Created by Pavan N on 04/05/19.
//  Copyright © 2019 Pavan N. All rights reserved.
//

import Foundation
import CSV

class CSVExporter {
    
    static func startExportData(data:ExportCSVStruct){
        let value = data.strainGauge
        guard let csv = csv else {return}
        if !data.strainGauge.isEmpty {
            csv.beginNewRow()
            try? csv.write(field:data.UUID.uuidString)
            for num in value{
                try? csv.write(field:num)
            }
            try? csv.write(field: data.HeartRate.description)
        }
    }
    
    static func stopExportingData(){
        
    }
}
