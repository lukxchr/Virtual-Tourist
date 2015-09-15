//
//  DE1.swift
//  Virtual Tourist
//
//  Created by Lukasz Chrzanowski on 14/09/2015.
//  Copyright (c) 2015 ___LC___. All rights reserved.
//

import Foundation
import CoreData

@objc(DE1)

class DE1: NSManagedObject {

    @NSManaged var d: NSNumber
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    init(d: Double, context: NSManagedObjectContext) {
        
        
        let entity =  NSEntityDescription.entityForName("DE1", inManagedObjectContext: context)!
        
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        self.d = d
        
    }

}
