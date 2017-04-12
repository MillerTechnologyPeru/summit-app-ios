//
//  TagManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData

public final class TagManagedObject: Entity {
    
    @NSManaged public var name: String
}

// MARK: - Encoding

extension Tag: CoreDataDecodable {
    
    public init(managedObject: TagManagedObject) {
        
        self.identifier = managedObject.identifier
        self.name = managedObject.name
    }
}

extension Tag: CoreDataEncodable {
    
    public func save(_ context: NSManagedObjectContext) throws -> TagManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.name = name
        
        managedObject.didCache()
        
        return managedObject
    }
}

// MARK: - Fetches

public extension TagManagedObject {
    
    static var sortDescriptors: [NSSortDescriptor] {
        
        return [NSSortDescriptor(key: "name", ascending: true)]
    }
}

public extension Tag {
    
    static func search(_ searchTerm: String, context: NSManagedObjectContext) throws -> [Tag] {
        
        let predicate = NSPredicate(format: "name CONTAINS[c] %@", searchTerm)
        
        let managedObjects = try context.managedObjects(ManagedObject.self, predicate: predicate, sortDescriptors: ManagedObject.sortDescriptors)
        
        return Tag.from(managedObjects: managedObjects)
    }
}
