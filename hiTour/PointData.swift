//
//  PointData.swift
//  hiTour
//
//  Created by Adam Chlupacek on 18/02/16.
//  Copyright © 2016 stranders.kcl.ac.uk. All rights reserved.
//

import Foundation
import CoreData


class PointData: NSManagedObject {
    
    static let entityName = "PointData"
    static let jsonReader = PointDataReader()


// Insert code here to add functionality to your managed object subclass

}

class PointDataReader: JsonReader{
    typealias T = PointData
    
    func read(dict: [String: AnyObject]) -> ((NSEntityDescription, NSManagedObjectContext) -> PointData)? {
        guard let rank = dict["rank"] as? Int else {
            return nil
        }
        
        return
            {(entity: NSEntityDescription, context: NSManagedObjectContext) -> PointData in
                let point = PointData(entity: entity, insertIntoManagedObjectContext: context)
                point.rank = rank
                
                return point
        }
    }
}