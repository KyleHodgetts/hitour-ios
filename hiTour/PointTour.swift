//
//  PointTour.swift
//  hiTour
//
//  Created by Adam Chlupacek on 18/02/16.
//  Copyright © 2016 stranders.kcl.ac.uk. All rights reserved.
//

import Foundation
import CoreData


class PointTour: NSManagedObject {
    
    static let entityName = "PointTour"
    static let jsonReader = PointTourReader()

}

class PointTourReader: JsonReader{
    typealias T = PointTour
    
    ///
    /// Parses the object and stores it in the core data
    ///
    func read(dict: [String: AnyObject], stack: CoreDataStack) -> ((NSEntityDescription, NSManagedObjectContext) -> PointTour)? {
        guard let rank = dict["rank"] as? Int else {
            return nil
        }
                
        return
            {(entity: NSEntityDescription, context: NSManagedObjectContext) -> PointTour in
                let pointTour = PointTour(entity: entity, insertIntoManagedObjectContext: context)
                pointTour.rank = rank
                pointTour.scanned = false
                
                return pointTour
        }
    }
    
    func entityName() -> String {
        return PointTour.entityName
    }
}