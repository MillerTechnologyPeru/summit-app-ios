//
//  Decode.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData

/// Specifies how a type can be decoded from Core Data.
public protocol CoreDataDecodable {
    
    associatedtype ManagedObject: NSManagedObject
    
    init(managedObject: ManagedObject)
}

public extension NSManagedObjectContext {
    
    /// Executes a fetch request and returns ```CoreDataDecodable``` types.
    func fetch<T: CoreDataDecodable>(fetchRequest: NSFetchRequest) throws -> [T] {
        
        guard fetchRequest.resultType == .ManagedObjectResultType
            else { fatalError("Method only supports fetch requests with NSFetchRequestManagedObjectResultType") }
        
        let managedObjects = try self.executeFetchRequest(fetchRequest) as! [T.ManagedObject]
        
        let decodables = managedObjects.map { (element) -> T in T.init(managedObject: element) }
        
        return decodables
    }
    
    @inline(__always)
    func managedObjects<T: CoreDataDecodable>(decodableType: T.Type, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor] = []) throws -> [T] {
        
        let results = try self.managedObjects(decodableType.ManagedObject.self)
        
        return T.from(managedObjects: results)
    }
}

public extension CoreDataDecodable {
    
    static func from<C: CollectionType where C.Generator.Element == ManagedObject>(managedObjects managedObjects: C) -> [Self] {
        
        return managedObjects.map { self.init(managedObject: $0) }
    }
}

public extension CoreDataDecodable where Self: Hashable {
    
    static func from(managedObjects managedObjects: Set<ManagedObject>) -> Set<Self> {
        
        return Set(managedObjects.map({ self.init(managedObject: $0) }))
    }
}
